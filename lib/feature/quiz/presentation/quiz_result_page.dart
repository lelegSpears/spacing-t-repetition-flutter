import 'package:flutter/material.dart';
import '../../../core/theme/colors_theme.dart';
import '../../review/model/review_model.dart';


class QuizResultPage extends StatelessWidget {
  const QuizResultPage({
    super.key,
    required this.quizTitle,
    required this.score,
    required this.total,
    required this.review,
  });

  final String quizTitle;
  final int score;
  final int total;
  final ReviewModel review;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0 : (score * 100 / total).round();
    final date = review.nextReviewAt;
    final formatted = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: ColorsTheme.backgroundGradient),
        child: SafeArea(child: Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(22),
            children: [
              const Icon(Icons.emoji_events_outlined,
                  size: 72, color: Colors.white),
              const SizedBox(height: 16),
              Text(quizTitle, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 18),
              Card(child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  Text('$rate%', style: const TextStyle(
                      fontSize: 48, fontWeight: FontWeight.bold,
                      color: Colors.lightBlue)),
                  Text('Você acertou $score de $total questões.'),
                  const SizedBox(height: 20),
                  const Icon(Icons.event_repeat, color: Colors.lightBlue),
                  const SizedBox(height: 8),
                  const Text('Sua próxima revisão:'),
                  Text(formatted, style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold)),
                  Text('Daqui a ${review.intervalDays} dia(s).'),
                ]),
              )),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Voltar à Home'),
              ),
            ],
          ),
        ))),
      ),
    );
  }
}