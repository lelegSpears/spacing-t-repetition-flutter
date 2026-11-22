import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../model/study_material_model.dart';

class StudyMaterialPage extends StatefulWidget {
  const StudyMaterialPage({
    super.key,
    required this.materials,
    this.onFinish,
  });

  final List<StudyMaterialModel> materials;
  final VoidCallback? onFinish;

  @override
  State<StudyMaterialPage> createState() => _StudyMaterialPageState();
}

class _StudyMaterialPageState extends State<StudyMaterialPage> {
  int currentPage = 0;

  void _next() {
    if (currentPage < widget.materials.length - 1) {
      setState(() => currentPage++);
    } else {
      if (widget.onFinish != null) {
        widget.onFinish!();
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final materials = widget.materials;
    final isEmpty = materials.isEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Material de estudo')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ColorsTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: isEmpty
                  ? const Center(child: Text('Nenhum material disponível.'))
                  : Column(children: [
                Expanded(child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Card(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(materials[currentPage].title,
                            style: const TextStyle(fontSize: 25,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        SelectableText(materials[currentPage].content,
                            style: const TextStyle(fontSize: 16, height: 1.65)),
                      ],
                    ),
                  )),
                )),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        tooltip: 'Anterior',
                        onPressed: currentPage > 0
                            ? () => setState(() => currentPage--)
                            : null,
                        icon: const Icon(Icons.arrow_back_ios),
                      ),
                      Text('${currentPage + 1} / ${materials.length}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 17)),
                      IconButton(
                        tooltip: currentPage == materials.length - 1
                            ? 'Concluir' : 'Próximo',
                        onPressed: _next,
                        icon: Icon(currentPage == materials.length - 1
                            ? Icons.check_circle_outline
                            : Icons.arrow_forward_ios),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}