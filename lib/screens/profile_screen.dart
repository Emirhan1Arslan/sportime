import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../mock_data.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'athlete_detail_screen.dart';
import 'metrics_screen.dart';

/// Profilim: kişisel istatistikler, rozetler, antrenman günlüğü ve bildirim
/// tercihleri. Eski "Dahası" sekmesinin yerini alır.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final me = state.me;
    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTraining(context),
        icon: const Icon(Icons.add),
        label: const Text('Antrenman ekle'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AthleteAvatar(me, radius: 28),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        me.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${me.club} · ${me.category}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AthleteStats(me),
          ),
          const SectionHeader('Antrenman günlüğü'),
          const _TrainingCard(),
          SectionHeader(
            'Rozetler (${state.earnedBadges.length}/${MockData.badges.length})',
          ),
          const _Badges(),
          const SectionHeader('Bildirim tercihleri'),
          const _NotificationPrefs(),
          const SectionHeader('Yönetim'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.insights),
                title: const Text('Kullanım ölçümleri'),
                subtitle: const Text('DAU/MAU, bildirim açılma oranı'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  state.logView('Kullanım ölçümleri');
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MetricsScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addTraining(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddTrainingSheet(),
    );
  }
}

class _TrainingCard extends StatelessWidget {
  const _TrainingCard();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final minutes = state.weeklyMinutes;
    final maxM = minutes.fold(60, (a, b) => a > b ? a : b);
    final total = minutes.fold(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${state.trainingStreak} günlük seri',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    'Bu hafta $total dk',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: _DayBar(
                          day: today.subtract(Duration(days: 6 - i)),
                          minutes: minutes[i],
                          fraction: minutes[i] / maxM,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 28),
              for (final e in state.training.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          shortDayMonth(e.date),
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ),
                      Expanded(child: Text(e.type)),
                      Text(
                        '${e.minutes} dk',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.day,
    required this.minutes,
    required this.fraction,
  });

  final DateTime day;
  final int minutes;
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final isToday = day == today;
    return Semantics(
      label: '${dayMonth(day)}: $minutes dakika',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: minutes == 0 ? 0.04 : fraction.clamp(0.08, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: minutes == 0
                          ? Colors.grey.shade300
                          : (isToday
                                ? brandRed
                                : brandRed.withValues(alpha: 0.55)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              shortWeekday(day),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddTrainingSheet extends StatefulWidget {
  const _AddTrainingSheet();

  @override
  State<_AddTrainingSheet> createState() => _AddTrainingSheetState();
}

class _AddTrainingSheetState extends State<_AddTrainingSheet> {
  static const _types = ['Kort', 'Kondisyon', 'Esneklik', 'Maç'];
  String _type = _types.first;
  double _minutes = 60;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bugünkü antrenman',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              for (final t in _types)
                ChoiceChip(
                  label: Text(t),
                  selected: _type == t,
                  onSelected: (_) => setState(() => _type = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Süre: ${_minutes.round()} dk'),
          Slider(
            value: _minutes,
            min: 15,
            max: 180,
            divisions: 11,
            label: '${_minutes.round()} dk',
            onChanged: (v) => setState(() => _minutes = v),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                AppScope.read(context).addTraining(
                  TrainingEntry(DateTime.now(), _type, _minutes.round()),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Kaydet'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badges extends StatelessWidget {
  const _Badges();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: MockData.badges.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final b = MockData.badges[i];
          final earned = state.earnedBadges.contains(b.id);
          return Tooltip(
            message: b.description,
            child: SizedBox(
              width: 100,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: earned
                            ? Colors.amber.shade100
                            : Colors.grey.shade200,
                        child: Icon(
                          b.icon,
                          color: earned
                              ? Colors.amber.shade800
                              : Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        b.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: earned ? null : Colors.grey.shade500,
                        ),
                      ),
                      if (!earned)
                        Icon(
                          Icons.lock_outline,
                          size: 12,
                          color: Colors.grey.shade400,
                          semanticLabel: 'Kilitli',
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationPrefs extends StatelessWidget {
  const _NotificationPrefs();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    String stepLabel(int d) =>
        d == 0 ? 'Son başvuru günü' : 'Son başvuruya $d gün kala';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          children: [
            for (final d in [3, 1, 0])
              SwitchListTile(
                secondary: const Icon(Icons.alarm),
                title: Text(stepLabel(d)),
                value: state.reminderSteps[d] ?? false,
                onChanged: (v) => state.setReminderStep(d, v),
              ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: const Icon(Icons.sports_tennis),
              title: const Text('Takip ettiğim sporcunun maçı başlayınca'),
              value: state.notifyMatchStart,
              onChanged: state.setNotifyMatchStart,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.emoji_events_outlined),
              title: const Text('Set ve maç sonuçları'),
              value: state.notifyResults,
              onChanged: state.setNotifyResults,
            ),
          ],
        ),
      ),
    );
  }
}
