import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'format.dart';
import 'mock_data.dart';
import 'models.dart';

/// Uygulamanın tüm demo durumu. Gerçek uygulamada bu veriler SBS servislerinden
/// ve push bildirim altyapısından gelir; burada bellek içinde simüle edilir.
class AppState extends ChangeNotifier {
  AppState({bool simulate = true}) {
    _primeBadges();
    if (simulate) {
      _timer = Timer.periodic(const Duration(seconds: 2), (_) => _tick());
    }
  }

  final _rng = Random(7);
  Timer? _timer;

  final List<Athlete> athletes = MockData.athletes;
  final List<Club> clubs = MockData.clubs;
  final List<Tournament> tournaments = MockData.tournaments();
  final List<LiveMatch> matches = MockData.matches();
  final List<NewsItem> news = MockData.news();
  final List<FeedPost> _feed = MockData.feed();
  final List<TrainingEntry> training = MockData.training();

  final Set<String> followed = {'a3', 'a1'};

  /// Kullanıcının kendi kulübü varsayılan olarak takip edilir.
  final Set<String> followedClubs = {'c1'};
  final Set<String> reminders = {'t1'};
  final Set<String> applied = {};
  final Set<String> _watchedMatches = {};
  final Set<String> earnedBadges = {};

  /// Kademeli hatırlatma adımları: son başvuruya kalan gün -> açık/kapalı.
  final Map<int, bool> reminderSteps = {3: true, 1: true, 0: true};
  bool notifyMatchStart = true;
  bool notifyResults = true;

  final List<AppNotice> notices = [];

  // Ölçümleme: bu cihazdaki oturumda toplanan olay sayaçları. Gerçek
  // uygulamada bu olaylar bir analitik servisine gönderilir.
  final DateTime sessionStart = DateTime.now();
  int noticesShown = 0;
  int noticesOpened = 0;
  final Map<String, int> screenViews = {};
  final _incoming = StreamController<AppNotice>.broadcast();

  /// Ekranda anlık gösterilecek yeni bildirimler (uygulama içi push simülasyonu).
  Stream<AppNotice> get incoming => _incoming.stream;

  Athlete athlete(String id) => athletes.firstWhere((a) => a.id == id);
  Athlete get me => athlete(MockData.meId);
  Club club(String id) => clubs.firstWhere((c) => c.id == id);
  Club? clubOf(Athlete a) => clubs.where((c) => c.name == a.club).firstOrNull;
  List<Athlete> athletesOf(Club c) =>
      athletes.where((a) => a.club == c.name).toList()
        ..sort((a, b) => a.ranking.compareTo(b.ranking));
  List<FeedPost> postsOf(Club c) =>
      _feed.where((p) => p.clubId == c.id).toList()
        ..sort((a, b) => b.time.compareTo(a.time));
  int get matchViews => _watchedMatches.length;

  int get unreadCount => notices.where((n) => !n.read).length;

  List<LiveMatch> get liveMatches =>
      matches.where((m) => m.status == MatchStatus.live).toList();
  List<LiveMatch> get upcomingMatches =>
      matches.where((m) => m.status == MatchStatus.upcoming).toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  List<LiveMatch> get finishedMatches =>
      matches.where((m) => m.status == MatchStatus.finished).toList();

  /// "Bugün" bloğu: canlı maçlar önce, sonra saat sırasına göre yaklaşanlar.
  List<LiveMatch> get todayMatches => [
    ...liveMatches,
    ...upcomingMatches.where((m) => dateOnly(m.startTime) == today),
  ];

  /// Takip edilen sporculara ve kulüplere ait akış, en yeni üstte.
  List<FeedPost> get feed =>
      _feed
          .where(
            (p) =>
                followed.contains(p.athleteId) ||
                followedClubs.contains(p.clubId),
          )
          .toList()
        ..sort((a, b) => b.time.compareTo(a.time));

  /// Son başvuru tarihi geçmemiş en yakın turnuva.
  Tournament? get nextDeadline {
    final open = tournaments.where((t) => daysUntil(t.deadline) >= 0).toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return open.isEmpty ? null : open.first;
  }

  // ---------------------------------------------------------------------------
  // Kullanıcı eylemleri

  void toggleFollow(String athleteId) {
    followed.contains(athleteId)
        ? followed.remove(athleteId)
        : followed.add(athleteId);
    _changed();
  }

  void toggleFollowClub(String clubId) {
    followedClubs.contains(clubId)
        ? followedClubs.remove(clubId)
        : followedClubs.add(clubId);
    _changed();
  }

  /// Ekran görüntüleme olayı. Dinleyicileri tetiklemez; sayaçlar ölçümleme
  /// ekranı açıldığında okunur.
  void logView(String screen) {
    screenViews[screen] = (screenViews[screen] ?? 0) + 1;
  }

  /// Bildirimler ekranı açıldığında okunmamışlar "açılmış" sayılır.
  void openNotices() {
    for (final n in notices.where((n) => !n.read)) {
      n.read = true;
      noticesOpened++;
    }
    notifyListeners();
  }

  void toggleReminder(String tournamentId) {
    reminders.contains(tournamentId)
        ? reminders.remove(tournamentId)
        : reminders.add(tournamentId);
    _changed();
  }

  void apply(String tournamentId) {
    applied.add(tournamentId);
    reminders.remove(tournamentId);
    _changed();
  }

  void setReminderStep(int days, bool on) {
    reminderSteps[days] = on;
    notifyListeners();
  }

  void setNotifyMatchStart(bool on) {
    notifyMatchStart = on;
    notifyListeners();
  }

