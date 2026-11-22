import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../quiz/presentation/quizzes_page.dart';
import '../model/category_model.dart';
import '../repository/catalog_repository.dart';
import '../model/category_draft_model.dart';
import '../widgets/create_category_widget.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.repository,
    this.materialsOnly = false,
  });

  final CatalogRepository repository;
  final bool materialsOnly;

  Future<void> _create(BuildContext context) async {
    final result = await showDialog<CategoryDraftModel>(
      context: context,
      builder: (_) => const CreateCategoryWidget(),
    );
    if (result == null) return;
    try {
      await repository.createCategory(result.name, result.description);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível criar: $error')),
      );
    }
  }

  void _openCategory(BuildContext context, CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizListPage(
          repository: repository,
          category: category,
          materialsOnly: materialsOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(materialsOnly ? 'Materiais por categoria' : 'Categorias'),
    ),
    floatingActionButton: materialsOnly
        ? null
        : FloatingActionButton(
      tooltip: 'Criar categoria',
      onPressed: () => _create(context),
      child: const Icon(Icons.add),
    ),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: StreamBuilder<List<CategoryModel>>(
        stream: repository.watchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar categorias.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = snapshot.data!;
          if (categories.isEmpty) {
            return Center(
              child: Text(materialsOnly
                  ? 'Nenhuma categoria disponível.'
                  : 'Nenhuma categoria ainda.\nToque no + para criar.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: const Icon(Icons.folder_outlined,
                      size: 32, color: Colors.lightBlue),
                  title: Text(category.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: category.description.isEmpty
                      ? null
                      : Text(category.description),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openCategory(context, category),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}