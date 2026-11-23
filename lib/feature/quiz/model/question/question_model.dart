import '../answer/answer_model.dart';

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.quizId,
    required this.statement,
    required this.answers,
  });

  final int id;
  final int quizId;
  final String statement;
  final List<AnswerModel> answers;
}