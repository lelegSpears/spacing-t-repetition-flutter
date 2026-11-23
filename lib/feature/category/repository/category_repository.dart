import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../model/category_model.dart';
import '../../quiz/model/question/question_draft_model.dart';
import '../../quiz/model/quiz_bundle_model.dart';
import '../../quiz/model/quiz_model.dart';
import '../../quiz/repository/quiz_repository.dart';
import '../../review/model/review_model.dart';
import '../../review/repository/review_repository.dart';
import '../../studymaterial/repository/study_material_repository.dart';

class CatalogRepository {
  final AppDatabase db;

  CatalogRepository(this.db)
      : quizzes = QuizRepository(db),
        reviews = ReviewRepository(db),
        studyMaterials = StudyMaterialRepository(db);

  final QuizRepository quizzes;
  final ReviewRepository reviews;
  final StudyMaterialRepository studyMaterials;

  // Facade de acesso usada pelas telas, mantendo as operações em repositórios
  // separados de acordo com sua responsabilidade.
  Stream<List<QuizModel>> watchQuizzes(int categoryId) =>
      quizzes.watchQuizzes(categoryId);

  Future<QuizBundleModel> loadQuiz(int quizId) => quizzes.loadQuiz(quizId);

  Future<void> createQuiz({
    required int categoryId,
    required String title,
    required String description,
    required List<QuestionDraftModel> questions,
  }) => quizzes.createQuiz(
    categoryId: categoryId,
    title: title,
    description: description,
    questions: questions,
  );

  Future<ReviewModel> completeQuiz({
    required QuizModel quiz,
    required int correct,
    required int total,
  }) => reviews.completeQuiz(quiz: quiz, correct: correct, total: total);

  Future<void> updateQuiz({
    required int quizId,
    required String title,
    required String description,
    required List<QuestionDraftModel> questions,
  }) => quizzes.updateQuiz(
    quizId: quizId,
    title: title,
    description: description,
    questions: questions,
  );

  Future<void> deleteQuiz(int quizId) => quizzes.deleteQuiz(quizId);

  Future<void> updateStudyMaterial({
    required int materialId,
    required String title,
    required String content,
  }) => studyMaterials.updateStudyMaterial(
    materialId: materialId,
    title: title,
    content: content,
  );

  Future<void> deleteStudyMaterial(int materialId) =>
      studyMaterials.deleteStudyMaterial(materialId);

  Stream<List<ReviewModel>> watchReviews() => reviews.watchReviews();
  Stream<List<AttemptModel>> watchAttempts() => reviews.watchAttempts();

  Future<void> createStudyMaterial({
    required int quizId,
    required String title,
    required String content,
  }) => studyMaterials.createStudyMaterial(
    quizId: quizId,
    title: title,
    content: content,
  );

// CATEGORIAS

  Stream<List<CategoryModel>> watchCategories() {
    return (db.select(db.categories)
      ..orderBy([
            (t) => OrderingTerm.asc(t.name),
      ]))
        .watch()
        .map(
          (rows) =>
          rows
              .map(
                (row) =>
                CategoryModel(
                  id: row.id,
                  name: row.name,
                  description: row.description,
                ),
          )
              .toList(),
    );
  }

  Future<int> createCategory(String name,
      String description,) async {
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

  Future<void> updateCategory({
    required int categoryId,
    required String name,
    required String description,
  }) async {
    final value = name.trim();
    if (value.isEmpty) throw ArgumentError('Informe o nome da categoria.');

    await db.transaction(() async {
      final current = await db.select(db.categories).get();
      if (!current.any((row) => row.id == categoryId)) {
        throw StateError('Categoria não encontrada.');
      }
      if (current.any((row) => row.id != categoryId &&
          row.name.toLowerCase() == value.toLowerCase())) {
        throw ArgumentError('Essa categoria já existe.');
      }
      await (db.update(db.categories)
        ..where((t) => t.id.equals(categoryId)))
          .write(CategoriesCompanion(
        name: Value(value),
        description: Value(description.trim()),
      ));
    });
  }

  Future<void> deleteCategory(int categoryId) async {
    final deleted = await (db.delete(db.categories)
      ..where((t) => t.id.equals(categoryId)))
        .go();
    if (deleted == 0) throw StateError('Categoria não encontrada.');
  }
}