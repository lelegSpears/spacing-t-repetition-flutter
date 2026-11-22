import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/repository/catalog_repository.dart';
import '../model/question_model.dart';
import '../model/quiz_bundle_model.dart';
import 'quiz_result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.bundle,
    required this.questions,
    required this.repository,
  });

  final QuizBundleModel bundle;
  final List<QuestionModel> questions;
  final CatalogRepository repository;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int _index = 0;
  final Map<int, int> _selected = {};
  bool _saving = false;

  Future<void> _next() async {
    if (!_selected.containsKey(widget.questions[_index].id) || _saving) return;
    if (_index < widget.questions.length - 1) {
      setState(() => _index++);
      return;
    }

    setState(() => _saving = true);
    var correct = 0;
    for (final question in widget.questions) {
      final selectedAnswerId = _selected[question.id];
      if (question.answers.any(
              (answer) => answer.id == selectedAnswerId && answer.isCorrect)) {
        correct++;
      }
    }
    try {
      final schedule = await widget.repository.completeQuiz(
        quiz: widget.bundle.quiz,
        correct: correct,
        total: widget.questions.length,
      );
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => QuizResultPage(
          quizTitle: widget.bundle.quiz.title,
          score: correct,
          total: widget.questions.length,
          review: schedule,
        ),
      ));
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível salvar o resultado: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Nenhuma questão disponível.')),
      );
    }
    final question = widget.questions[_index];
    final selectedId = _selected[question.id];
    final isLast = _index == widget.questions.length - 1;

    return Scaffold(
      appBar: AppBar(title: Text(widget.bundle.quiz.title)),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColorsTheme.backgroundGradient,
        ),
        child: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                Text('Questão ${_index + 1} / ${widget.questions.length}',
                    style: const TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  minHeight: 7,
                  value: (_index + 1) / widget.questions.length,
                ),
              ]),
            ),
            Expanded(child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Card(child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(question.statement,
                          style: const TextStyle(fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      ...question.answers.map((answer) {
                        final selected = selectedId == answer.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            color: selected
                                ? Colors.lightBlue.shade50 : Colors.white,
                            child: ListTile(
                              leading: Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: Colors.lightBlue,
                              ),
                              title: Text(answer.text),
                              onTap: _saving ? null : () => setState(() =>
                              _selected[question.id] = answer.id),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                )),
              ],
            )),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                if (_index > 0) ...[
                  OutlinedButton(
                    onPressed: _saving ? null : () => setState(() => _index--),
                    child: const Text('Voltar'),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: ElevatedButton(
                  onPressed: selectedId == null || _saving ? null : _next,
                  child: Text(_saving ? 'Salvando...' :
                  isLast ? 'Finalizar' : 'Próxima questão'),
                )),
              ]),
            ),
          ]),
        ))),
      ),
    );
  }
}