import 'package:flutter/material.dart';

import 'models.dart';

/// Demo verileri. Tüm isimler ve sonuçlar kurgusaldır; tarihler uygulamanın
/// açıldığı güne göre üretilir, böylece "Bugün" bloğu her zaman dolu görünür.
class MockData {
  MockData._();

  /// Demo kullanıcısının kendi sporcu kaydı.
  static const meId = 'a1';

  static const athletes = <Athlete>[
    Athlete(
      id: 'a1',
      name: 'Deniz Kaya',
      club: 'Ankara Gençlik Spor Kulübü',
      city: 'Ankara',
      category: 'Tek Erkekler',
      ranking: 7,
      rankingHistory: [18, 16, 15, 12, 12, 10, 9, 7],
      wins: 23,
      losses: 9,
      form: [true, true, false, true, true],
    ),
    Athlete(
      id: 'a2',
      name: 'Emre Aydın',
      club: 'Bursa Osmangazi Spor',
      city: 'Bursa',
      category: 'Tek Erkekler',
      ranking: 4,
      rankingHistory: [5, 5, 4, 6, 5, 4, 4, 4],
      wins: 31,
      losses: 8,
      form: [true, false, true, true, true],
    ),
    Athlete(
      id: 'a3',
      name: 'Elif Yıldız',
      club: 'Erzincan Badminton İhtisas',
      city: 'Erzincan',
      category: 'Tek Kadınlar',
      ranking: 2,
      rankingHistory: [6, 5, 4, 3, 3, 2, 2, 2],
      wins: 35,
      losses: 5,
      form: [true, true, true, false, true],
    ),
    Athlete(
      id: 'a4',
      name: 'Zeynep Arslan',
      club: 'İzmir Karşıyaka Spor',
      city: 'İzmir',
      category: 'Tek Kadınlar',
      ranking: 5,
      rankingHistory: [3, 4, 4, 5, 6, 5, 5, 5],
      wins: 27,
      losses: 11,
      form: [false, true, false, true, true],
    ),
    Athlete(
      id: 'a5',
      name: 'Mert Şahin',
      club: 'Tokat Gençlik ve Spor',
      city: 'Tokat',
      category: 'Tek Erkekler',
      ranking: 11,
      rankingHistory: [14, 13, 13, 12, 11, 12, 11, 11],
      wins: 18,
      losses: 12,
      form: [true, false, false, true, true],
    ),
    Athlete(
      id: 'a6',
      name: 'Can Öztürk',
      club: 'Isparta Davraz Spor',
      city: 'Isparta',
      category: 'Tek Erkekler',
      ranking: 9,
      rankingHistory: [8, 8, 9, 9, 10, 9, 9, 9],
      wins: 20,
      losses: 13,
      form: [false, true, true, false, true],
    ),
    Athlete(
      id: 'a7',
      name: 'Ayşe Demir',
      club: 'Adana Alp Spor',
      city: 'Adana',
      category: 'Tek Kadınlar',
      ranking: 8,
      rankingHistory: [12, 11, 10, 10, 9, 9, 8, 8],
      wins: 19,
      losses: 10,
      form: [true, true, false, true, false],
    ),
    Athlete(
      id: 'a8',
      name: 'Selin Koç',
      club: 'Kars Voleybol ve Spor',
      city: 'Kars',
      category: 'Tek Kadınlar',
      ranking: 12,
      rankingHistory: [15, 15, 14, 13, 13, 12, 12, 12],
      wins: 14,
      losses: 12,
      form: [false, false, true, true, false],
    ),
  ];

  static Athlete athlete(String id) => athletes.firstWhere((a) => a.id == id);

