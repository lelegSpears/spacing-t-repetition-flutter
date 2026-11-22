import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../model/question_draft_model.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({super.key, required this.questionCount})
      : assert(questionCount > 0);

  final int questionCount;

  @override
  State<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

class _QuestionFields {
  String statement = '';
  List<String> answers = List.filled(4, '');
  int? correctIndex;
}

class _CreateQuestionPageState extends State<CreateQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _statementController = TextEditingController();
  final _answerControllers = List.generate(4, (_) => TextEditingController());
  late final List<_QuestionFields> _drafts =
  List.generate(widget.questionCount, (_) => _QuestionFields());

  int _index = 0;
  int? _correctIndex;

  void _saveFields() {
    final current = _drafts[_index];
    current.statement = _statementController.text.trim();
    current.answers = _answerControllers.map((e) => e.text.trim()).toList();
    current.correctIndex = _correctIndex;
  }

  void _loadFields() {
    final current = _drafts[_index];
    _statementController.text = current.statement;
    for (var i = 0; i < 4; i++) {
      _answerControllers[i].text = current.answers[i];
    }
    _correctIndex = current.correctIndex;
  }

  void _previous() {
    if (_index == 0) return;
    _saveFields();
    setState(() {
      _index--;
      _loadFields();
    });
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    if (_correctIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marque a alternativa correta.')),
      );
      return;
    }
    _saveFields();

    if (_index < widget.questionCount - 1) {
      setState(() {
        _index++;
        _loadFields();
      });
      return;
    }
    final invalid = _drafts.indexWhere((q) =>
    q.statement.isEmpty ||
        q.answers.any((answer) => answer.isEmpty) ||
        q.correctIndex == null);
    if (invalid >= 0) {
      setState(() {
        _index = invalid;
        _loadFields();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Revise as questões incompletas.')),
      );
      return;
    }
    Navigator.pop(
      context,
      _drafts.map((draft) => QuestionDraftModel(
        statement: draft.statement,
        answers: List.unmodifiable(draft.answers),
        correctIndex: draft.correctIndex!,
      )).toList(),
    );
  }

  @override
  void dispose() {
    _statementController.dispose();
    for (final controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Criar questões')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(children: [
                    Text('Questão ${_index + 1} de ${widget.questionCount}',
                        style: const TextStyle(fontSize: 19,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (_index + 1) / widget.questionCount,
                      minHeight: 6,
                    ),
                  ]),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: _statementController,
                                maxLines: 3,
                                maxLength: 500,
                                decoration: const InputDecoration(
                                    labelText: 'Enunciado'),
                                validator: (value) =>
                                value == null || value.trim().isEmpty
                                    ? 'Informe a pergunta.'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              const Text('Alternativas',
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Marque a alternativa correta.'),
                              const SizedBox(height: 16),
                              ...List.generate(4, (answerIndex) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 12),
                                child: Row(children: [
                                  IconButton(
                                    tooltip: 'Alternativa correta',
                                    icon: Icon(
                                      _correctIndex == answerIndex
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      color: _correctIndex == answerIndex
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    onPressed: () => setState(() =>
                                    _correctIndex = answerIndex),
                                  ),
                                  Expanded(child: TextFormField(
                                    controller:
                                    _answerControllers[answerIndex],
                                    decoration: InputDecoration(
                                        labelText:
                                        'Alternativa ${answerIndex + 1}'),
                                    validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Preencha a alternativa.'
                                        : null,
                                  )),
                                ]),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    if (_index > 0) ...[
                      OutlinedButton(
                        onPressed: _previous,
                        child: const Text('Voltar'),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_index == widget.questionCount - 1
                          ? 'Salvar quiz'
                          : 'Próxima questão'),
                    )),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}