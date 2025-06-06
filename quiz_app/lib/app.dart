import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/quiz/quiz_bloc.dart';
import 'blocs/leaderboard/leaderboard_bloc.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/leaderboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/quiz',
          builder: (context, state) {
            return const QuizScreen();
          },
        ),
        GoRoute(
          path: '/leaderboard/:quizId',
          builder: (context, state) => LeaderboardScreen(quizId: state.pathParameters['quizId']!),
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => QuizBloc()), BlocProvider(create: (context) => LeaderboardBloc())],
      child: MaterialApp.router(
        title: 'Quiz App',
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
        routerConfig: router,
      ),
    );
  }
}
