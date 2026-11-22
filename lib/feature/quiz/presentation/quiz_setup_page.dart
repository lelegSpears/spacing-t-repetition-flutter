import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../../core/util/csv_export_service.dart';
import '../../StudyMaterial/model/study_material_draft_model.dart';
import '../../StudyMaterial/presentation/study_material_page.dart';
import '../../StudyMaterial/presentation/widgets/create_study_material_widget.dart';
import '../../category/repository/catalog_repository.dart';
import '../model/quiz_bundle_model.dart';
import 'quiz_page.dart';

class QuizSetupPage extends StatefulWidget {
  const QuizSetupPage({
    super.key,
    required this.quizId,
    required this.repository,
  });

  final int quizId;
  final CatalogRepository repository;

  @override
  State<QuizSetupPage> createState() => _QuizSetupPageState();
}

class _QuizSetupPageState extends State<QuizSetupPage> {
  late Future<QuizBundleModel> _bundleFuture;
  int? _questionCount;
  int? _materialCount;
  bool _classMode = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _bundleFuture = widget.repository.loadQuiz(widget.quizId);
  }

  Future<void> _addMaterial() async {
    final draft = await showDialog<StudyMaterialDraftModel>(
      context: context,
      builder: (_) => const CreateStudyMaterialWidget(),
    );
    if (draft == null) return;
    try {
      await widget.repository.createStudyMaterial(
        quizId: widget.quizId,
        title: draft.title,
        content: draft.content,
      );
      if (mounted) setState(_refresh);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $error')),
      );
    }
  }

  void _start(QuizBundleModel bundle, int questionCount, int materialCount) {
    final questions = bundle.questions.take(questionCount).toList();
    final quiz = QuizPage(
      bundle: bundle,
      questions: questions,
      repository: widget.repository,
    );
    if (_classMode && materialCount > 0) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => StudyMaterialPage(
          materials: bundle.materials.take(materialCount).toList(),
          onFinish: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => quiz)),
        ),
      ));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => quiz));
    }
  }

  Future<void> _share(String filename, String data) async {
    try {
      await CsvExportService.shareCsv(context, filename: filename, csv: data);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao compartilhar CSV: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Preparar quiz')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: FutureBuilder<QuizBundleModel>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar quiz.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final bundle = snapshot.data!;
          final total = bundle.questions.length;
          final materialTotal = bundle.materials.length;
          final questionCount = (_questionCount ?? total).clamp(1, total).toInt();
          final materialCount = materialTotal == 0
              ? 0
              : (_materialCount ?? materialTotal).clamp(1, materialTotal).toInt();
          return Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              Text(bundle.quiz.title,
                  style: const TextStyle(fontSize: 25,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(bundle.quiz.description),
              const SizedBox(height: 18),
              Card(child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantidade de questões: $questionCount de $total',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: questionCount.toDouble(),
                      min: 1,
                      max: total.toDouble(),
                      divisions: total <= 1 ? null : total - 1,
                      onChanged: total <= 1 ? null : (value) =>
                          setState(() => _questionCount = value.round()),
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Modo Class'),
                      subtitle: const Text('Ler resumos antes do quiz'),
                      value: _classMode && materialTotal > 0,
                      onChanged: materialTotal == 0 ? null :
                          (value) => setState(() => _classMode = value),
                    ),
                    if (_classMode && materialTotal > 0) ...[
                      Text('Materiais: $materialCount de $materialTotal'),
                      Slider(
                        value: materialCount.toDouble(),
                        min: 1,
                        max: materialTotal.toDouble(),
                        divisions: materialTotal <= 1 ? null : materialTotal - 1,
                        onChanged: materialTotal <= 1 ? null : (value) =>
                            setState(() => _materialCount = value.round()),
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(
                      onPressed: () => _start(bundle, questionCount, materialCount),
                      icon: const Icon(Icons.play_arrow),
                      label: Text(_classMode && materialTotal > 0
                          ? 'Ler e começar' : 'Iniciar quiz'),
                    )),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: Text('Materiais de estudo',
                    style: TextStyle(fontSize: 18,
                        fontWeight: FontWeight.bold))),
                IconButton(
                  tooltip: 'Adicionar material',
                  onPressed: _addMaterial,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ]),
              if (bundle.materials.isEmpty)
                const Card(child: ListTile(title: Text(
                    'Nenhum material. Use o botão + para adicionar.')))
              else
                ...bundle.materials.map((m) => Card(child: ListTile(
                  title: Text(m.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => StudyMaterialPage(
                      materials: bundle.materials,
                    ),
                  )),
                ))),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _share('quiz_${bundle.quiz.id}_questoes.csv',
                    CsvExportService.questions(bundle)),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar questões CSV'),
              ),
              OutlinedButton.icon(
                onPressed: bundle.materials.isEmpty ? null : () => _share(
                    'quiz_${bundle.quiz.id}_materiais.csv',
                    CsvExportService.materials(bundle)),
                icon: const Icon(Icons.file_download_outlined),
                label: const Text('Exportar materiais CSV'),
              ),
            ]),
          ));
        },
      ),
    ),
  );
}