import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../widgets/back_to_home_button.dart';
import '../constants/string_constants.dart';
import '../constants/style_constants.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(StringConstants.quizTitle)),
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state.status == QuizStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == QuizStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? StringConstants.somethingWentWrong, style: StyleConstants.errorStyle),
                  const SizedBox(height: StyleConstants.smallSpacing),
                  const BackToHomeButton(),
                ],
              ),
            );
          }

          if (state.status == QuizStatus.loaded) {
            if (state.currentQuestionIndex == state.quiz!.questions.length) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(StringConstants.quizCompleted, style: StyleConstants.titleStyle),
                    SizedBox(height: StyleConstants.smallSpacing),
                    BackToHomeButton(),
                  ],
                ),
              );
            }

            final question = state.quiz!.questions[state.currentQuestionIndex!];
            return Padding(
              padding: const EdgeInsets.all(StyleConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Question ${state.currentQuestionIndex! + 1}/${state.quiz!.questions.length}',
                    style: StyleConstants.questionNumberStyle,
                  ),
                  const SizedBox(height: StyleConstants.smallSpacing),
                  Text(question.text, style: StyleConstants.subtitleStyle),
                  const SizedBox(height: StyleConstants.mediumSpacing),
                  ...List.generate(
                    question.options.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<QuizBloc>().add(
                                AnswerQuestion(questionId: question.id, selectedOptionIndex: index),
                              );
                        },
                        child: Text(question.options[index]),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(StringConstants.notFound, style: StyleConstants.titleStyle),
                SizedBox(height: StyleConstants.smallSpacing),
                BackToHomeButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
