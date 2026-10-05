import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Canlı skor ekranı: set skorları ve son sayıların akışı anlık güncellenir.
class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final m = state.matches.firstWhere((x) => x.id == matchId);
    final a = state.athlete(m.playerA), b = state.athlete(m.playerB);
    return Scaffold(
      appBar: AppBar(title: Text(m.tournament)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Dar ekranda etiket ve kategori alt alta kayar.
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (m.status == MatchStatus.live) const LiveBadge(),
                      Text(
                        '${m.category} · ${m.court}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _Side(a, won: m.winner == a.id)),
                      // Skor, yer kalmazsa taşmak yerine küçülür.
                      Expanded(
                        flex: 3,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: _BigScore(m),
                        ),
                      ),
                      Expanded(flex: 3, child: _Side(b, won: m.winner == b.id)),
                    ],
                  ),
                  if (m.status == MatchStatus.upcoming) ...[
                    const SizedBox(height: 16),
                    Text('Maç saat ${hm(m.startTime)} başlayacak.'),
                  ],
                ],
              ),
            ),
          ),
          if (m.status != MatchStatus.upcoming) ...[
            const SectionHeader('Set skorları'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (final (i, s) in m.sets.indexed)
                      _SetRow(
                        i + 1,
                        s,
                        current: !s.isOver && m.status == MatchStatus.live,
                      ),
                  ],
                ),
              ),
            ),
          ],
          if (m.lastPoints.isNotEmpty) ...[
            const SectionHeader('Son sayılar'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final toA in m.lastPoints)
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: toA
                                ? brandRed
                                : Colors.blueGrey.shade400,
                            child: Text(
                              toA ? a.initials : b.initials,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Soldan sağa, en yeni sağda.',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side(this.athlete, {required this.won});

  final Athlete athlete;
  final bool won;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openAthlete(context, athlete.id),
      child: Column(
        children: [
          AthleteAvatar(athlete, radius: 28),
          const SizedBox(height: 8),
          Text(
            athlete.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: won ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            '#${athlete.ranking} · ${athlete.city}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: 8),
          // Dar ekranda buton yazısı bölünmesin diye küçülür.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: FollowButton(athlete.id, compact: true),
          ),
        ],
      ),
    );
  }
}

class _BigScore extends StatelessWidget {
  const _BigScore(this.m);

  final LiveMatch m;

  @override
  Widget build(BuildContext context) {
    const big = TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w800,
      fontFeatures: [FontFeature.tabularFigures()],
    );
    final live = m.status == MatchStatus.live;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            live
                ? '${m.current.a} - ${m.current.b}'
                : '${m.setsA} - ${m.setsB}',
            style: big.copyWith(color: live ? brandRed : null),
            semanticsLabel: live
                ? 'Sayı ${m.current.a} ${m.current.b}'
                : 'Set ${m.setsA} ${m.setsB}',
          ),
          Text(
            live ? 'Setler ${m.setsA} - ${m.setsB}' : 'Setler',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow(this.no, this.s, {required this.current});

  final int no;
  final MatchSet s;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final total = (s.a + s.b).clamp(1, 60);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              '$no. set',
              style: TextStyle(
                fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                color: current ? brandRed : null,
              ),
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${s.a}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: s.a > s.b ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: s.a.clamp(1, 60),
                      child: const ColoredBox(color: brandRed),
                    ),
                    Expanded(
                      flex: (total - s.a).clamp(1, 60),
                      child: ColoredBox(color: Colors.blueGrey.shade300),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 28,
            child: Text(
              '${s.b}',
              style: TextStyle(
                fontWeight: s.b > s.a ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