  void setNotifyResults(bool on) {
    notifyResults = on;
    notifyListeners();
  }

  void watchMatch(String matchId) {
    if (_watchedMatches.add(matchId)) _changed();
  }

  void addTraining(TrainingEntry entry) {
    training.add(entry);
    training.sort((a, b) => b.date.compareTo(a.date));
    _changed();
  }

  /// Kademeli hatırlatmaları tetikler. Gerçek uygulamada bunlar sunucu
  /// tarafında zamanlanır; demo için tek tuşla hepsi üretilir.
  int sendDueReminders() {
    var sent = 0;
    for (final t in tournaments) {
      if (!reminders.contains(t.id) || applied.contains(t.id)) continue;
      final days = daysUntil(t.deadline);
      if (reminderSteps[days] == true) {
        _notify(AppNotice(deadlineLabel(days), t.name, NoticeKind.reminder));
        sent++;
      }
    }
    return sent;
  }

  // ---------------------------------------------------------------------------
  // Antrenman günlüğü

  /// Bugün (ya da bugün henüz kayıt yoksa dün) biten ardışık gün sayısı.
  int get trainingStreak {
    final days = training.map((e) => dateOnly(e.date)).toSet();
    var cursor = days.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  bool get trainedToday => training.any((e) => dateOnly(e.date) == today);

  /// Son 7 günün dakika toplamları, eskiden yeniye.
  List<int> get weeklyMinutes => List.generate(7, (i) {
    final day = today.subtract(Duration(days: 6 - i));
    return training
        .where((e) => dateOnly(e.date) == day)
        .fold(0, (sum, e) => sum + e.minutes);
  });

  // ---------------------------------------------------------------------------
  // Rozetler

  bool _isEarned(String id) => switch (id) {
    'first_log' => training.isNotEmpty,
    'streak3' => trainingStreak >= 3,
    'streak7' => trainingStreak >= 7,
    'follower' => followed.length >= 3,
    'live_fan' => _watchedMatches.length >= 3,
    'planner' => reminders.length >= 2,
    'applicant' => applied.isNotEmpty,
    'club_fan' => followedClubs.isNotEmpty,
    _ => false,
  };

  /// Açılışta zaten hak edilmiş rozetler için bildirim üretmeden işaretler.
  void _primeBadges() {
    for (final b in MockData.badges) {
      if (_isEarned(b.id)) earnedBadges.add(b.id);
    }
  }

  void _checkBadges() {
    for (final b in MockData.badges) {
      if (!earnedBadges.contains(b.id) && _isEarned(b.id)) {
        earnedBadges.add(b.id);
        _notify(
          AppNotice('Yeni rozet: ${b.title}', b.description, NoticeKind.badge),
        );
      }
    }
  }

  void _changed() {
    _checkBadges();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Canlı skor simülasyonu

  void _tick() {
    final now = DateTime.now();
    for (final m in matches) {
      if (m.status == MatchStatus.upcoming && !m.startTime.isAfter(now)) {
        m.status = MatchStatus.live;
        if (notifyMatchStart && _followsAny(m)) {
          _notify(AppNotice('Maç başladı', _names(m), NoticeKind.matchStart));
        }
      }
    }
    // Her tikte tek bir canlı maça sayı verilir; maçlar demo boyunca sürsün.
    final live = liveMatches;
    if (live.isNotEmpty) {
      final m = live[_rng.nextInt(live.length)];
      _playPoint(m, now);
    }
    notifyListeners();
  }

  void _playPoint(LiveMatch m, DateTime now) {
    // Sıralaması daha iyi olan oyuncu sayıyı biraz daha sık alır.
    final a = athlete(m.playerA), b = athlete(m.playerB);
    final pA = 0.5 + (b.ranking - a.ranking).clamp(-10, 10) * 0.015;
    final event = m.addPoint(_rng.nextDouble() < pA);
    if (event == PointEvent.point || !notifyResults || !_followsAny(m)) {
      return;
    }
    final score = m.sets
        .where((s) => s.isOver)
        .map((s) => '${s.a}-${s.b}')
        .join(', ');
    if (event == PointEvent.matchWon) {
      final w = athlete(m.winner!);
      _notify(
        AppNotice(
          'Maç sonucu',
          '${w.name} kazandı ($score)',
          NoticeKind.result,
        ),
      );
      _feed.add(
        FeedPost(
          athleteId: w.id,
          text: '${m.category} maçını $score kazandı.',
          time: now,
          kind: FeedKind.result,
        ),
      );
    } else {
      _notify(
        AppNotice('Set bitti', '${_names(m)} · $score', NoticeKind.result),
      );
    }
  }

  /// Maçtaki oyunculardan biri ya da oyuncunun kulübü takip ediliyor mu?
  bool _followsAny(LiveMatch m) => [m.playerA, m.playerB].any(
    (id) =>
        followed.contains(id) ||
        followedClubs.contains(clubOf(athlete(id))?.id),
  );

  String _names(LiveMatch m) =>
      '${athlete(m.playerA).name} - ${athlete(m.playerB).name}';

  void _notify(AppNotice n) {
    noticesShown++;
    notices.insert(0, n);
    _incoming.add(n);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _incoming.close();
    super.dispose();
  }
}

/// Durumu ağaç boyunca paylaşır; paket bağımlılığı olmadan basit bir sağlayıcı.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  /// Durum değiştiğinde yeniden çizilmesi gereken widget'lar için.
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;

  /// Yalnızca eylem çağıran (dinlemeyen) yerler için.
  static AppState read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
