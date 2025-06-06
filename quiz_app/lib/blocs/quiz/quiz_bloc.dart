import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:get_it/get_it.dart';
import 'package:quiz_app/repositories/quiz/quiz_repository.dart';
import '../../models/quiz.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

// BLoC
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository _quizRepository = GetIt.instance<QuizRepository>();

  QuizBloc() : super(const QuizState(status: QuizStatus.initial)) {
    on<JoinQuiz>(_onJoinQuiz);
    on<AnswerQuestion>(_onAnswerQuestion);
  }

  void _onJoinQuiz(JoinQuiz event, Emitter<QuizState> emit) async {
    emit(state.copyWith(status: QuizStatus.loading));
    try {
      // TODO: Implement actual quiz fetching logic
      // For now, using mock data
      final mockQuiz = Quiz(
        id: event.quizId,
        title: 'Sample Quiz',
        questions: const [
          Question(
            id: '1',
            text: 'What is Flutter?',
            options: ['A programming language', 'A UI framework', 'A database', 'An operating system'],
            correctOptionIndex: 1,
          ),
          Question(
            id: '2',
            text: 'Which state management solution are we using?',
            options: ['Provider', 'BLoC', 'Redux', 'MobX'],
            correctOptionIndex: 1,
          ),
        ],
      );
      emit(state.copyWith(status: QuizStatus.loaded, quiz: mockQuiz, currentQuestionIndex: 0, answers: {}));
    } catch (e) {
      emit(state.copyWith(status: QuizStatus.error, errorMessage: "Failed to join quiz"));
    }
  }

  void _onAnswerQuestion(AnswerQuestion event, Emitter<QuizState> emit) async {
    if (state.status == QuizStatus.loaded) {
      final currentState = state;
      final updatedAnswers = Map<String, int>.from(currentState.answers ?? {});
      updatedAnswers[event.questionId] = event.selectedOptionIndex;

      if (currentState.currentQuestionIndex == currentState.quiz?.questions.length) {
        try {
          await _quizRepository.submitAnswer(currentState.quiz!.id, updatedAnswers);
        } catch (e) {
          emit(currentState.copyWith(status: QuizStatus.error, errorMessage: "Failed to submit answer"));
        }
      }

      emit(currentState.copyWith(
        currentQuestionIndex: (currentState.currentQuestionIndex ?? 0) + 1,
        answers: updatedAnswers,
      ));
    }
  }
}
