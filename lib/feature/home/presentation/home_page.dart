import 'package:flutter/material.dart';

import '../../../core/theme/colors_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpacingTRepetition'),
      ),

      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: ColorsTheme.backgroundGradient,
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

                ElevatedButton.icon(  // Implementar navegação de Quizzes
                  onPressed: () {
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Explorar Quizzes'),
                ),

                const SizedBox(height: 15),

                ElevatedButton.icon( // Implementar para a tela de revisões.
                  onPressed: () {
                  },
                  icon: const Icon(Icons.book),
                  label: const Text('Minhas Revisões'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}