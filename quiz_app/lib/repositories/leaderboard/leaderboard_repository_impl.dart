import 'package:get_it/get_it.dart';
import 'package:quiz_app/socket/leaderboard_web_socket_client.dart';
import '../../models/leaderboard.dart';
import '../../utils/logger_service.dart';
import 'leaderboard_repository.dart';

class LeaderboardRepositoryImpl extends LeaderboardRepository {
  LoggerService get _logger => GetIt.instance<LoggerService>();
  LeaderboardWebSocketClient get _wsClient => GetIt.instance<LeaderboardWebSocketClient>();

  LeaderboardRepositoryImpl() : super();

  @override
  Stream<Leaderboard> connectToLeaderboard(String quizId) async* {
    try {
      await _wsClient.connectToQuiz(quizId);
    } catch (e, stackTrace) {
      _logger.e(() => 'Failed to connect to WebSocket: $e\n$stackTrace');
      rethrow;
    }
  }

  @override
  void disconnect() {
    try {
      _wsClient.disconnect();
      _logger.i(() => 'WebSocket connection closed');
    } catch (e, stackTrace) {
      _logger.e(() => 'Error while closing WebSocket connection: $e\n$stackTrace');
    }
  }
}
