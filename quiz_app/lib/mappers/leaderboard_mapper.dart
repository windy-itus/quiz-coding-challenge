import '../models/leaderboard.dart';

class LeaderboardMapper {
  static Leaderboard? fromJson(Map<String, dynamic> json) {
    try {
      return Leaderboard(
        quizId: json['quizId'] as String,
        entries: (json['entries'] as List).map((entry) => fromJsonEntry(entry)).whereType<LeaderboardEntry>().toList(),
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
    } catch (e) {
      return null;
    }
  }

  static LeaderboardUpdateEvent? fromJsonUpdate(Map<String, dynamic> data) {
    try {
      return LeaderboardUpdateEvent(
        added: (data['added'] as List).map((entry) => fromJsonEntry(entry)).whereType<LeaderboardEntry>().toList(),
        updated: (data['updated'] as List).map((entry) => fromJsonEntry(entry)).whereType<LeaderboardEntry>().toList(),
        removed: (data['removed'] as List).map((entry) => fromJsonEntry(entry)).whereType<LeaderboardEntry>().toList(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp'] as int),
      );
    } catch (e) {
      return null;
    }
  }

  static LeaderboardEntry? fromJsonEntry(Map<String, dynamic> json) {
    try {
      return LeaderboardEntry(
        userId: json['userId'] as String,
        username: json['username'] as String? ?? '', // Username is optional
        score: json['score'] as int,
        rank: json['rank'] as int,
      );
    } catch (e) {
      return null;
    }
  }
}
