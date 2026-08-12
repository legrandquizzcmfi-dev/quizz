import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/quiz_theme.dart';

/// Charge le contenu des 3 onglets thématiques depuis les assets JSON (§6, §8).
///
/// Chaque thème est un fichier JSON séparé du code, pour permettre à EFDET
/// de fournir/mettre à jour les questions sans réécriture de l'application.
class ContentRepository {
  static const _themeMeta = [
    (
      asset: 'assets/data/theme_1.json',
      color: Color(0xFF4CAF50),
      icon: Icons.grass_rounded,
    ),
    (
      asset: 'assets/data/theme_2.json',
      color: Color(0xFF1E88E5),
      icon: Icons.menu_book_rounded,
    ),
    (
      asset: 'assets/data/theme_3.json',
      color: Color(0xFFFF9800),
      icon: Icons.bolt_rounded,
    ),
  ];

  Future<List<QuizTheme>> loadThemes() async {
    final themes = <QuizTheme>[];
    for (final meta in _themeMeta) {
      final raw = await rootBundle.loadString(meta.asset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      themes.add(QuizTheme.fromJson(json, color: meta.color, icon: meta.icon));
    }
    return themes;
  }
}
