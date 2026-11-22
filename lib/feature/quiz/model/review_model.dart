class ReviewModel {
  const ReviewModel({
    required this.quizId,
    required this.quizTitle,
    required this.nextReviewAt,
    required this.intervalDays,
  });

  final int quizId;
  final String quizTitle;
  final DateTime nextReviewAt;
  final int intervalDays;

  bool get isDue => !nextReviewAt.isAfter(DateTime.now());
}

class AttemptModel {
  const AttemptModel({
    required this.quizId,
    required this.completedAt,
    required this.correct,
    required this.total,
  });

  final int quizId;
  final DateTime completedAt;
  final int correct;
  final int total;
}