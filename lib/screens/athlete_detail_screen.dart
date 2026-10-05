import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Sporcu profili: kişisel istatistik paneli (sıralama grafiği, form, oranlar).
class AthleteDetailScreen extends StatelessWidget {
  const AthleteDetailScreen({super.key, required this.athleteId});

  final String athleteId;

  @override
  Widget build(BuildContext context) {
    final a = AppScope.of(context).athlete(athleteId);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandRed,
        foregroundColor: Colors.white,
        title: Text(
          a.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Header(a),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AthleteStats(a),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.a);

  final Athlete a;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: brandRed,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Row(
        children: [
          AthleteAvatar(a, radius: 34),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.club,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${a.city} · ${a.category}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme
                        .copyWith(primary: Colors.white, onPrimary: brandRed),
                    outlinedButtonTheme: OutlinedButtonThemeData(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                  ),
                  child: FollowButton(a.id, compact: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Profilim sekmesinde de kullanılan istatistik bloğu.
class AthleteStats extends StatelessWidget {
  const AthleteStats(this.a, {super.key});

  final Athlete a;

  @override
  Widget build(BuildContext context) {
    final first = a.rankingHistory.first;
    final change = first - a.ranking;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                'Ulusal sıra',
                '#${a.ranking}',
                change > 0 ? '▲ $change basamak' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                'Galibiyet',
                '${(a.winRate * 100).round()}%',
                '${a.wins}G · ${a.losses}M',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sıralama değişimi (son 8 ay)',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 160,
                  child: Semantics(
                    label:
                        'Sıralama grafiği: ${a.rankingHistory.first}. '
                        'sıradan ${a.ranking}. sıraya',
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: RankingChartPainter(
                        a.rankingHistory,
                        labelColor: Colors.grey.shade600,
                        gridColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Son 5 maç',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final w in a.form)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: w ? winGreen : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      w ? 'G' : 'M',
                      semanticsLabel: w ? 'Galibiyet' : 'Mağlubiyet',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.sub);

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            if (sub != null)
              Text(
                sub!,
                style: TextStyle(
                  color: sub!.startsWith('▲') ? winGreen : Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sıralama çizgi grafiği. Sıralamada küçük sayı daha iyi olduğu için y ekseni
/// ters çevrilir: yükselen çizgi = iyileşme.
class RankingChartPainter extends CustomPainter {
  RankingChartPainter(
    this.values, {
    required this.labelColor,
    required this.gridColor,
  });

  final List<int> values;
  final Color labelColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0, bottom = 20.0, top = 8.0, right = 12.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    final best = values.reduce((a, b) => a < b ? a : b);
    final worst = values.reduce((a, b) => a > b ? a : b);
    final lo = (best - 1).clamp(1, 999);
    final hi = worst + 1;

    double y(int rank) => top + (rank - lo) / (hi - lo) * h;
    double x(int i) => left + i / (values.length - 1) * w;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    TextPainter label(String s) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: labelColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Yatay kılavuz çizgileri ve y ekseni etiketleri (sıra numaraları).
    for (final r in {lo, ((lo + hi) / 2).round(), hi}) {
      canvas.drawLine(Offset(left, y(r)), Offset(left + w, y(r)), grid);
      final tp = label('#$r');
      tp.paint(canvas, Offset(0, y(r) - tp.height / 2));
    }

    // X ekseni: ay kısaltmaları, son nokta içinde bulunulan ay.
    final now = DateTime.now();
    for (var i = 0; i < values.length; i++) {
      final month = now.month - (values.length - 1 - i);
      final tp = label(shortMonth((month - 1) % 12 + 1));
      tp.paint(canvas, Offset(x(i) - tp.width / 2, size.height - tp.height));
    }

    final path = Path()..moveTo(x(0), y(values[0]));
    for (var i = 1; i < values.length; i++) {
      path.lineTo(x(i), y(values[i]));
    }
    final area = Path.from(path)
      ..lineTo(x(values.length - 1), top + h)
      ..lineTo(x(0), top + h)
      ..close();
    canvas.drawPath(
      area,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brandRed.withValues(alpha: 0.25),
            brandRed.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = brandRed
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final end = Offset(x(values.length - 1), y(values.last));
    canvas.drawCircle(end, 5, Paint()..color = Colors.white);
    canvas.drawCircle(
      end,
      5,
      Paint()
        ..color = brandRed
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(RankingChartPainter old) => old.values != values;
}
