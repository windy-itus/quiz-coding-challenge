import 'package:equatable/equatable.dart';

class Leaderboard extends Equatable {
  final String quizId;
  final List<LeaderboardEntry> entries;
  final DateTime lastUpdated;

  const Leaderboard({
    required this.quizId,
    required this.entries,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [quizId, entries, lastUpdated];
}

class LeaderboardUpdateEvent extends Equatable {
  final List<LeaderboardEntry>? added;
  final List<LeaderboardEntry>? updated;
  final List<LeaderboardEntry>? removed;
  final DateTime timestamp;

  const LeaderboardUpdateEvent({
    this.added,
    this.updated,
    this.removed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [added, updated, removed, timestamp];
}

class LeaderboardEntry extends Equatable {
  final String userId;
  final String username;
  final int score;
  final int rank;

  const LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.rank,
  });

  @override
  List<Object?> get props => [userId, username, score, rank];
}
