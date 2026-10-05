import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Müsabaka takvimi + kademeli başvuru hatırlatmaları.
class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final list = [...state.tournaments]
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
    return Scaffold(
      appBar: AppBar(title: const Text('Müsabakalar')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const _ReminderInfo(),
          const SizedBox(height: 16),
          for (final t in list) ...[
            _TournamentCard(t),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ReminderInfo extends StatelessWidget {
  const _ReminderInfo();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final steps = state.reminderSteps.entries
        .where((e) => e.value)
        .map((e) => e.key == 0 ? 'son gün' : '${e.key} gün kala')
        .join(', ');
    return Card(
      color: brandRed.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.notifications_active, color: brandRed),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Kademeli hatırlatma',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Zil simgesini açtığın müsabakalar için son başvuru tarihine '
              '${steps.isEmpty ? 'hiç' : steps} bildirim alırsın.',
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                final n = state.sendDueReminders();
                if (n == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bugün gönderilecek hatırlatma yok.'),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Hatırlatmaları gönder (demo)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  const _TournamentCard(this.t);

  final Tournament t;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final applied = state.applied.contains(t.id);
    final reminded = state.reminders.contains(t.id);
    final open = daysUntil(t.deadline) >= 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            color: brandRed,
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: reminded ? 'Hatırlatmayı kapat' : 'Hatırlat',
                  color: Colors.white,
                  onPressed: applied || !open
                      ? null
                      : () => state.toggleReminder(t.id),
                  icon: Icon(
                    reminded
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Info(Icons.place_outlined, t.location),
                _Info(
                  Icons.calendar_today_outlined,
                  '${dayMonth(t.start)} – ${dayMonth(t.end)}',
                ),
                _Info(
                  Icons.event_busy_outlined,
                  'Son başvuru: ${dayMonth(t.deadline)}',
                ),
                const SizedBox(height: 8),
                if (applied)
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: winGreen, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Başvurun alındı',
                        style: TextStyle(
                          color: winGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  )
                else
                  DeadlineChip(t.deadline),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: applied || !open
                        ? null
                        : () => state.apply(t.id),
                    child: Text(applied ? 'Başvuru yapıldı' : 'Başvuru Yap'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: brandRed),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
