import 'package:flutter/material.dart';

class Athlete {
  const Athlete({
    required this.id,
    required this.name,
    required this.club,
    required this.city,
    required this.category,
    required this.ranking,
    required this.rankingHistory,
    required this.wins,
    required this.losses,
    required this.form,
  });

  final String id;
  final String name;
  final String club;
  final String city;
  final String category;

  /// Güncel ulusal sıralama (1 = en iyi).
  final int ranking;

  /// Son aylara ait sıralama geçmişi, eskiden yeniye.
  final List<int> rankingHistory;
  final int wins;
  final int losses;

  /// Son maç sonuçları, eskiden yeniye (true = galibiyet).
  final List<bool> form;

  String get initials {
    final parts = name.split(' ');
    return parts.take(2).map((p) => p.characters.first).join();
  }

  double get winRate => wins + losses == 0 ? 0 : wins / (wins + losses);
}

class Tournament {
  const Tournament({
    required this.id,
    required this.name,
    required this.location,
    required this.start,
    required this.end,
    required this.deadline,
  });

  final String id;
  final String name;
  final String location;
  final DateTime start;
  final DateTime end;
  final DateTime deadline;
}

class MatchSet {
  MatchSet([this.a = 0, this.b = 0]);
  int a;
  int b;

  bool get isOver =>
      a == 30 || b == 30 || ((a >= 21 || b >= 21) && (a - b).abs() >= 2);
}

enum MatchStatus { upcoming, live, finished }

enum PointEvent { point, setWon, matchWon }

class LiveMatch {
  LiveMatch({
    required this.id,
    required this.tournament,
    required this.category,
    required this.court,
    required this.playerA,
    required this.playerB,
    required this.startTime,
    required this.status,
    List<MatchSet>? sets,
  }) : sets = sets ?? [MatchSet()];

  final String id;
  final String tournament;
  final String category;
  final String court;
  final String playerA;
  final String playerB;
  final DateTime startTime;
  MatchStatus status;
  final List<MatchSet> sets;

  /// Son sayıyı kimin aldığı (true = A), momentum göstergesi için.
  final List<bool> lastPoints = [];

  int get setsA => sets.where((s) => s.isOver && s.a > s.b).length;
  int get setsB => sets.where((s) => s.isOver && s.b > s.a).length;
  MatchSet get current => sets.last;
  String? get winner => setsA == 2 ? playerA : (setsB == 2 ? playerB : null);

  bool involves(String athleteId) =>
      playerA == athleteId || playerB == athleteId;

  PointEvent addPoint(bool toA) {
    final s = current;
    toA ? s.a++ : s.b++;
    lastPoints.add(toA);
    if (lastPoints.length > 12) lastPoints.removeAt(0);
    if (!s.isOver) return PointEvent.point;
    if (setsA == 2 || setsB == 2) {
      status = MatchStatus.finished;
      return PointEvent.matchWon;
    }
    sets.add(MatchSet());
    return PointEvent.setWon;
  }
}

class NewsItem {
  const NewsItem(this.title, this.date, this.tag);
  final String title;
  final DateTime date;
  final String tag;
}

enum FeedKind { result, news, club, milestone }

class Club {
  const Club({
    required this.id,
    required this.name,
    required this.city,
    required this.founded,
  });

  final String id;
  final String name;
  final String city;
  final int founded;
}

/// Akış gönderisi; ya bir sporcuya ya da bir kulübe aittir.
class FeedPost {
  FeedPost({
    this.athleteId,
    this.clubId,
    required this.text,
    required this.time,
    required this.kind,
  }) : assert((athleteId == null) != (clubId == null));

  final String? athleteId;
  final String? clubId;
  final String text;
  final DateTime time;
  final FeedKind kind;
}

class TrainingEntry {
  TrainingEntry(this.date, this.type, this.minutes);
  final DateTime date;
  final String type;
  final int minutes;
}

enum NoticeKind { reminder, matchStart, result, badge }

class AppNotice {
  AppNotice(this.title, this.body, this.kind) : time = DateTime.now();
  final String title;
  final String body;
  final NoticeKind kind;
  final DateTime time;
  bool read = false;

  IconData get icon => switch (kind) {
    NoticeKind.reminder => Icons.alarm,
    NoticeKind.matchStart => Icons.sports_tennis,
    NoticeKind.result => Icons.emoji_events_outlined,
    NoticeKind.badge => Icons.military_tech,
  };
}

class BadgeDef {
  const BadgeDef(this.id, this.title, this.description, this.icon);
  final String id;
  final String title;
  final String description;
  final IconData icon;
}
