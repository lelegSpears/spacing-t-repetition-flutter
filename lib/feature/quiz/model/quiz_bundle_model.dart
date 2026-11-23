import 'package:spacing_t_he_repetition/feature/quiz/model/question/question_model.dart';

import '../../studymaterial/model/study_material_model.dart';
import 'quiz_model.dart';

class QuizBundleModel {
  const QuizBundleModel({
    required this.quiz,
    required this.questions,
    required this.materials,
  });

  final QuizModel quiz;
  final List<QuestionModel> questions;
  final List<StudyMaterialModel> materials;
}