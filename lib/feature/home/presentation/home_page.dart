
import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';
import '../../category/presentation/category_page.dart';
import '../../category/repository/category_repository.dart';
import '../../notification/presentation/notification_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../review/presentation/review_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.repository,
  });

  final CatalogRepository repository;

  void _go(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpacingTRepetition'),

        actions: [
          // Notificações no canto superior direito
          IconButton(
            tooltip: 'Notificações',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => _go(
              context,
              NotificationsPage(repository: repository),
            ),
          ),

          // Perfil no canto superior direito
          IconButton(
            tooltip: 'Meu Perfil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => _go(
              context,
              ProfilePage(repository: repository),
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: ColorsTheme.backgroundGradient,
        ),

        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),

              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),

                children: [
                  const Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: Colors.white,
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Bem-vindo ao SpacingTRepetition!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Estude no seu ritmo e revise seus conhecimentos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 35),

                  ElevatedButton.icon(
                    onPressed: () => _go(
                      context,
                      CategoryPage(repository: repository),
                    ),
                    icon: const Icon(Icons.quiz_outlined),
                    label: const Text('Explorar Quizzes'),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: () => _go(
                      context,
                      ReviewPage(repository: repository),
                    ),
                    icon: const Icon(Icons.book),
                    label: const Text('Minhas Revisões'),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton.icon(
                    onPressed: () => _go(
                      context,
                      CategoryPage(
                        repository: repository,
                        materialsOnly: true,
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Materiais de estudo'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
