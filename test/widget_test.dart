import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportime_demo/app_state.dart';
import 'package:sportime_demo/main.dart';
import 'package:sportime_demo/models.dart';
import 'package:sportime_demo/screens/home_screen.dart';
import 'package:sportime_demo/screens/profile_screen.dart';

/// Ekranın dikey ListView'ı (yatay listeler de Scrollable olduğu için ilk
/// eşleşme alınır; ağaçta dikey liste onların atasıdır).
Finder _scrollableOf(Finder screen) =>
    find.descendant(of: screen, matching: find.byType(Scrollable)).first;

void main() {
  testWidgets('anasayfa "Bugün" bloğunu ve takip akışını gösterir', (
    tester,
  ) async {
    final state = AppState(simulate: false);
    await tester.pumpWidget(SportimeApp(state: state));

    expect(find.text('Bugünün maçları'), findsOneWidget);
    expect(find.text('Elif Yıldız'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Takip ettiklerin'),
      300,
      scrollable: _scrollableOf(find.byType(HomeScreen)),
    );
    expect(find.text('Takip ettiklerin'), findsOneWidget);
  });

  testWidgets('sekmeler arasında gezinilebilir', (tester) async {
    await tester.pumpWidget(SportimeApp(state: AppState(simulate: false)));

    for (final tab in ['Maçlar', 'Müsabakalar', 'Keşfet', 'Profilim']) {
      await tester.tap(find.text(tab).last);
      // "CANLI" etiketi sürekli animasyonlu olduğu için pumpAndSettle bitmez.
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.scrollUntilVisible(
      find.text('Antrenman günlüğü'),
      300,
      scrollable: _scrollableOf(find.byType(ProfileScreen)),
    );
    expect(find.text('Antrenman günlüğü'), findsOneWidget);
  });

  test('takip edilmeyen sporcu akışta görünmez, takip edilince görünür', () {
    final state = AppState(simulate: false);
    expect(state.feed.any((p) => p.athleteId == 'a4'), isFalse);
    state.toggleFollow('a4');
    expect(state.feed.any((p) => p.athleteId == 'a4'), isTrue);
  });

  test('3 sporcu takip edilince rozet kazanılır ve bildirim gelir', () {
    final state = AppState(simulate: false);
    expect(state.earnedBadges.contains('follower'), isFalse);
    state.toggleFollow('a2');
    expect(state.earnedBadges.contains('follower'), isTrue);
    expect(state.notices.first.kind, NoticeKind.badge);
  });

  test('badminton set kuralları: 21 ve 2 sayı fark, 30 tavan', () {
    expect(MatchSet(21, 19).isOver, isTrue);
    expect(MatchSet(21, 20).isOver, isFalse);
    expect(MatchSet(29, 28).isOver, isFalse);
    expect(MatchSet(30, 29).isOver, isTrue);
  });

  test('kademeli hatırlatma bugünkü son başvuru için bildirim üretir', () {
    final state = AppState(simulate: false);
    // t1'in son başvurusu bugün ve varsayılan olarak hatırlatması açık.
    expect(state.sendDueReminders(), 1);
    state.setReminderStep(0, false);
    expect(state.sendDueReminders(), 0);
  });

  test('antrenman eklenince seri bugüne uzar', () {
    final state = AppState(simulate: false);
    final before = state.trainingStreak;
    state.addTraining(TrainingEntry(DateTime.now(), 'Kort', 60));
    expect(state.trainingStreak, before + 1);
    expect(state.trainedToday, isTrue);
  });

  test('kulüp takip edilince kulüp duyuruları akışa girer', () {
    final state = AppState(simulate: false);
    expect(state.feed.any((p) => p.clubId == 'c2'), isFalse);
    state.toggleFollowClub('c2');
    expect(state.feed.any((p) => p.clubId == 'c2'), isTrue);
    state.toggleFollowClub('c2');
    expect(state.feed.any((p) => p.clubId == 'c2'), isFalse);
  });

  test('bildirimler ekranı açılınca okunmamışlar açılmış sayılır', () {
    final state = AppState(simulate: false);
    state.sendDueReminders();
    expect(state.noticesShown, 1);
    expect(state.unreadCount, 1);
    state.openNotices();
    expect(state.noticesOpened, 1);
    expect(state.unreadCount, 0);
  });
}
