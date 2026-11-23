import 'package:drift/drift.dart';

import '../../studymaterial/model/study_material_model.dart';
import '../model/answer/answer_model.dart';
import '../model/question/question_model.dart';
import '../model/quiz_bundle_model.dart';
import '../../../core/database/app_database.dart';
import '../model/question/question_draft_model.dart';
import '../model/quiz_model.dart';

class QuizRepository {
  final AppDatabase db;

  QuizRepository(this.db);

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
    _validateQuiz(title, questions);

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

  // CARREGAR QUIZ

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

  void _validateQuiz(String title, List<QuestionDraftModel> questions) {
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

  }


  Future<void> updateQuiz({
    required int quizId,
    required String title,
    required String description,
    required List<QuestionDraftModel> questions,
  }) async {
    _validateQuiz(title, questions);

    await db.transaction(() async {
      final existing = await (db.select(db.quizzes)
        ..where((t) => t.id.equals(quizId)))
          .getSingleOrNull();
      if (existing == null) throw StateError('Quiz não encontrado.');

      await (db.update(db.quizzes)
        ..where((t) => t.id.equals(quizId)))
          .write(QuizzesCompanion(
        title: Value(title.trim()),
        description: Value(description.trim()),
      ));

      await (db.delete(db.questions)
        ..where((t) => t.quizId.equals(quizId)))
          .go();

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

  Future<void> deleteQuiz(int quizId) async {
    final deleted = await (db.delete(db.quizzes)
      ..where((t) => t.id.equals(quizId)))
        .go();
    if (deleted == 0) throw StateError('Quiz não encontrado.');
  }
}