import 'package:flutter/material.dart';

import '../app_state.dart';
import '../format.dart';
import '../main.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Anasayfa: her açılışta farklı içerik gösteren "Bugün" odaklı ekran.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPORTIME'),
        actions: [
          IconButton(
            tooltip: 'Bildirimler',
            onPressed: () => openNotifications(context),
            icon: Badge(
              isLabelVisible: state.unreadCount > 0,
              label: Text('${state.unreadCount}'),
              child: const Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Bugün · ${longDate(DateTime.now())}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          const _TodayMatches(),
          const _DeadlineCard(),
          const _StreakCard(),
          SectionHeader(
            'Takip ettiklerin',
            action: 'Sporcu bul',
            onAction: () => HomeShell.of(context).goTo(3),
          ),
          const _Feed(),
          const SectionHeader('Federasyon duyuruları'),
          const _News(),
        ],
      ),
    );
  }
}

class _TodayMatches extends StatelessWidget {
  const _TodayMatches();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final matches = state.todayMatches;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          'Bugünün maçları',
          action: 'Tümü',
          onAction: () => HomeShell.of(context).goTo(1),
        ),
        if (matches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Bugün planlanmış maç yok.'),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: matches.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _TodayMatchCard(matches[i]),
            ),
          ),
      ],
    );
  }
}

class _TodayMatchCard extends StatelessWidget {
  const _TodayMatchCard(this.m);

  final LiveMatch m;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final live = m.status == MatchStatus.live;
    Widget player(String id, int score) {
      final a = state.athlete(id);
      return Row(
        children: [
          AthleteAvatar(a, radius: 12),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              a.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          if (live)
            Text(
              '$score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
        ],
      );
    }

    return SizedBox(
      width: 250,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: live
              ? const BorderSide(color: brandRed, width: 1.5)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => openMatch(context, m),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (live)
                      const LiveBadge()
                    else
                      Text(
                        hm(m.startTime),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: brandRed,
                        ),
                      ),
                    const Spacer(),
                    Text(
                      live ? '${m.sets.length}. set' : m.court,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const Spacer(),
                player(m.playerA, m.current.a),
                const SizedBox(height: 8),
                player(m.playerB, m.current.b),
                const Spacer(),
                Text(
                  m.category,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// En yakın son başvuru tarihi: kullanıcıyı harekete geçiren hatırlatma kartı.
class _DeadlineCard extends StatelessWidget {
  const _DeadlineCard();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = state.nextDeadline;
    if (t == null) return const SizedBox.shrink();
    final applied = state.applied.contains(t.id);
    final reminded = state.reminders.contains(t.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [brandRed, brandRedDark]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.alarm, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      deadlineLabel(daysUntil(t.deadline)).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${t.location} · ${shortDayMonth(t.start)} – '
                '${shortDayMonth(t.end)}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: brandRed,
                      ),
                      onPressed: applied ? null : () => state.apply(t.id),
                      child: Text(applied ? 'Başvuru yapıldı' : 'Başvuru Yap'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: reminded ? 'Hatırlatmayı kapat' : 'Hatırlat',
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white54),
                    ),
                    onPressed: applied
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
            ],
          ),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final streak = state.trainingStreak;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: ListTile(
          onTap: () => HomeShell.of(context).goTo(4),
          leading: CircleAvatar(
            backgroundColor: Colors.orange.shade50,
            child: Icon(
              Icons.local_fire_department,
              color: Colors.orange.shade700,
            ),
          ),
          title: Text(
            '$streak günlük antrenman serisi',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            state.trainedToday
                ? 'Bugünkü antrenmanını kaydettin.'
                : 'Seriyi sürdürmek için bugünkü antrenmanını kaydet.',
          ),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}

class _Feed extends StatelessWidget {
  const _Feed();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final posts = state.feed.take(5).toList();
    if (posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.person_search, size: 36),
                const SizedBox(height: 8),
                const Text(
                  'Henüz kimseyi takip etmiyorsun. Sporcuları ve kulüpleri '
                  'takip et, sonuçları ve duyuruları burada gör.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => HomeShell.of(context).goTo(3),
                  child: const Text('Keşfet'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Column(
          children: [
            for (final (i, p) in posts.indexed) ...[
              if (i > 0) const Divider(height: 1, indent: 68),
              FeedTile(p),
            ],
          ],
        ),
      ),
    );
  }
}

class _News extends StatelessWidget {
  const _News();

  @override
  Widget build(BuildContext context) {
    final news = AppScope.of(context).news;
    return SizedBox(
      height: 118,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: news.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final n = news[i];
          return SizedBox(
            width: 230,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.tag.toUpperCase(),
                      style: const TextStyle(
                        color: brandRed,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        n.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      dayMonth(n.date),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
