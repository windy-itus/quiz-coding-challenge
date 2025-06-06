import 'dart:async';
import 'package:quiz_app/socket/web_socket_client.dart';
import 'package:quiz_app/socket/web_socket_event.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LeaderboardWebSocketClient extends WebSocketClient {
  final String _baseUrl;

  LeaderboardWebSocketClient(this._baseUrl) : super();

  Future<void> connectToQuiz(String quizId) async {
    await super.connect('$_baseUrl/leaderboard/$quizId');
  }

  @override
  void setupSocketEventHandlers(IO.Socket socket, StreamController<dynamic>? messageController) {
    // Handle incoming messages
    socket.on('leaderboard_update', (data) {
      try {
        messageController?.add(WebSocketEvent(type: WebSocketEventType.leaderboardUpdate, payload: data));
      } catch (e, stackTrace) {
        logger.e(() => 'Error processing Socket.IO message: $e\n$stackTrace');
      }
    });

    // Handle incoming messages
    socket.on('leaderboard_init', (data) {
      try {
        messageController?.add(WebSocketEvent(type: WebSocketEventType.leaderboardInit, payload: data));
      } catch (e, stackTrace) {
        logger.e(() => 'Error processing Socket.IO message: $e\n$stackTrace');
      }
    });
  }
}
