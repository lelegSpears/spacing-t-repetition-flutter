import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../StudyMaterial/presentation/study_material_page.dart';
import '../../category/model/category_model.dart';
import '../../category/repository/catalog_repository.dart';
import '../model/quiz_model.dart';
import 'create_quiz_page.dart';
import 'quiz_setup_page.dart';

class QuizListPage extends StatelessWidget {
  const QuizListPage({
    super.key,
    required this.category,
    required this.repository,
    this.materialsOnly = false,
  });

  final CategoryModel category;
  final CatalogRepository repository;
  final bool materialsOnly;

  Future<void> _open(BuildContext context, QuizModel quiz) async {
    if (materialsOnly) {
      final bundle = await repository.loadQuiz(quiz.id);
      if (!context.mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => StudyMaterialPage(
          materials: bundle.materials,
        ),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => QuizSetupPage(
          quizId: quiz.id,
          repository: repository,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(category.name)),
    floatingActionButton: materialsOnly
        ? null
        : FloatingActionButton(
      tooltip: 'Criar quiz',
      onPressed: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => CreateQuizPage(
          categoryId: category.id,
          repository: repository,
        ),
      )),
      child: const Icon(Icons.add),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: StreamBuilder<List<QuizModel>>(
        stream: repository.watchQuizzes(category.id),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar os quizzes.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final quizzes = snapshot.data!;
          if (quizzes.isEmpty) {
            return Center(child: Text(
              materialsOnly
                  ? 'Não há materiais cadastrados nesta categoria.'
                  : 'Não há quizzes ainda.\nToque em + para começar.',
              textAlign: TextAlign.center,
            ));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: quizzes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final quiz = quizzes[index];
              return Card(child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const Icon(Icons.quiz_outlined,
                    color: Colors.lightBlue, size: 30),
                title: Text(quiz.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: quiz.description.isEmpty
                    ? null
                    : Text(quiz.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, quiz),
              ));
            },
          );
        },
      ),
    ),
  );
}