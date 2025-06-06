import 'package:equatable/equatable.dart';

class Quiz extends Equatable {
  final String id;
  final String title;
  final List<Question> questions;

  const Quiz({required this.id, required this.title, required this.questions});

  @override
  List<Object?> get props => [id, title, questions];
}

class Question extends Equatable {
  final String id;
  final String text;
  final List<String> options;
  final int correctOptionIndex;

  const Question({required this.id, required this.text, required this.options, required this.correctOptionIndex});

  @override
  List<Object?> get props => [id, text, options, correctOptionIndex];
}
