import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'screens/athletes_screen.dart';
import 'screens/home_screen.dart';
import 'screens/matches_screen.dart';
import 'screens/metrics_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/tournaments_screen.dart';
import 'theme.dart';
import 'widgets.dart';

void main() => runApp(SportimeApp(state: AppState()));

class SportimeApp extends StatelessWidget {
  const SportimeApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'SPORTIME Demo',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const HomeShell(),
      ),
    );
  }
}

/// Alt navigasyonlu ana iskelet. Rapordaki öneri doğrultusunda Anasayfa ilk
/// sekmede; "Dahası" yerine kişisel "Profilim" sekmesi var.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static HomeShellState of(BuildContext context) =>
      context.findAncestorStateOfType<HomeShellState>()!;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  // Web demosunda belirli bir sekmeyle açmak için: ?tab=0..4
  int _index = (int.tryParse(Uri.base.queryParameters['tab'] ?? '') ?? 0).clamp(
    0,
    4,
  );
  StreamSubscription<AppNotice>? _sub;
  static final _subTab =
      (int.tryParse(Uri.base.queryParameters['sub'] ?? '') ?? 0).clamp(0, 1);

  static const _tabNames = [
    'Anasayfa',
    'Maçlar',
    'Müsabakalar',
    'Keşfet',
    'Profilim',
  ];

  void goTo(int index) {
    AppScope.read(context).logView(_tabNames[index]);
    setState(() => _index = index);
  }

  @override
  void initState() {
    super.initState();
    final link = Uri.base.queryParameters['screen'];
    if (link != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openLink(link));
    }
  }

  /// Web demosunda detay ekranını doğrudan açar, ör. ?screen=match:m1
  /// (sunum ve ekran görüntüsü almak için).
  void _openLink(String link) {
    final state = AppScope.read(context);
    final [name, ...rest] = link.split(':');
    final id = rest.firstOrNull ?? '';
    switch (name) {
      case 'match':
        openMatch(context, state.matches.firstWhere((m) => m.id == id));
      case 'athlete':
        openAthlete(context, id);
      case 'club':
        openClub(context, id);
      case 'notifications':
        state.sendDueReminders();
        openNotifications(context);
      case 'metrics':
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MetricsScreen()));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sub ??= AppScope.read(context).incoming.listen(_showNotice);
  }

  /// Push bildirimi simülasyonu: yeni bildirim ekranın altında belirir.
  void _showNotice(AppNotice n) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(n.icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'Gör',
          onPressed: () => openNotifications(context),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = AppScope.of(context).liveMatches.length;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomeScreen(),
          const MatchesScreen(),
          const TournamentsScreen(),
          AthletesScreen(initialTab: _subTab),
          const ProfileScreen(),
        ],
      ),
      // 360 pikselden dar ekranlarda "Müsabakalar" etiketi iki satıra
      // bölünmesin diye etiket yazısı küçültülür.
      bottomNavigationBar: NavigationBarTheme(
        data: MediaQuery.sizeOf(context).width < 360
            ? NavigationBarTheme.of(context).copyWith(
                labelTextStyle: WidgetStatePropertyAll(
                  const TextStyle(
                    fontSize: 10,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
              )
            : NavigationBarTheme.of(context),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: goTo,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Anasayfa',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: live > 0,
                label: Text('$live'),
                child: const Icon(Icons.sports_tennis_outlined),
              ),
              selectedIcon: const Icon(Icons.sports_tennis),
              label: 'Maçlar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.emoji_events_outlined),
              selectedIcon: Icon(Icons.emoji_events),
              label: 'Müsabakalar',
            ),
            const NavigationDestination(
              icon: Icon(Icons.travel_explore_outlined),
              selectedIcon: Icon(Icons.travel_explore),
              label: 'Keşfet',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profilim',
            ),
          ],
        ),
      ),
    );
  }
}
