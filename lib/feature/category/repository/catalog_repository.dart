
import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/util/RepetitionService.dart';

import '../../quiz/model/answer_model.dart';
import '../../category/model/category_model.dart';
import '../../quiz/model/question_model.dart';
import '../../quiz/model/question_draft_model.dart';
import '../../quiz/model/quiz_bundle_model.dart';
import '../../quiz/model/quiz_model.dart';
import '../../quiz/model/review_model.dart';
import '../../StudyMaterial/model/study_material_model.dart';

class CatalogRepository {
  final AppDatabase db;

  CatalogRepository(this.db);

  // ==================== CATEGORIAS ====================

  Stream<List<CategoryModel>> watchCategories() {
    return (db.select(db.categories)
      ..orderBy([
            (t) => OrderingTerm.asc(t.name),
      ]))
        .watch()
        .map(
          (rows) => rows
          .map(
            (row) => CategoryModel(
          id: row.id,
          name: row.name,
          description: row.description,
        ),
      )
          .toList(),
    );
  }

  Future<int> createCategory(
      String name,
      String description,
      ) async {
    final value = name.trim();

    if (value.isEmpty) {
      throw ArgumentError('Informe o nome da categoria.');
    }

    final current = await db.select(db.categories).get();

    final alreadyExists = current.any(
          (category) =>
      category.name.toLowerCase() == value.toLowerCase(),
    );

    if (alreadyExists) {
      throw ArgumentError('Essa categoria já existe.');
    }

    return db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: value,
        description: Value(description.trim()),
      ),
    );
  }

  // ==================== QUIZZES ====================

  Stream<List<QuizModel>> watchQuizzes(int categoryId) {
    return (db.select(db.quizzes)
      ..where((t) => t.categoryId.equals(categoryId))
      ..orderBy([
            (t) => OrderingTerm.asc(t.title),
      ]))
        .watch()
        .map(
          (rows) => rows.map(_quizModel).toList(),
    );
  }

  QuizModel _quizModel(QuizRow row) {
    return QuizModel(
      id: row.id,
      categoryId: row.categoryId,
      title: row.title,
      description: row.description,
    );
  }

  Future<void> createQuiz({
    required int categoryId,
    required String title,
    required String description,
    required List<QuestionDraftModel> questions,
  }) async {
    if (title.trim().isEmpty || questions.isEmpty) {
      throw ArgumentError(
        'Informe um título e pelo menos uma questão.',
      );
    }

    for (final question in questions) {
      if (question.statement.trim().isEmpty ||
          question.answers.length != 4 ||
          question.answers.any((a) => a.trim().isEmpty) ||
          question.correctIndex < 0 ||
          question.correctIndex >= question.answers.length) {
        throw ArgumentError('Existem questões incompletas.');
      }
    }

    await db.transaction(() async {
      final category = await (db.select(db.categories)
        ..where((t) => t.id.equals(categoryId)))
          .getSingleOrNull();

      if (category == null) {
        throw ArgumentError('Categoria não encontrada.');
      }

      final quizId = await db.into(db.quizzes).insert(
        QuizzesCompanion.insert(
          categoryId: categoryId,
          title: title.trim(),
          description: Value(description.trim()),
        ),
      );

      for (var index = 0; index < questions.length; index++) {
        final draft = questions[index];

        final questionId = await db.into(db.questions).insert(
          QuestionsCompanion.insert(
            quizId: quizId,
            statement: draft.statement.trim(),
            position: index,
          ),
        );

        for (var i = 0; i < draft.answers.length; i++) {
          await db.into(db.answers).insert(
            AnswersCompanion.insert(
              questionId: questionId,
              answerText: draft.answers[i].trim(),
              isCorrect: i == draft.correctIndex,
              position: i,
            ),
          );
        }
      }
    });
  }

  // ==================== CARREGAR QUIZ ====================

  Future<QuizBundleModel> loadQuiz(int quizId) async {
    final quizRow = await (db.select(db.quizzes)
      ..where((t) => t.id.equals(quizId)))
        .getSingle();

    final questionRows = await (db.select(db.questions)
      ..where((t) => t.quizId.equals(quizId))
      ..orderBy([
            (t) => OrderingTerm.asc(t.position),
      ]))
        .get();

    final materialRows = await (db.select(db.studyMaterials)
      ..where((t) => t.quizId.equals(quizId))
      ..orderBy([
            (t) => OrderingTerm.asc(t.position),
      ]))
        .get();

    final questionIds = questionRows.map((q) => q.id).toList();

    final answerRows = questionIds.isEmpty
        ? await (db.select(db.answers)
      ..where((t) => const Constant(false)))
        .get()
        : await (db.select(db.answers)
      ..where((t) => t.questionId.isIn(questionIds)))
        .get();

    final questions = questionRows.map((question) {
      final matchingAnswers = answerRows
          .where((answer) => answer.questionId == question.id)
          .toList()
        ..sort(
              (a, b) => a.position.compareTo(b.position),
        );

      return QuestionModel(
        id: question.id,
        quizId: question.quizId,
        statement: question.statement,
        answers: matchingAnswers
            .map(
              (answer) => AnswerModel(
            id: answer.id,
            questionId: answer.questionId,
            text: answer.answerText,
            isCorrect: answer.isCorrect,
          ),
        )
            .toList(),
      );
    }).toList();

    final materials = materialRows
        .map(
          (material) => StudyMaterialModel(
        id: material.id,
        quizId: material.quizId,
        title: material.title,
        content: material.content,
      ),
    )
        .toList();

    return QuizBundleModel(
      quiz: _quizModel(quizRow),
      questions: questions,
      materials: materials,
    );
  }

  // ==================== MATERIAIS ====================

  Future<void> createStudyMaterial({
    required int quizId,
    required String title,
    required String content,
  }) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw ArgumentError('Preencha título e conteúdo.');
    }

    await db.transaction(() async {
      final quiz = await (db.select(db.quizzes)
        ..where((t) => t.id.equals(quizId)))
          .getSingleOrNull();

      if (quiz == null) {
        throw ArgumentError('Quiz não encontrado.');
      }

      final others = await (db.select(db.studyMaterials)
        ..where((t) => t.quizId.equals(quizId)))
          .get();

      await db.into(db.studyMaterials).insert(
        StudyMaterialsCompanion.insert(
          quizId: quizId,
          title: title.trim(),
          content: content.trim(),
          position: others.length,
        ),
      );
    });
  }

  // ==================== RESULTADOS ====================

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

  // ==================== REVISÕES ====================

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

  // ==================== HISTÓRICO ====================

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
