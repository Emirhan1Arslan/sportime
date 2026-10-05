import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../widgets.dart';

/// Sporcular ve kulüpler: arama + tek dokunuşla takip.
class AthletesScreen extends StatefulWidget {
  const AthletesScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<AthletesScreen> createState() => _AthletesScreenState();
}

class _AthletesScreenState extends State<AthletesScreen> {
  String _query = '';

  bool _matches(List<String> fields) {
    final q = _query.toLowerCase();
    return q.isEmpty || fields.any((f) => f.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final athletes =
        state.athletes.where((a) => _matches([a.name, a.city, a.club])).toList()
          ..sort((a, b) => a.ranking.compareTo(b.ranking));
    // Takip edilen kulüpler listenin başında.
    final clubs = state.clubs.where((c) => _matches([c.name, c.city])).toList()
      ..sort((a, b) {
        final fa = state.followedClubs.contains(a.id) ? 0 : 1;
        final fb = state.followedClubs.contains(b.id) ? 0 : 1;
        return fa.compareTo(fb);
      });
    return DefaultTabController(
      length: 2,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Keşfet'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(112),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Sporcu, kulüp veya şehir ara',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const TabBar(
                  tabs: [
                    Tab(text: 'Sporcular'),
                    Tab(text: 'Kulüpler'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _List(
              hint:
                  '${state.followed.length} sporcu takip ediyorsun. Maçları '
                  've sonuçları anasayfanda ve bildirimlerinde görünür.',
              children: [
                for (final a in athletes)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    onTap: () => openAthlete(context, a.id),
                    leading: AthleteAvatar(a, radius: 22),
                    title: Text(
                      a.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '#${a.ranking} · ${a.category}\n${a.club}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: FollowButton(a.id, compact: true),
                  ),
              ],
            ),
            _List(
              hint:
                  '${state.followedClubs.length} kulüp takip ediyorsun. '
                  'Duyuruları anasayfanda görünür; kulüp sporcularının maç '
                  'sonuçları için bildirim alırsın.',
              children: [for (final c in clubs) _ClubTile(c)],
            ),
          ],
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.hint, required this.children});

  final String hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(hint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 12),
        if (children.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('Sonuç bulunamadı.')),
          )
        else
          Card(
            child: Column(
              children: [
                for (final (i, w) in children.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 72),
                  w,
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _ClubTile extends StatelessWidget {
  const _ClubTile(this.club);

  final Club club;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final count = state.athletesOf(club).length;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: () => openClub(context, club.id),
      leading: ClubAvatar(club, radius: 22),
      title: Text(
        club.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${club.city} · Kuruluş ${club.founded}\n$count lisanslı sporcu',
        maxLines: 2,
      ),
      isThreeLine: true,
      trailing: FollowButton.club(club.id, compact: true),
    );
  }
}
