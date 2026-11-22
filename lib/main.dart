import 'package:flutter/material.dart';

import 'app/str_app.dart';
import 'core/database/app_database.dart';
import 'feature/category/repository/catalog_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Um banco e um repositório compartilhados durante toda a sessão.
  final database = AppDatabase();
  final repository = CatalogRepository(database);
  runApp(StrApp(repository: repository));
}