import 'package:flutter/material.dart';

import '../../model/study_material_draft_model.dart';

class CreateStudyMaterialWidget extends StatelessWidget {
  const CreateStudyMaterialWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String title = '';
    String content = '';
    return Form(
      child: Builder(builder: (formContext) => AlertDialog(
        title: const Text('Novo material'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe um título.'
                    : null,
                onSaved: (value) => title = value?.trim() ?? '',
              ),
              const SizedBox(height: 12),
              TextFormField(
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
            child: const Text('Adicionar'),
          ),
        ],
      )),
    );
  }
}