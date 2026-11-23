
import 'package:drift/drift.dart';

import 'app_database.dart';

class StartDataSeeder {
  final AppDatabase db;

  StartDataSeeder(this.db);

  static const String _seedVersion = 'initial_data_v1';

  Future<void> seed() async {
    await db.transaction(() async {
      await db.customStatement('''
        CREATE TABLE IF NOT EXISTS app_seed_control (
          seed_key TEXT PRIMARY KEY NOT NULL
        )
      ''');

      final alreadySeeded = await db.customSelect(
        "SELECT seed_key FROM app_seed_control "
            "WHERE seed_key = '$_seedVersion' LIMIT 1",
      ).getSingleOrNull();

      if (alreadySeeded != null) {
        return;
      }

      final existingCategory = await (
          db.select(db.categories)..limit(1)
      ).getSingleOrNull();

      if (existingCategory == null) {
        await _createInitialContent();
      }

      await db.customStatement(
        "INSERT INTO app_seed_control (seed_key) "
            "VALUES ('$_seedVersion')",
      );
    });
  }

  Future<void> _createInitialContent() async {
    final categoryId = await db.into(db.categories).insert(
      CategoriesCompanion.insert(
        name: 'Primeiros passos',
        description: const Value(
          'Aprenda a utilizar a repetição espaçada nos estudos.',
        ),
      ),
    );

    final quizId = await db.into(db.quizzes).insert(
      QuizzesCompanion.insert(
        categoryId: categoryId,
        title: 'Introdução à repetição espaçada',
        description: const Value(
          'Quiz introdutório sobre técnicas de revisão.',
        ),
      ),
    );

    const questions = <_SeedQuestion>[
      _SeedQuestion(
        statement: 'Qual é o objetivo da repetição espaçada?',
        answers: [
          'Revisar o conteúdo em intervalos planejados',
          'Estudar tudo em um único dia',
          'Evitar qualquer revisão',
          'Memorizar sem testar',
        ],
        correctIndex: 0,
      ),
      _SeedQuestion(
        statement: 'O que fazer ao errar muitas questões?',
        answers: [
          'Esperar mais tempo antes de revisar',
          'Revisar o conteúdo e tentar novamente',
          'Excluir todas as perguntas',
          'Parar de estudar o assunto',
        ],
        correctIndex: 1,
      ),
      _SeedQuestion(
        statement: 'Por que responder quizzes ajuda nos estudos?',
        answers: [
          'Substitui completamente o sono',
          'Evita aprender conceitos novos',
          'Ajuda a praticar a recuperação da memória',
          'Garante acertar toda prova',
        ],
        correctIndex: 2,
      ),
    ];

    for (var i = 0; i < questions.length; i++) {
      final question = questions[i];

      final questionId = await db.into(db.questions).insert(
        QuestionsCompanion.insert(
          quizId: quizId,
          statement: question.statement,
          position: i,
        ),
      );

      for (var j = 0; j < question.answers.length; j++) {
        await db.into(db.answers).insert(
          AnswersCompanion.insert(
            questionId: questionId,
            answerText: question.answers[j],
            isCorrect: j == question.correctIndex,
            position: j,
          ),
        );
      }
    }
  }
}

class _SeedQuestion {
  final String statement;
  final List<String> answers;
  final int correctIndex;

  const _SeedQuestion({
    required this.statement,
    required this.answers,
    required this.correctIndex,
  });
}
