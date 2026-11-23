import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';

class StudyMaterialRepository {
  final AppDatabase db;

  StudyMaterialRepository(this.db);
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

  Future<void> updateStudyMaterial({
    required int materialId,
    required String title,
    required String content,
  }) async {
    if (title.trim().isEmpty || content.trim().isEmpty) {
      throw ArgumentError('Preencha título e conteúdo.');
    }
    final changed = await (db.update(db.studyMaterials)
      ..where((t) => t.id.equals(materialId)))
        .write(StudyMaterialsCompanion(
      title: Value(title.trim()),
      content: Value(content.trim()),
    ));
    if (changed == 0) throw StateError('Material não encontrado.');
  }

  Future<void> deleteStudyMaterial(int materialId) async {
    await db.transaction(() async {
      final item = await (db.select(db.studyMaterials)
        ..where((t) => t.id.equals(materialId)))
          .getSingleOrNull();
      if (item == null) throw StateError('Material não encontrado.');

      await (db.delete(db.studyMaterials)
        ..where((t) => t.id.equals(materialId)))
          .go();

      final remaining = await (db.select(db.studyMaterials)
        ..where((t) => t.quizId.equals(item.quizId))
        ..orderBy([(t) => OrderingTerm.asc(t.position)]))
          .get();
      for (var i = 0; i < remaining.length; i++) {
        if (remaining[i].position == i) continue;
        await (db.update(db.studyMaterials)
          ..where((t) => t.id.equals(remaining[i].id)))
            .write(StudyMaterialsCompanion(position: Value(i)));
      }
    });
  }
}