import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get leaderboardWsUrl => dotenv.env['LEADERBOARD_WS_URL'] ?? 'ws://localhost:3000';
  static String get leaderboardHostUrl => dotenv.env['LEADERBOARD_HOST_URL'] ?? 'http://localhost:3000';
}
