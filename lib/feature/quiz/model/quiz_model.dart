class QuizModel {
  const QuizModel({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
  });

  final int id;
  final int categoryId;
  final String title;
  final String description;
}