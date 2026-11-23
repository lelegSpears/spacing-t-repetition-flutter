
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// CATEGORIAS

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().unique()();

  TextColumn get description =>
      text().withDefault(const Constant(''))();
}

// QUIZZES

@DataClassName('QuizRow')
class Quizzes extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get categoryId => integer().references(
    Categories,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get title => text()();

  TextColumn get description =>
      text().withDefault(const Constant(''))();
}

// QUESTÕES

class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get quizId => integer().references(
    Quizzes,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get statement => text()();

  IntColumn get position => integer()();
}

// RESPOSTAS

class Answers extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get questionId => integer().references(
    Questions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get answerText => text().named('text')();

  BoolColumn get isCorrect => boolean()();

  IntColumn get position => integer()();
}

// MATERIAIS

class StudyMaterials extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get quizId => integer().references(
    Quizzes,
    #id,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get title => text()();

  TextColumn get content => text()();

  IntColumn get position => integer()();
}

// TENTATIVAS

class QuizAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get quizId => integer().references(
    Quizzes,
    #id,
    onDelete: KeyAction.cascade,
  )();

  DateTimeColumn get completedAt => dateTime()();

  IntColumn get correctCount => integer()();

  IntColumn get totalCount => integer()();
}

// AGENDAMENTO

class ReviewSchedules extends Table {
  IntColumn get quizId => integer().references(
    Quizzes,
    #id,
    onDelete: KeyAction.cascade,
  )();

  DateTimeColumn get nextReviewAt => dateTime()();

  IntColumn get intervalDays => integer()();

  @override
  Set<Column> get primaryKey => {quizId};
}

// DATABASE

@DriftDatabase(
  tables: [
    Categories,
    Quizzes,
    Questions,
    Answers,
    StudyMaterials,
    QuizAttempts,
    ReviewSchedules,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
    driftDatabase(
      name: 'spacing_t_repetition.sqlite',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    ),
  );

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement(
        'PRAGMA foreign_keys = ON',
      );
    },
  );
}