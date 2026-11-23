import 'package:drift/drift.dart';

import '../../../util/repetition_service.dart';
import '../../../core/database/app_database.dart';
import '../../quiz/model/quiz_model.dart';
import '../model/review_model.dart';

class ReviewRepository {
  final AppDatabase db;

  ReviewRepository(this.db);

  Future<ReviewModel> completeQuiz({
    required QuizModel quiz,
    required int correct,
    required int total,
  }) async {
    final days = RepetitionService.nextIntervalDays(
      correct: correct,
      total: total,
    );

    final completed = DateTime.now();

    final nextReview = completed.add(
      Duration(days: days),
    );

    await db.transaction(() async {
      await db.into(db.quizAttempts).insert(
        QuizAttemptsCompanion.insert(
          quizId: quiz.id,
          completedAt: completed,
          correctCount: correct,
          totalCount: total,
        ),
      );

      await db.into(db.reviewSchedules).insertOnConflictUpdate(
        ReviewSchedulesCompanion.insert(
          quizId: Value(quiz.id),
          nextReviewAt: nextReview,
          intervalDays: days,
        ),
      );
    });

    return ReviewModel(
      quizId: quiz.id,
      quizTitle: quiz.title,
      nextReviewAt: nextReview,
      intervalDays: days,
    );
  }

// REVISÕES

  Stream<List<ReviewModel>> watchReviews() {
    return db.select(db.reviewSchedules).watch().asyncMap(
          (rows) async {
        final quizzes = await db.select(db.quizzes).get();

        final titles = {
          for (final quiz in quizzes) quiz.id: quiz.title,
        };

        final reviews = rows
            .where((row) => titles.containsKey(row.quizId))
            .map(
              (row) => ReviewModel(
            quizId: row.quizId,
            quizTitle: titles[row.quizId]!,
            nextReviewAt: row.nextReviewAt,
            intervalDays: row.intervalDays,
          ),
        )
            .toList();

        reviews.sort(
              (a, b) => a.nextReviewAt.compareTo(b.nextReviewAt),
        );

        return reviews;
      },
    );
  }

// HISTÓRICO

  Stream<List<AttemptModel>> watchAttempts() {
    return (db.select(db.quizAttempts)
      ..orderBy([
            (t) => OrderingTerm.desc(t.completedAt),
      ]))
        .watch()
        .map(
          (rows) => rows
          .map(
            (row) => AttemptModel(
          quizId: row.quizId,
          completedAt: row.completedAt,
          correct: row.correctCount,
          total: row.totalCount,
        ),
      )
          .toList(),
    );
  }
}