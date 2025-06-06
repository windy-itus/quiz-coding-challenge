part of 'leaderboard_bloc.dart';

// Events
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToLeaderboard extends LeaderboardEvent {
  final String quizId;

  const ConnectToLeaderboard(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class DisconnectFromLeaderboard extends LeaderboardEvent {}

class LeaderboardSocketEventReceived extends LeaderboardEvent {
  final WebSocketEvent event;

  const LeaderboardSocketEventReceived(this.event);

  @override
  List<Object?> get props => [event];
}
