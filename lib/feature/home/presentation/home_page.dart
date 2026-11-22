import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/presentation/category_page.dart';
import '../../category/repository/catalog_repository.dart';
import '../../notification/presentation/notification_page.dart';
import '../../profile/profile_page.dart';
import '../../review/presentation/review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.repository});

  final CatalogRepository repository;

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SpacingTRepetition'),
      actions: [
        IconButton(
          tooltip: 'Notificações',
          onPressed: () => _open(
            context,
            NotificationsPage(repository: repository),
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
        IconButton(
          tooltip: 'Perfil',
          onPressed: () => _open(
            context,
            ProfilePage(repository: repository),
          ),
          icon: const Icon(Icons.person_outline_rounded),
        ),
      ],
    ),
    body: Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.menu_book_rounded,
                    size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Bem-vindo ao SpacingTRepetition!',
                  textAlign: TextAlign.center,
                  style:
                  TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Estude no seu ritmo e revise seus conhecimentos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 35),
                ElevatedButton.icon(
                  onPressed: () => _open(
                    context,
                    CategoryPage(repository: repository),
                  ),
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Explorar Quizzes'),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => _open(
                    context,
                    ReviewPage(repository: repository),
                  ),
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Minhas Revisões'),
                ),
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: () => _open(
                    context,
                    CategoryPage(
                      repository: repository,
                      materialsOnly: true,
                    ),
                  ),
                  icon: const Icon(Icons.book_outlined),
                  label: const Text('Material de Estudo'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}