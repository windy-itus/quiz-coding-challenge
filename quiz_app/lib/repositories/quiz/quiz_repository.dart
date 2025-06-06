abstract class QuizRepository {
  Future<void> submitAnswer(String quizId, Map<String, int> answers);
}
