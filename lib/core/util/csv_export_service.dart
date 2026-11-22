import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../feature/quiz/model/quiz_bundle_model.dart';

class CsvExportService {
  const CsvExportService._();

  static String _quote(Object? value) {
    final escaped = (value ?? '').toString().replaceAll('"', '""');
    return '"$escaped"';
  }

  static String questions(QuizBundleModel bundle) {
    final lines = ['quiz_id,question_id,question,answer,is_correct'];
    for (final question in bundle.questions) {
      for (final answer in question.answers) {
        lines.add([
          bundle.quiz.id,
          question.id,
          question.statement,
          answer.text,
          answer.isCorrect,
        ].map(_quote).join(','));
      }
    }
    return '\uFEFF${lines.join('\r\n')}\r\n';
  }

  static String materials(QuizBundleModel bundle) {
    final lines = ['quiz_id,material_id,title,content'];
    for (final material in bundle.materials) {
      lines.add([
        bundle.quiz.id,
        material.id,
        material.title,
        material.content,
      ].map(_quote).join(','));
    }
    return '\uFEFF${lines.join('\r\n')}\r\n';
  }

  static Future<void> shareCsv(
      BuildContext context, {
        required String filename,
        required String csv,
      }) async {
    final render = context.findRenderObject();
    final origin = render is RenderBox
        ? render.localToGlobal(Offset.zero) & render.size
        : null;
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(
        Uint8List.fromList(utf8.encode(csv)),
        mimeType: 'text/csv',
      )],
      fileNameOverrides: [filename],
      title: filename,
      sharePositionOrigin: origin,
    ));
  }
}