import 'package:flutter/material.dart';
import '../../../core/theme/colors_theme.dart';

import '../category/repository/catalog_repository.dart';
import '../quiz/model/review_model.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _changeMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta);
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meu Perfil')),
    body: Container(
      decoration: const BoxDecoration(
        gradient: ColorsTheme.backgroundGradient,
      ),
      child: StreamBuilder<List<AttemptModel>>(
        stream: widget.repository.watchAttempts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar histórico.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final attempts = snapshot.data!;
          final studied = attempts
              .map((a) => DateUtils.dateOnly(a.completedAt))
              .toSet();
          final average = attempts.isEmpty
              ? null
              : (attempts.map((a) => a.correct / a.total).reduce((a, b) => a + b)
              / attempts.length * 100)
              .round();
          final offset = DateTime(_month.year, _month.month).weekday % 7;
          final days = DateUtils.getDaysInMonth(_month.year, _month.month);
          return Center(child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(padding: const EdgeInsets.all(20), children: [
              const CircleAvatar(radius: 33, backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 37, color: Colors.lightBlue)),
              const SizedBox(height: 10),
              const Center(child: Text('Estudante offline',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold))),
              const SizedBox(height: 18),
              Card(child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _stat('Dias estudados', '${studied.length}'),
                      _stat('Quizzes feitos', '${attempts.length}'),
                      _stat('Média de acertos', average == null ? '—' : '$average%'),
                    ]),
              )),
              const SizedBox(height: 15),
              Card(child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(children: [
                  Row(children: [
                    IconButton(
                      tooltip: 'Mês anterior',
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(child: Text(
                      '${_month.month.toString().padLeft(2, '0')}/${_month.year}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 19,
                          fontWeight: FontWeight.bold),
                    )),
                    IconButton(
                      tooltip: 'Próximo mês',
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ]),
                  Row(children: const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                      .map((day) => Expanded(child: Center(child: Text(day))))
                      .toList()),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: offset + days,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      if (index < offset) return const SizedBox.shrink();
                      final n = index - offset + 1;
                      final day = DateTime(_month.year, _month.month, n);
                      final wasStudied = studied.contains(day);
                      return Container(
                        decoration: BoxDecoration(
                          color: wasStudied
                              ? Colors.lightBlue.shade200
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text('$n',
                          style: TextStyle(
                            fontWeight: wasStudied
                                ? FontWeight.bold : FontWeight.normal,
                          ),
                        )),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.circle, color: Colors.lightBlue, size: 12),
                        SizedBox(width: 7),
                        Text('Dia com quiz concluído'),
                      ]),
                ]),
              )),
            ]),
          ));
        },
      ),
    ),
  );

  Widget _stat(String label, String value) => Expanded(child: Column(
    children: [
      Text(value, style: const TextStyle(fontSize: 20,
          fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 11)),
    ],
  ));
}