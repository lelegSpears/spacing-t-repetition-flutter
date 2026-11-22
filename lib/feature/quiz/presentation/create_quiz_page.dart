import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/repository/catalog_repository.dart';
import '../model/question_draft_model.dart';
import 'create_question_page.dart';

/// Stateless: o Form armazena os campos; a página só envia os dados.
class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({
    super.key,
    required this.categoryId,
    required this.repository,
  });

  final int categoryId;
  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) {
    String title = '';
    String description = '';
    int questionCount = 5;

    return Form(
      child: Builder(
        builder: (formContext) => Scaffold(
          appBar: AppBar(title: const Text('Criar quiz')),
          body: Container(
            decoration: const BoxDecoration(
              gradient: ColorsTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Novo quiz',
                                style: TextStyle(fontSize: 23,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 18),
                            TextFormField(
                              maxLength: 80,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(labelText: 'Título'),
                              validator: (value) =>
                              value == null || value.trim().isEmpty
                                  ? 'Informe um título.'
                                  : null,
                              onSaved: (value) => title = value?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              maxLines: 3,
                              maxLength: 300,
                              decoration: const InputDecoration(labelText: 'Descrição'),
                              onSaved: (value) =>
                              description = value?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: '5',
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Quantidade de questões (1 a 50)',
                              ),
                              validator: (value) {
                                final n = int.tryParse(value ?? '');
                                return n == null || n < 1 || n > 50
                                    ? 'Informe um número de 1 a 50.'
                                    : null;
                              },
                              onSaved: (value) =>
                              questionCount = int.parse(value!),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Criar questões'),
                              onPressed: () async {
                                final form = Form.of(formContext);
                                if (!form.validate()) return;
                                form.save();
                                // Captura os campos antes de abrir outra rota.
                                final quizTitle = title;
                                final quizDescription = description;
                                final drafts = await Navigator.push<
                                    List<QuestionDraftModel>>(
                                  formContext,
                                  MaterialPageRoute(
                                    builder: (_) => CreateQuestionPage(
                                      questionCount: questionCount,
                                    ),
                                  ),
                                );
                                if (!formContext.mounted || drafts == null) return;
                                try {
                                  await repository.createQuiz(
                                    categoryId: categoryId,
                                    title: quizTitle,
                                    description: quizDescription,
                                    questions: drafts,
                                  );
                                  if (formContext.mounted) Navigator.pop(formContext);
                                } catch (error) {
                                  if (!formContext.mounted) return;
                                  ScaffoldMessenger.of(formContext).showSnackBar(
                                    SnackBar(content: Text('Erro ao salvar: $error')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}