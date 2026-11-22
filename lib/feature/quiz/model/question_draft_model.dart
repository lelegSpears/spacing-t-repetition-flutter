class QuestionDraftModel {
  const QuestionDraftModel({
    required this.statement,
    required this.answers,
    required this.correctIndex,
  });

  final String statement;
  final List<String> answers;
  final int correctIndex;
}