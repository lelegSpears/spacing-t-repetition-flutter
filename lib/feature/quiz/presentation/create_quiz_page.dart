import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/repository/category_repository.dart';
import '../model/question/question_draft_model.dart';
import '../model/quiz_bundle_model.dart';
import 'question/create_question_page.dart';

class CreateQuizPage extends StatelessWidget {
  const CreateQuizPage({
    super.key,
    required this.categoryId,
    required this.repository,
    this.existing,
  });

  final int categoryId;
  final CatalogRepository repository;
  final QuizBundleModel? existing;

  List<QuestionDraftModel> _existingDrafts() {
    if (existing == null) return const [];
    return existing!.questions.map((question) {
      final correctIndex = question.answers.indexWhere((a) => a.isCorrect);
      if (question.answers.length != 4 || correctIndex < 0) {
        throw StateError('O quiz possui questões incompatíveis com o editor.');
      }
      return QuestionDraftModel(
        statement: question.statement,
        answers: question.answers.map((a) => a.text).toList(),
        correctIndex: correctIndex,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String title = existing?.quiz.title ?? '';
    String description = existing?.quiz.description ?? '';
    int questionCount = existing == null
        ? 5
        : (existing!.questions.isEmpty ? 1 : existing!.questions.length);
    final isEditing = existing != null;

    return Form(
      child: Builder(
        builder: (formContext) => Scaffold(
          appBar: AppBar(title: Text(isEditing ? 'Editar quiz' : 'Criar quiz')),
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
                            Text(isEditing ? 'Editar quiz' : 'Novo quiz',
                                style: const TextStyle(
                                    fontSize: 23, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 18),
                            TextFormField(
                              initialValue: existing?.quiz.title,
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
                              initialValue: existing?.quiz.description,
                              maxLines: 3,
                              maxLength: 300,
                              decoration: const InputDecoration(labelText: 'Descrição'),
                              onSaved: (value) =>
                              description = value?.trim() ?? '',
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: '$questionCount',
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
                              icon: Icon(isEditing ? Icons.edit_note : Icons.arrow_forward),
                              label: Text(isEditing
                                  ? 'Editar questões e salvar'
                                  : 'Criar questões'),
                              onPressed: () async {
                                final form = Form.of(formContext);
                                if (!form.validate()) return;
                                form.save();
                                try {
                                  final initial = _existingDrafts();
                                  final drafts = await Navigator.push<
                                      List<QuestionDraftModel>>(
                                    formContext,
                                    MaterialPageRoute(
                                      builder: (_) => CreateQuestionPage(
                                        questionCount: questionCount,
                                        initialQuestions: initial,
                                      ),
                                    ),
                                  );
                                  if (!formContext.mounted || drafts == null) return;
                                  if (existing == null) {
                                    await repository.createQuiz(
                                      categoryId: categoryId,
                                      title: title,
                                      description: description,
                                      questions: drafts,
                                    );
                                  } else {
                                    await repository.updateQuiz(
                                      quizId: existing!.quiz.id,
                                      title: title,
                                      description: description,
                                      questions: drafts,
                                    );
                                  }
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