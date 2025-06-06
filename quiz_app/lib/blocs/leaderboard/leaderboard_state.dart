part of 'leaderboard_bloc.dart';

// States
class LeaderboardState extends Equatable {
  const LeaderboardState({
    required this.status,
    this.leaderboard,
    this.errorMessage,
  });

  final LeaderboardStatus status;
  final Leaderboard? leaderboard;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, leaderboard, errorMessage];

  LeaderboardState copyWith({
    LeaderboardStatus? status,
    Leaderboard? leaderboard,
    String? errorMessage,
  }) {
    return LeaderboardState(
      status: status ?? this.status,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum LeaderboardStatus { initial, loading, connected, error }

extension LeaderboardStatusX on LeaderboardStatus {
  bool get isInitial => this == LeaderboardStatus.initial;
  bool get isLoading => this == LeaderboardStatus.loading;
  bool get isConnected => this == LeaderboardStatus.connected;
  bool get isError => this == LeaderboardStatus.error;
}
