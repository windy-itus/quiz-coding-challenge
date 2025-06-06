import 'package:quiz_app/models/leaderboard.dart';

// TODO: Consider use Swagger to integrate with the backend quickly
abstract class LeaderboardRepository {
  Stream<Leaderboard> connectToLeaderboard(String quizId);
  void disconnect();
}
