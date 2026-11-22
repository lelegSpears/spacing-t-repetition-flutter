import 'package:flutter/material.dart';

import '../feature/category/repository/catalog_repository.dart';
import '../core/theme/colors_theme.dart';
import '../feature/home/presentation/home_page.dart';

class StrApp extends StatelessWidget {
  const StrApp({super.key, required this.repository});

  final CatalogRepository repository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SpacingTRepetition',
    debugShowCheckedModeBanner: false,
    theme: ColorsTheme.theme,
    home: HomePage(repository: repository,),
  );
}