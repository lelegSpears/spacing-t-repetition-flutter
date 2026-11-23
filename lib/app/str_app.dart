import 'package:flutter/material.dart';
import 'package:spacing_t_he_repetition/core/database/start_data_seeder.dart';
import '../core/database/app_database.dart';
import '../core/theme/colors_theme.dart';
import '../feature/category/repository/category_repository.dart';
import '../feature/home/presentation/home_page.dart';

class StrApp extends StatefulWidget {
  const StrApp({super.key});

  @override
  State<StrApp> createState() => _StrAppState();
}

class _StrAppState extends State<StrApp> {
  late final AppDatabase _db;
  late final CatalogRepository _repository;
  late final Future<void> _initialization;

  @override
  void initState() {
    super.initState();

    _db = AppDatabase();
    _repository = CatalogRepository(_db);
    _initialization = StartDataSeeder(_db).seed();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpacingTRepetition',
      debugShowCheckedModeBanner: false,
      theme: ColorsTheme.theme,

      home: FutureBuilder<void>(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SelectableText(
                    'Erro ao inicializar o aplicativo:\n'
                        '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }

          return HomePage(repository: _repository);
        },
      ),
    );
  }
}
