import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sportime_demo/app_state.dart';
import 'package:sportime_demo/main.dart';
import 'package:sportime_demo/screens/athlete_detail_screen.dart';
import 'package:sportime_demo/screens/club_detail_screen.dart';
import 'package:sportime_demo/screens/match_detail_screen.dart';
import 'package:sportime_demo/screens/metrics_screen.dart';
import 'package:sportime_demo/screens/notifications_screen.dart';
import 'package:sportime_demo/theme.dart';

/// Küçük ekran + büyük yazı tipi (erişilebilirlik) ile her sekmede taşma
/// (RenderFlex overflow) hatası oluşmadığını kontrol eder.
void main() {
  for (final (w, h, scale) in [(320.0, 640.0, 1.3), (390.0, 844.0, 1.0)]) {
    testWidgets('${w.toInt()}x${h.toInt()} ekran, yazı ölçeği $scale', (
      tester,
    ) async {
      tester.view.physicalSize = Size(w, h);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(
            size: Size(w, h),
            textScaler: TextScaler.linear(scale),
          ),
          child: SportimeApp(state: AppState(simulate: false)),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'Anasayfa');

      for (final tab in ['Maçlar', 'Müsabakalar', 'Keşfet', 'Profilim']) {
        await tester.tap(find.text(tab).last);
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull, reason: tab);
      }
    });
  }

  final details = <String, Widget>{
    'Maç detayı': const MatchDetailScreen(matchId: 'm1'),
    'Sporcu detayı': const AthleteDetailScreen(athleteId: 'a3'),
    'Kulüp detayı': const ClubDetailScreen(clubId: 'c1'),
    'Kullanım ölçümleri': const MetricsScreen(),
    'Bildirimler': const NotificationsScreen(),
  };
  for (final MapEntry(key: name, value: screen) in details.entries) {
    testWidgets('$name: 320x640 ekran, yazı ölçeği 1.3', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final state = AppState(simulate: false)..sendDueReminders();
      await tester.pumpWidget(
        AppScope(
          state: state,
          child: MaterialApp(
            theme: buildTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: screen,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: name);
    });
  }
}
