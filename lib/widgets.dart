import 'package:flutter/material.dart';

import 'app_state.dart';
import 'format.dart';
import 'models.dart';
import 'screens/athlete_detail_screen.dart';
import 'screens/club_detail_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/notifications_screen.dart';
import 'theme.dart';

/// Baş harfli sporcu avatarı. Ekran okuyucular için sporcu adını etiketler
/// (rapordaki "alt text" önerisi).
class AthleteAvatar extends StatelessWidget {
  const AthleteAvatar(this.athlete, {super.key, this.radius = 20});

  final Athlete athlete;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final hue = (athlete.id.hashCode % 360).toDouble();
    return Semantics(
      label: '${athlete.name} profil fotoğrafı',
      image: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: HSLColor.fromAHSL(1, hue, 0.35, 0.88).toColor(),
        child: Text(
          athlete.initials,
          style: TextStyle(
            fontSize: radius * 0.75,
            fontWeight: FontWeight.w700,
            color: HSLColor.fromAHSL(1, hue, 0.45, 0.3).toColor(),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    );
  }
}

/// Yanıp sönen "CANLI" etiketi.
class LiveBadge extends StatefulWidget {
  const LiveBadge({super.key});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: liveRed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: _c,
            child: const Icon(Icons.circle, size: 8, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Text(
            'CANLI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sporcu ya da kulüp takip butonu.
class FollowButton extends StatelessWidget {
  const FollowButton(this.id, {super.key, this.compact = false})
    : isClub = false;
  const FollowButton.club(this.id, {super.key, this.compact = false})
    : isClub = true;

  final String id;
  final bool isClub;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final on = isClub
        ? state.followedClubs.contains(id)
        : state.followed.contains(id);
    void toggle() =>
        isClub ? state.toggleFollowClub(id) : state.toggleFollow(id);
    final style = compact
        ? const ButtonStyle(
            visualDensity: VisualDensity.compact,
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12),
            ),
          )
        : null;
    return on
        ? OutlinedButton.icon(
            style: style,
            onPressed: toggle,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Takipte'),
          )
        : FilledButton.icon(
            style: style,
            onPressed: toggle,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Takip et'),
          );
  }
}

/// Son başvuru tarihine göre renklenen etiket (T-0 kırmızı, T-1 turuncu).
class DeadlineChip extends StatelessWidget {
  const DeadlineChip(this.deadline, {super.key});

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final days = daysUntil(deadline);
    final color = days <= 0
        ? liveRed
        : days == 1
        ? warnAmber
        : days <= 3
        ? const Color(0xFFF9A825)
        : Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              deadlineLabel(days),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Detay ekranlarını açan yardımcılar; her açılış ölçümleme için kaydedilir.

void openMatch(BuildContext context, LiveMatch m) {
  final state = AppScope.read(context)..logView('Maç detayı');
  state.watchMatch(m.id);
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => MatchDetailScreen(matchId: m.id)));
}

void openAthlete(BuildContext context, String athleteId) {
  AppScope.read(context).logView('Sporcu detayı');
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AthleteDetailScreen(athleteId: athleteId),
    ),
  );
}

void openClub(BuildContext context, String clubId) {
  AppScope.read(context).logView('Kulüp detayı');
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => ClubDetailScreen(clubId: clubId)));
}

void openNotifications(BuildContext context) {
  AppScope.read(context).logView('Bildirimler');
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const NotificationsScreen()));
}

/// Kulüp logosu yerine kullanılan simge; ekran okuyucu için kulüp adı etiketli.
class ClubAvatar extends StatelessWidget {
  const ClubAvatar(this.club, {super.key, this.radius = 20});

  final Club club;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${club.name} logosu',
      image: true,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: brandRed.withValues(alpha: 0.1),
        child: Icon(Icons.shield, size: radius, color: brandRed),
      ),
    );
  }
}

/// Maç listelerinde kullanılan satır: oyuncular, set skorları, durum.
class MatchTile extends StatelessWidget {
  const MatchTile(this.match, {super.key});

  final LiveMatch match;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final m = match;
    return Card(
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
                  Expanded(
                    child: Text(
                      '${m.category} · ${m.court}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  switch (m.status) {
                    MatchStatus.live => const LiveBadge(),
                    MatchStatus.upcoming => Text(
                      hm(m.startTime),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    MatchStatus.finished => Text(
                      'Bitti',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  },
                ],
              ),
              const SizedBox(height: 10),
              _PlayerRow(state.athlete(m.playerA), m, isA: true),
              const SizedBox(height: 6),
              _PlayerRow(state.athlete(m.playerB), m, isA: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow(this.athlete, this.match, {required this.isA});

  final Athlete athlete;
  final LiveMatch match;
  final bool isA;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final won = match.winner == athlete.id;
    final followed = state.followed.contains(athlete.id);
    final showScores = match.status != MatchStatus.upcoming;
    return Row(
      children: [
        AthleteAvatar(athlete, radius: 14),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  athlete.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: won ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
              if (followed) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber.shade700,
                  semanticLabel: 'Takip ediliyor',
                ),
              ],
            ],
          ),
        ),
        if (showScores)
          for (final (i, s) in match.sets.indexed)
            _ScoreCell(
              isA ? s.a : s.b,
              isCurrent:
                  i == match.sets.length - 1 &&
                  match.status == MatchStatus.live,
              isWinner: s.isOver && (isA ? s.a > s.b : s.b > s.a),
            ),
      ],
    );
  }
}

class _ScoreCell extends StatelessWidget {
  const _ScoreCell(
    this.value, {
    required this.isCurrent,
    required this.isWinner,
  });

  final int value;
  final bool isCurrent;
  final bool isWinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 26,
      margin: const EdgeInsets.only(left: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isCurrent ? brandRed.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$value',
        style: TextStyle(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: isWinner || isCurrent ? FontWeight.w800 : FontWeight.w400,
          color: isCurrent ? brandRed : null,
        ),
      ),
    );
  }
}

/// Akış satırı: sporcu gönderisinde sporcu avatarı, kulüp gönderisinde kulüp
/// simgesi gösterilir. Köşedeki küçük simge gönderinin türünü belirtir.
class FeedTile extends StatelessWidget {
  const FeedTile(this.post, {super.key});

  final FeedPost post;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final athlete = post.athleteId == null
        ? null
        : state.athlete(post.athleteId!);
    final club = post.clubId == null ? null : state.club(post.clubId!);
    final (icon, color) = switch (post.kind) {
      FeedKind.result => (Icons.emoji_events, winGreen),
      FeedKind.milestone => (Icons.trending_up, brandRed),
      FeedKind.club => (Icons.campaign_outlined, Colors.blueGrey),
      FeedKind.news => (Icons.flag_outlined, warnAmber),
    };
    return ListTile(
      onTap: () => athlete != null
          ? openAthlete(context, athlete.id)
          : openClub(context, club!.id),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          athlete != null ? AthleteAvatar(athlete) : ClubAvatar(club!),
          Positioned(
            right: -4,
            bottom: -4,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: Icon(icon, size: 13, color: color),
            ),
          ),
        ],
      ),
      title: Text(
        athlete?.name ?? club!.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(post.text),
      trailing: Text(
        timeAgo(post.time),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
