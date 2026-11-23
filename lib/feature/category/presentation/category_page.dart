import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../repository/category_repository.dart';
import '../../quiz/presentation/quiz_list_page.dart';
import '../model/category_model.dart';
import '../model/category_draft_model.dart';
import '../model/widgets/create_category_widget.dart';

class CategoryPage extends StatelessWidget {
  const CategoryPage({
    super.key,
    required this.repository,
    this.materialsOnly = false,
  });

  final CatalogRepository repository;
  final bool materialsOnly;

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _create(BuildContext context) async {
    final draft = await showDialog<CategoryDraftModel>(
      context: context,
      builder: (_) => const CreateCategoryWidget(),
    );
    if (draft == null) return;
    try {
      await repository.createCategory(draft.name, draft.description);
    } catch (error) {
      if (context.mounted) _message(context, 'Não foi possível criar: $error');
    }
  }

  Future<void> _edit(BuildContext context, CategoryModel category) async {
    final draft = await showDialog<CategoryDraftModel>(
      context: context,
      builder: (_) => CreateCategoryWidget(category: category),
    );
    if (draft == null) return;
    try {
      await repository.updateCategory(
        categoryId: category.id,
        name: draft.name,
        description: draft.description,
      );
      if (context.mounted) _message(context, 'Categoria atualizada.');
    } catch (error) {
      if (context.mounted) _message(context, 'Não foi possível editar: $error');
    }
  }

  Future<void> _delete(BuildContext context, CategoryModel category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir categoria?'),
        content: Text(
          'Excluir "${category.name}" também apaga todos os quizzes, '
              'materiais de estudo e históricos de revisão vinculados a ela. '
              'Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Excluir definitivamente'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await repository.deleteCategory(category.id);
      if (context.mounted) _message(context, 'Categoria excluída.');
    } catch (error) {
      if (context.mounted) _message(context, 'Não foi possível excluir: $error');
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
              child: Text(
                materialsOnly
                    ? 'Nenhuma categoria disponível.'
                    : 'Nenhuma categoria ainda.\nToque no + para criar.',
                textAlign: TextAlign.center,
              ),
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
                  trailing: materialsOnly
                      ? const Icon(Icons.chevron_right)
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Editar categoria',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _edit(context, category),
                      ),
                      IconButton(
                        tooltip: 'Excluir categoria',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _delete(context, category),
                      ),
                    ],
                  ),
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