import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/quiz_theme.dart';

/// Charge le contenu des 4 onglets thématiques depuis les assets JSON (§6, §8).
///
/// Chaque thème est un fichier JSON séparé du code, pour permettre à EFDET
/// de fournir/mettre à jour les questions sans réécriture de l'application.
/// Chaque thème possède un fichier français (`theme_N.json`) et un fichier
/// anglais (`theme_N_en.json`).
class ContentRepository {
  static const _themeMeta = [
    (
      assetFr: 'assets/data/theme_1.json',
      assetEn: 'assets/data/theme_1_en.json',
      color: Color(0xFF4CAF50),
      icon: Icons.grass_rounded,
    ),
    (
      assetFr: 'assets/data/theme_2.json',
      assetEn: 'assets/data/theme_2_en.json',
      color: Color(0xFF1E88E5),
      icon: Icons.menu_book_rounded,
    ),
    (
      assetFr: 'assets/data/theme_3.json',
      assetEn: 'assets/data/theme_3_en.json',
      color: Color(0xFFFF9800),
      icon: Icons.bolt_rounded,
    ),
    (
      assetFr: 'assets/data/theme_4.json',
      assetEn: 'assets/data/theme_4_en.json',
      color: Color(0xFF8E24AA),
      icon: Icons.volunteer_activism_rounded,
    ),
  ];

  Future<List<QuizTheme>> loadThemes({required String languageCode}) async {
    final themes = <QuizTheme>[];
    for (final meta in _themeMeta) {
      final asset = languageCode == 'en' ? meta.assetEn : meta.assetFr;
      final raw = await rootBundle.loadString(asset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      themes.add(QuizTheme.fromJson(json, color: meta.color, icon: meta.icon));
    }
    return themes;
  }
}
