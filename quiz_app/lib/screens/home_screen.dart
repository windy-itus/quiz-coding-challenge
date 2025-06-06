import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import 'package:go_router/go_router.dart';
import '../constants/string_constants.dart';
import '../constants/style_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _quizIdController = TextEditingController();
  final _leaderboardQuizIdController = TextEditingController();

  @override
  void dispose() {
    _quizIdController.dispose();
    _leaderboardQuizIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(StyleConstants.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(StringConstants.welcomeMessage, style: StyleConstants.titleStyle),
              const SizedBox(height: StyleConstants.largeSpacing),
              TextField(
                controller: _quizIdController,
                decoration: const InputDecoration(labelText: StringConstants.enterQuizId, border: OutlineInputBorder()),
              ),
              const SizedBox(height: StyleConstants.smallSpacing),
              BlocConsumer<QuizBloc, QuizState>(
                listener: (context, state) {
                  if (state.status == QuizStatus.loaded) {
                    context.go('/quiz');
                  }
                },
                builder: (context, state) {
                  return ElevatedButton(
                    onPressed: state.status == QuizStatus.loading
                        ? null
                        : () {
                            if (_quizIdController.text.isNotEmpty) {
                              context.read<QuizBloc>().add(JoinQuiz(_quizIdController.text));
                            }
                          },
                    child: state.status == QuizStatus.loading
                        ? const CircularProgressIndicator()
                        : const Text(StringConstants.startQuiz),
                  );
                },
              ),
              if (context.watch<QuizBloc>().state.status == QuizStatus.error)
                Padding(
                  padding: const EdgeInsets.only(top: StyleConstants.defaultPadding),
                  child: Text(
                    (context.watch<QuizBloc>().state).errorMessage ?? '',
                    style: StyleConstants.errorStyle,
                  ),
                ),
              const SizedBox(height: StyleConstants.largeSpacing),
              const Divider(),
              const SizedBox(height: StyleConstants.largeSpacing),
              TextField(
                controller: _leaderboardQuizIdController,
                decoration: const InputDecoration(
                  labelText: StringConstants.enterQuizIdForLeaderboard,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: StyleConstants.smallSpacing),
              ElevatedButton(
                onPressed: () {
                  if (_leaderboardQuizIdController.text.isNotEmpty) {
                    context.go('/leaderboard/${_leaderboardQuizIdController.text}');
                  }
                },
                child: const Text(StringConstants.viewLeaderboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
