import 'package:flutter/material.dart';

import '../model/category_draft_model.dart';

// Formulário simples: seu estado é mantido pelo próprio Form.
class CreateCategoryWidget extends StatelessWidget {
  const CreateCategoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    String name = '';
    String description = '';

    return Form(
      child: Builder(
        builder: (formContext) => AlertDialog(
          title: const Text('Nova categoria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  autofocus: true,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Informe um nome.'
                      : null,
                  onSaved: (value) => name = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  maxLines: 3,
                  maxLength: 200,
                  decoration: const InputDecoration(labelText: 'Descrição'),
                  onSaved: (value) => description = value?.trim() ?? '',
                ),
              ],
            ),
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
                Navigator.pop(
                  formContext,
                  CategoryDraftModel(
                    name: name,
                    description: description,
                  ),
                );
              },
              child: const Text('Criar'),
            ),
          ],
        ),
      ),
    );
  }
}