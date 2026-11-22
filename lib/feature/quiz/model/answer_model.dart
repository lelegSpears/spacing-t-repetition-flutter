class AnswerModel {
  const AnswerModel({
    required this.id,
    required this.questionId,
    required this.text,
    required this.isCorrect,
  });

  final int id;
  final int questionId;
  final String text;
  final bool isCorrect;
}