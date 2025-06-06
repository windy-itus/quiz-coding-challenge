enum WebSocketEventType {
  leaderboardUpdate,
  leaderboardInit,
}

class WebSocketEvent {
  final WebSocketEventType type;
  final dynamic payload;

  WebSocketEvent({required this.type, this.payload});
}
