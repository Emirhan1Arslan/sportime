import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../mock_data.dart';
import '../theme.dart';
import '../widgets.dart';

/// Raporun "Ölçümleme Önerisi" bölümündeki metriklerin yönetici görünümü.
/// Üst kısım örnek kullanıcı verisidir; alt kısım bu cihazda gerçekten
/// toplanan olay sayaçlarını gösterir.
class MetricsScreen extends StatelessWidget {
  const MetricsScreen({super.key});

  static double _avg(Iterable<int> xs) =>
      xs.fold(0, (a, b) => a + b) / xs.length;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    const dau = MockData.dailyActive;
    const release = MockData.releaseDay;
    final before = _avg(dau.take(release));
    final after = _avg(dau.skip(release));
    final stickBefore = before / MockData.monthlyActiveBefore * 100;
    final stickAfter = after / MockData.monthlyActiveAfter * 100;
    final openRate = state.noticesShown == 0
        ? 0
        : (state.noticesOpened / state.noticesShown * 100).round();
    final views = state.screenViews.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanım Ölçümleri')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: warnAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: warnAmber),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Yönetici görünümü. Üstteki grafikler örnek veridir; '
                    'gerçek değerler analitik servisinden gelir.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Kpi(
                  label: 'DAU/MAU oranı',
                  value: '%${stickAfter.toStringAsFixed(0)}',
                  delta: 'önce %${stickBefore.toStringAsFixed(0)} · hedef %20',
                  good: stickAfter >= 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Kpi(
                  label: 'Bildirim açılma',
                  value: '%${MockData.pushOpenAfter}',
                  delta: 'önce %${MockData.pushOpenBefore}',
                  good: true,
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
                    'Günlük aktif kullanıcı (son 30 gün)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    'Ortalama ${before.round()} → ${after.round()} kişi',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: Semantics(
                      label:
                          'Günlük aktif kullanıcı grafiği: ortalama '
                          '${before.round()} kişiden ${after.round()} kişiye',
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _DauChartPainter(
                          dau,
                          releaseIndex: release,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Haftalık ortalama açılma',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _Bar(
                    'Sporcu/kulüp takip edenler',
                    MockData.weeklyOpensFollowing,
                    max: MockData.weeklyOpensFollowing,
                    color: brandRed,
                  ),
                  const SizedBox(height: 10),
                  _Bar(
                    'Takip etmeyenler',
                    MockData.weeklyOpensNotFollowing,
                    max: MockData.weeklyOpensFollowing,
                    color: Colors.blueGrey.shade300,
                  ),
                ],
              ),
            ),
          ),
          const SectionHeader('Bu cihazdaki oturum (gerçek sayaçlar)'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Row('Oturum başlangıcı', hm(state.sessionStart)),
                  _Row('Gösterilen bildirim', '${state.noticesShown}'),
                  _Row(
                    'Açılan bildirim',
                    '${state.noticesOpened} (%$openRate)',
                  ),
                  _Row('İzlenen maç', '${state.matchViews}'),
                  _Row(
                    'Takip edilen',
                    '${state.followed.length} sporcu, '
                        '${state.followedClubs.length} kulüp',
                  ),
                  const Divider(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Ekran görüntülemeleri',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (views.isEmpty)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Henüz kayıt yok.'),
                    ),
                  for (final e in views.take(6)) _Row(e.key, '${e.value}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.label,
    required this.value,
    required this.delta,
    required this.good,
  });

  final String label;
  final String value;
  final String delta;
  final bool good;

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
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  good ? Icons.trending_up : Icons.trending_flat,
                  color: good ? winGreen : warnAmber,
                ),
              ],
            ),
            Text(
              delta,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar(this.label, this.value, {required this.max, required this.color});

  final String label;
  final double value;
  final double max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text(
              '${value.toStringAsFixed(1)} kez',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / max,
            minHeight: 10,
            color: color,
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// 30 günlük DAU çizgisi; yayın günü kesikli dikey çizgiyle işaretlenir.
class _DauChartPainter extends CustomPainter {
  _DauChartPainter(
    this.values, {
    required this.releaseIndex,
    required this.labelColor,
    required this.gridColor,
  });

  final List<int> values;
  final int releaseIndex;
  final Color labelColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 30.0, bottom = 18.0, top = 16.0, right = 8.0;
    final w = size.width - left - right;
    final h = size.height - top - bottom;
    const lo = 300, hi = 750;
    double x(num i) => left + i / (values.length - 1) * w;
    double y(num v) => top + (1 - (v - lo) / (hi - lo)) * h;

    TextPainter label(String s, {Color? color}) => TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(color: color ?? labelColor, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (final v in [300, 450, 600, 750]) {
      canvas.drawLine(Offset(left, y(v)), Offset(left + w, y(v)), grid);
      final tp = label('$v');
      tp.paint(canvas, Offset(0, y(v) - tp.height / 2));
    }
    for (final (i, text) in [(0, '30 gün önce'), (29, 'Bugün')]) {
      final tp = label(text);
      final dx = i == 0 ? x(i) : x(i) - tp.width;
      tp.paint(canvas, Offset(dx, size.height - tp.height));
    }

    // Yayın günü işareti.
    final rx = x(releaseIndex - 0.5);
    final dash = Paint()
      ..color = brandRed.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    for (var yy = top; yy < top + h; yy += 6) {
      canvas.drawLine(Offset(rx, yy), Offset(rx, yy + 3), dash);
    }
    label(
      'Yeni özellikler',
      color: brandRed,
    ).paint(canvas, Offset(rx + 4, top - 14));

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
            brandRed.withValues(alpha: 0.22),
            brandRed.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(left, top, w, h)),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = brandRed
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final end = Offset(x(values.length - 1), y(values.last));
    canvas.drawCircle(end, 4, Paint()..color = brandRed);
  }

  @override
  bool shouldRepaint(_DauChartPainter old) => old.values != values;
}
