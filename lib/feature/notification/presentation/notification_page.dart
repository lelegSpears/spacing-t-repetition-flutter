import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/repository/catalog_repository.dart';
import '../../quiz/model/review_model.dart';
import '../../quiz/presentation/quiz_setup_page.dart';

// Central de avisos do MVP: mostra revisões vencidas quando o app é aberto
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Notificações')),
    body: Container(
      decoration: const BoxDecoration(
          gradient: ColorsTheme.backgroundGradient),
      child: StreamBuilder<List<ReviewModel>>(
        stream: repository.watchReviews(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar avisos.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final due = snapshot.data!.where((r) => r.isDue).toList();
          if (due.isEmpty) {
            return const Center(child: Text(
              'Nenhuma revisão pendente por enquanto.',
              textAlign: TextAlign.center,
            ));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: due.length,
            itemBuilder: (context, index) {
              final review = due[index];
              return Card(child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.deepOrange),
                title: Text('Hora de revisar ${review.quizTitle}'),
                subtitle: const Text('Toque para iniciar a revisão.'),
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