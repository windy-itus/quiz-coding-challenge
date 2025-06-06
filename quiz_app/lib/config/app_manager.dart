import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:quiz_app/config/env.dart';
import 'package:quiz_app/repositories/leaderboard/leaderboard_repository.dart';
import 'package:quiz_app/repositories/leaderboard/leaderboard_repository_impl.dart';
import 'package:quiz_app/repositories/quiz/quiz_repository.dart';
import 'package:quiz_app/repositories/quiz/quiz_repository_mock.dart';
import 'package:quiz_app/socket/leaderboard_web_socket_client.dart';
import 'package:quiz_app/utils/logger_service.dart';
import 'package:quiz_app/utils/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppManager {
  static final GetIt _getIt = GetIt.instance;

  ///------------------------------------------------------------------------------------------------
  ///  INIT
  ///------------------------------------------------------------------------------------------------
  Future<void> init() async {
    // Register Logger
    _getIt.registerSingleton<LoggerService>(LoggerService());

    // Initialize SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    _getIt.registerSingleton<TokenService>(TokenService(prefs));

    await _configNetworkApi();
  }

  Future _configNetworkApi() async {
    _getIt.registerSingleton<LeaderboardWebSocketClient>(LeaderboardWebSocketClient(Env.leaderboardWsUrl));
    _getIt.registerSingleton<LeaderboardRepository>(LeaderboardRepositoryImpl());
    _getIt.registerSingleton<QuizRepository>(
        QuizRepositoryMock()); // TODO: Should be replaced with the real implementation
  }

  // Method to dispose all registered instances
  static Future<void> dispose() async {
    await _getIt.reset();
  }
}
