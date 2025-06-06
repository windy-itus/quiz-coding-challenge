part of 'quiz_bloc.dart';

// Events
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class JoinQuiz extends QuizEvent {
  final String quizId;

  const JoinQuiz(this.quizId);

  @override
  List<Object?> get props => [quizId];
}

class AnswerQuestion extends QuizEvent {
  final String questionId;
  final int selectedOptionIndex;

  const AnswerQuestion({required this.questionId, required this.selectedOptionIndex});

  @override
  List<Object?> get props => [questionId, selectedOptionIndex];
}