  static const clubs = <Club>[
    Club(
      id: 'c1',
      name: 'Ankara Gençlik Spor Kulübü',
      city: 'Ankara',
      founded: 2008,
    ),
    Club(id: 'c2', name: 'Bursa Osmangazi Spor', city: 'Bursa', founded: 2004),
    Club(
      id: 'c3',
      name: 'Erzincan Badminton İhtisas',
      city: 'Erzincan',
      founded: 2011,
    ),
    Club(id: 'c4', name: 'İzmir Karşıyaka Spor', city: 'İzmir', founded: 1999),
    Club(id: 'c5', name: 'Tokat Gençlik ve Spor', city: 'Tokat', founded: 2017),
    Club(id: 'c6', name: 'Isparta Davraz Spor', city: 'Isparta', founded: 2016),
    Club(id: 'c7', name: 'Adana Alp Spor', city: 'Adana', founded: 2017),
    Club(id: 'c8', name: 'Kars Voleybol ve Spor', city: 'Kars', founded: 2009),
  ];

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static List<Tournament> tournaments() {
    final t = _today;
    return [
      Tournament(
        id: 't1',
        name: 'Türkiye Büyükler Badminton Şampiyonası',
        location: 'Ankara',
        start: t.add(const Duration(days: 12)),
        end: t.add(const Duration(days: 15)),
        deadline: t,
      ),
      Tournament(
        id: 't2',
        name: 'Gençler Türkiye Kupası',
        location: 'Erzincan',
        start: t.add(const Duration(days: 18)),
        end: t.add(const Duration(days: 20)),
        deadline: t.add(const Duration(days: 1)),
      ),
      Tournament(
        id: 't3',
        name: 'Sri Lanka International Series',
        location: 'Sri Lanka',
        start: t.add(const Duration(days: 25)),
        end: t.add(const Duration(days: 31)),
        deadline: t.add(const Duration(days: 3)),
      ),
      Tournament(
        id: 't4',
        name: 'Kulüpler Arası Karışık Çiftler Ligi',
        location: 'İzmir',
        start: t.add(const Duration(days: 40)),
        end: t.add(const Duration(days: 42)),
        deadline: t.add(const Duration(days: 21)),
      ),
    ];
  }

  static List<LiveMatch> matches() {
    final now = DateTime.now();
    const tour = 'Ankara Açık Turnuvası';
    return [
      LiveMatch(
        id: 'm1',
        tournament: tour,
        category: 'Tek Erkekler · Yarı Final',
        court: 'Kort 1',
        playerA: 'a1',
        playerB: 'a2',
        startTime: now.subtract(const Duration(minutes: 34)),
        status: MatchStatus.live,
        sets: [MatchSet(21, 18), MatchSet(11, 13)],
      ),
      LiveMatch(
        id: 'm2',
        tournament: tour,
        category: 'Tek Kadınlar · Yarı Final',
        court: 'Kort 2',
        playerA: 'a4',
        playerB: 'a7',
        startTime: now.subtract(const Duration(minutes: 12)),
        status: MatchStatus.live,
        sets: [MatchSet(9, 7)],
      ),
      LiveMatch(
        id: 'm3',
        tournament: tour,
        category: 'Tek Kadınlar · Yarı Final',
        court: 'Kort 3',
        playerA: 'a3',
        playerB: 'a8',
        // Demo sırasında canlıya geçip "maç başladı" bildirimi üretsin diye.
        startTime: now.add(const Duration(seconds: 40)),
        status: MatchStatus.upcoming,
      ),
      LiveMatch(
        id: 'm4',
        tournament: tour,
        category: 'Tek Erkekler · Klasman Maçı',
        court: 'Kort 1',
        playerA: 'a5',
        playerB: 'a6',
        startTime: DateTime(now.year, now.month, now.day, 18, 30),
        status: MatchStatus.upcoming,
      ),
      LiveMatch(
        id: 'm5',
        tournament: tour,
        category: 'Tek Erkekler · Çeyrek Final',
        court: 'Kort 2',
        playerA: 'a1',
        playerB: 'a5',
        startTime: now.subtract(const Duration(hours: 3)),
        status: MatchStatus.finished,
        sets: [MatchSet(21, 15), MatchSet(19, 21), MatchSet(21, 17)],
      ),
    ];
  }

  static List<NewsItem> news() {
    final t = _today;
    return [
      NewsItem(
        'Milli takım aday kadrosu açıklandı',
        t.subtract(const Duration(days: 1)),
        'Duyuru',
      ),
      NewsItem(
        'Hakem vizesi işlemleri başladı',
        t.subtract(const Duration(days: 3)),
        'Hakem',
      ),
      NewsItem(
        'Ankara Açık Turnuvası kura çekimi tamamlandı',
        t.subtract(const Duration(days: 4)),
        'Müsabaka',
      ),
    ];
  }

