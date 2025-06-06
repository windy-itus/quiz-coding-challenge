part of 'quiz_bloc.dart';

// States
class QuizState extends Equatable {
  const QuizState({required this.status, this.quiz, this.currentQuestionIndex, this.answers, this.errorMessage});

  final QuizStatus status;
  final Quiz? quiz;
  final int? currentQuestionIndex;
  final Map<String, int>? answers;
  final String? errorMessage;

  @override
  List<Object?> get props => [quiz, currentQuestionIndex, answers, status];

  QuizState copyWith(
      {QuizStatus? status, Quiz? quiz, int? currentQuestionIndex, Map<String, int>? answers, String? errorMessage}) {
    return QuizState(
        status: status ?? this.status,
        quiz: quiz ?? this.quiz,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        answers: answers ?? this.answers,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

enum QuizStatus { initial, loading, loaded, error }

extension QuizStatusX on QuizStatus {
  bool get isInitial => this == QuizStatus.initial;
  bool get isLoading => this == QuizStatus.loading;
  bool get isLoaded => this == QuizStatus.loaded;
  bool get isError => this == QuizStatus.error;
}
