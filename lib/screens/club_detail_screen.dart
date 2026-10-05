import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Kulüp sayfası: takip, kulübün sporcuları ve kulüp duyuruları.
class ClubDetailScreen extends StatelessWidget {
  const ClubDetailScreen({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final club = state.club(clubId);
    final athletes = state.athletesOf(club);
    final posts = state.postsOf(club);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        title: const Text(
          'Kulüp',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Container(
            color: brandRed,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Semantics(
                    label: '${club.name} logosu',
                    child: const Icon(Icons.shield, size: 36, color: brandRed),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${club.city} · Kuruluş ${club.founded}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      _OnRed(child: FollowButton.club(club.id, compact: true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SectionHeader('Kulüp duyuruları (${posts.length})'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: posts.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Kulüp henüz duyuru paylaşmadı.'),
                    )
                  : Column(
                      children: [
                        for (final (i, p) in posts.indexed) ...[
                          if (i > 0) const Divider(height: 1, indent: 68),
                          FeedTile(p),
                        ],
                      ],
                    ),
            ),
          ),
          SectionHeader('Sporcular (${athletes.length})'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  for (final (i, a) in athletes.indexed) ...[
                    if (i > 0) const Divider(height: 1, indent: 68),
                    _AthleteRow(a),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AthleteRow extends StatelessWidget {
  const _AthleteRow(this.a);

  final Athlete a;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => openAthlete(context, a.id),
      leading: AthleteAvatar(a),
      title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('#${a.ranking} · ${a.category}'),
      trailing: FollowButton(a.id, compact: true),
    );
  }
}

/// Kırmızı zemin üzerinde okunabilir beyaz takip butonu.
class _OnRed extends StatelessWidget {
  const _OnRed({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.white,
          onPrimary: brandRed,
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white70),
          ),
        ),
      ),
      child: child,
    );
  }
}
