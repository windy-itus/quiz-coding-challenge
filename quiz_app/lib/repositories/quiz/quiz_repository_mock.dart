import 'package:quiz_app/repositories/quiz/quiz_repository.dart';

class QuizRepositoryMock extends QuizRepository {
  @override
  Future<void> submitAnswer(String quizId, Map<String, int> answers) async {
    // Do nothing
  }
}
