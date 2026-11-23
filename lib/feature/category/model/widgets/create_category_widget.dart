import 'package:flutter/material.dart';

import '../category_draft_model.dart';
import '../category_model.dart';

/// O mesmo formulário serve para criar e editar uma categoria.
class CreateCategoryWidget extends StatelessWidget {
  const CreateCategoryWidget({super.key, this.category});

  final CategoryModel? category;

  @override
  Widget build(BuildContext context) {
    String name = category?.name ?? '';
    String description = category?.description ?? '';

    return Form(
      child: Builder(
        builder: (formContext) => AlertDialog(
          title: Text(category == null ? 'Nova categoria' : 'Editar categoria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: category?.name,
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
                  initialValue: category?.description,
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
                  CategoryDraftModel(name: name, description: description),
                );
              },
              child: Text(category == null ? 'Criar' : 'Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}