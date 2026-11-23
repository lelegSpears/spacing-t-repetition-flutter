class StudyMaterialModel {
  const StudyMaterialModel({
    required this.id,
    required this.quizId,
    required this.title,
    required this.content,
  });

  final int id;
  final int quizId;
  final String title;
  final String content;
}