  static List<FeedPost> feed() {
    final now = DateTime.now();
    return [
      FeedPost(
        athleteId: 'a3',
        text: 'Çeyrek finalde 2-0 kazanarak yarı finale yükseldi.',
        time: now.subtract(const Duration(hours: 2)),
        kind: FeedKind.result,
      ),
      FeedPost(
        athleteId: 'a1',
        text: 'Ulusal sıralamada 9. sıradan 7. sıraya yükseldi.',
        time: now.subtract(const Duration(hours: 5)),
        kind: FeedKind.milestone,
      ),
      FeedPost(
        clubId: 'c2',
        text:
            'Yeni sezon antrenman programı yayınlandı. Salı ve perşembe '
            'akşamları gençler grubu için ek kort saatleri açıldı.',
        time: now.subtract(const Duration(hours: 9)),
        kind: FeedKind.club,
      ),
      FeedPost(
        clubId: 'c1',
        text:
            "Ankara Açık Turnuvası'nda yarı finale 1 sporcumuzla yükseldik. "
            'Maçı kulüp lokalinde birlikte izliyoruz.',
        time: now.subtract(const Duration(hours: 1)),
        kind: FeedKind.club,
      ),
      FeedPost(
        clubId: 'c3',
        text: 'Elif Yıldız milli takım aday kadrosuna çağrıldı. Tebrikler!',
        time: now.subtract(const Duration(hours: 20)),
        kind: FeedKind.club,
      ),
      FeedPost(
        clubId: 'c5',
        text: 'Kulübümüz 7-12 yaş için yeni badminton okulu kayıtlarını başlattı.',
        time: now.subtract(const Duration(days: 2)),
        kind: FeedKind.club,
      ),
      FeedPost(
        athleteId: 'a4',
        text: 'Sri Lanka International Series kadrosuna seçildi.',
        time: now.subtract(const Duration(days: 1, hours: 2)),
        kind: FeedKind.news,
      ),
    ];
  }

  static List<TrainingEntry> training() {
    final t = _today;
    return [
      TrainingEntry(t.subtract(const Duration(days: 1)), 'Kort', 90),
      TrainingEntry(t.subtract(const Duration(days: 2)), 'Kondisyon', 45),
      TrainingEntry(t.subtract(const Duration(days: 3)), 'Kort', 75),
      TrainingEntry(t.subtract(const Duration(days: 5)), 'Esneklik', 30),
    ];
  }

  static const badges = <BadgeDef>[
    BadgeDef(
      'first_log',
      'İlk Adım',
      'İlk antrenmanını kaydet',
      Icons.directions_run,
    ),
    BadgeDef(
      'streak3',
      '3 Günlük Seri',
      '3 gün üst üste antrenman kaydet',
      Icons.local_fire_department,
    ),
    BadgeDef(
      'streak7',
      'Haftanın Sporcusu',
      '7 gün üst üste antrenman kaydet',
      Icons.whatshot,
    ),
    BadgeDef(
      'follower',
      'Taraftar',
      'En az 3 sporcuyu takip et',
      Icons.favorite,
    ),
    BadgeDef('live_fan', 'Canlı Takipçi', '3 canlı maçı izle', Icons.live_tv),
    BadgeDef(
      'planner',
      'Planlı Sporcu',
      '2 turnuva için hatırlatma kur',
      Icons.event_available,
    ),
    BadgeDef(
      'club_fan',
      'Kulüp Taraftarı',
      'Bir kulübü takip et',
      Icons.shield,
    ),
    BadgeDef(
      'applicant',
      'Sahaya Hazır',
      'İlk turnuva başvurunu yap',
      Icons.how_to_reg,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Ölçümleme ekranı için örnek kullanım verisi. Gerçek değerler analitik
  // servisinden (ör. Firebase Analytics) gelir; buradaki sayılar önerilerin
  // yayına alınmasından sonraki olası etkiyi göstermek için uydurulmuştur.

  /// Önerilerin yayına alındığı varsayılan gün (30 günlük serinin indeksi).
  static const releaseDay = 15;

  /// Son 30 günün günlük aktif kullanıcı (DAU) sayıları, eskiden yeniye.
  static const dailyActive = <int>[
    432,
    418,
    455,
    447,
    470,
    362,
    341,
    440,
    428,
    461,
    452,
    476,
    355,
    338,
    449,
    512,
    548,
    571,
    596,
    603,
    498,
    486,
    627,
    641,
    668,
    659,
    684,
    571,
    559,
    702,
  ];

  /// Aylık aktif kullanıcı (MAU): yayından önce ve sonra.
  static const monthlyActiveBefore = 3180;
  static const monthlyActiveAfter = 3350;

  /// Push bildirim açılma oranı (%): yayından önce ve sonra.
  static const pushOpenBefore = 4.1;
  static const pushOpenAfter = 11.8;

  /// Kullanıcı başına haftalık ortalama açılma sayısı.
  static const weeklyOpensFollowing = 6.2;
  static const weeklyOpensNotFollowing = 1.7;
}
