import 'package:flutter/material.dart';

import '../../model/study_material_draft.dart';
import '../../model/study_material_model.dart';

class CreateStudyMaterialWidget extends StatelessWidget {
  const CreateStudyMaterialWidget({super.key, this.material});

  final StudyMaterialModel? material;

  @override
  Widget build(BuildContext context) {
    String title = material?.title ?? '';
    String content = material?.content ?? '';
    return Form(
      child: Builder(builder: (formContext) => AlertDialog(
        title: Text(material == null ? 'Novo material' : 'Editar material'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: material?.title,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título.'
                    : null,
                onSaved: (value) => title = value?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: material?.content,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Texto do material'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe o texto.'
                    : null,
                onSaved: (value) => content = value?.trim() ?? '',
              ),
            ],
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(formContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final form = Form.of(formContext);
              if (!form.validate()) return;
              form.save();
              Navigator.pop(formContext,
                  StudyMaterialDraftModel(title: title, content: content));
            },
            child: Text(material == null ? 'Adicionar' : 'Salvar'),
          ),
        ],
      )),
    );
  }
}