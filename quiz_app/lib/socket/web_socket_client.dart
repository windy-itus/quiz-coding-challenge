import 'dart:async';
import 'package:get_it/get_it.dart';
import 'package:quiz_app/socket/web_socket_event.dart';
import '../utils/logger_service.dart';
import '../utils/token_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

abstract class WebSocketClient {
  LoggerService get logger => GetIt.instance<LoggerService>();
  TokenService get _tokenService => GetIt.instance<TokenService>();
  late IO.Socket _socket;
  String? _lastUrl;
  bool _isReconnecting = false;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);

  final StreamController<WebSocketEvent> _socketEventController = StreamController<WebSocketEvent>.broadcast();

  Stream<WebSocketEvent> get socketEvents => _socketEventController.stream;

  /// Connects to a WebSocket server at the specified URL
  Future<void> connect(String url) async {
    try {
      logger.i(() => 'Connecting to Socket.IO at: $url');
      _lastUrl = url;

      final token = _tokenService.getToken();
      if (token == null) {
        throw Exception('No authentication token available');
      }

      // Create Socket.IO connection with options
      _socket = IO.io(url, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
        'reconnection': true,
        'reconnectionAttempts': _maxReconnectAttempts,
        'reconnectionDelay': _reconnectDelay.inMilliseconds,
        'auth': {
          'token': token,
        }
      });

      // Set up Socket.IO event handlers
      _socket.onConnect((_) {
        logger.i(() => 'Socket.IO connected');
        _isReconnecting = false;
      });

      _socket.onDisconnect((_) {
        logger.i(() => 'Socket.IO disconnected');
        _handleReconnection();
      });

      _socket.onError((error) {
        logger.e(() => 'Socket.IO error: $error');
        _socketEventController.addError(error);
        _handleReconnection();
      });

      _socket.onConnectError((error) {
        logger.e(() => 'Socket.IO connection error: $error');
        _socketEventController.addError(error);
        _handleReconnection();
      });

      _socket.onReconnect((_) {
        logger.i(() => 'Socket.IO reconnected');
        _isReconnecting = false;
      });

      _socket.onReconnectAttempt((attempt) {
        logger.i(() => 'Socket.IO reconnection attempt: $attempt');
        _isReconnecting = true;
      });

      _socket.onReconnectError((error) {
        logger.e(() => 'Socket.IO reconnection error: $error');
      });

      _socket.onReconnectFailed((_) {
        logger.e(() => 'Socket.IO reconnection failed after $_maxReconnectAttempts attempts');
        _isReconnecting = false;
      });

      setupSocketEventHandlers(_socket, _socketEventController);

      // Connect to the server
      _socket.connect();
    } catch (e, stackTrace) {
      logger.e(() => 'Failed to connect to Socket.IO: $e\n$stackTrace');
      rethrow;
    }
  }

  void _handleReconnection() {
    if (!_isReconnecting && _lastUrl != null) {
      logger.i(() => 'Attempting to reconnect to Socket.IO...');
      Future.delayed(_reconnectDelay, () {
        if (!_socket.connected) {
          connect(_lastUrl!);
        }
      });
    }
  }

  void setupSocketEventHandlers(IO.Socket socket, StreamController<dynamic>? messageController);

  /// Sends a message to the Socket.IO server
  void send(dynamic message) {
    try {
      _socket.emit('message', message);
    } catch (e, stackTrace) {
      logger.e(() => 'Error sending Socket.IO message: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Returns a stream of messages from the Socket.IO server
  Stream<dynamic> get messageStream {
    return socketEvents;
  }

  /// Returns a broadcast stream of messages that can be listened to by multiple subscribers
  Stream<WebSocketEvent> get broadcastMessageStream {
    return socketEvents;
  }

  /// Closes the Socket.IO connection
  void disconnect() {
    try {
      _socket.disconnect();
      _socketEventController.close();
      logger.i(() => 'Socket.IO connection closed');
    } catch (e, stackTrace) {
      logger.e(() => 'Error while closing Socket.IO connection: $e\n$stackTrace');
    }
  }

  /// Checks if the Socket.IO is connected
  bool get isConnected => _socket.connected;
}
