import 'package:flutter/material.dart';
import 'package:spacing_t_he_repetition/core/theme/colors_theme.dart';
import 'package:spacing_t_he_repetition/feature/home/presentation/home_page.dart';

class StrApp extends StatelessWidget{
  const StrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpacingTRepetition',
      debugShowCheckedModeBanner: false,
      theme: ColorsTheme.theme,
      home: HomePage(),
    );
  }

}