import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';

/// Canlı, yaklaşan ve biten maçlar.
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maçlar'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Canlı (${state.liveMatches.length})'),
              const Tab(text: 'Yaklaşan'),
              const Tab(text: 'Biten'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MatchList(state.liveMatches, empty: 'Şu anda canlı maç yok.'),
            _MatchList(state.upcomingMatches, empty: 'Yaklaşan maç yok.'),
            _MatchList(state.finishedMatches, empty: 'Henüz biten maç yok.'),
          ],
        ),
      ),
    );
  }
}

class _MatchList extends StatelessWidget {
  const _MatchList(this.matches, {required this.empty});

  final List<LiveMatch> matches;
  final String empty;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) return Center(child: Text(empty));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => MatchTile(matches[i]),
    );
  }
}
