import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/repository/category_repository.dart';
import '../../quiz/presentation/quiz_setup_page.dart';
import '../model/review_model.dart';

class ReviewPage extends StatelessWidget {
  const ReviewPage({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Minhas Revisões')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: StreamBuilder<List<ReviewModel>>(
        stream: repository.watchReviews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar revisões.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data!;
          if (reviews.isEmpty) {
            return const Center(child: Text(
              'Nenhuma revisão agendada.\nConclua um quiz para começar.',
              textAlign: TextAlign.center,
            ));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final date = review.nextReviewAt;
              return Card(child: ListTile(
                leading: Icon(review.isDue
                    ? Icons.notification_important_outlined
                    : Icons.calendar_today_outlined,
                    color: review.isDue ? Colors.deepOrange
                        : Colors.lightBlue),
                title: Text(review.quizTitle),
                subtitle: Text(review.isDue
                    ? 'Hora de revisar!'
                    : 'Revisão em ${date.day}/${date.month}/${date.year}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => QuizSetupPage(
                    quizId: review.quizId,
                    repository: repository,
                  ),
                )),
              ));
            },
          );
        },
      ),
    ),
  );
}