import 'package:flutter/material.dart';

import 'quiz_level.dart';

/// Un onglet thématique (§5.1) : "Le Camp des Agneaux", "Le Message des 3B",
/// "Instant ZTF" (§13, point 3).
class QuizTheme {
  final String id;
  final String title;
  final Color color;
  final IconData icon;
  final List<QuizLevel> levels;

  const QuizTheme({
    required this.id,
    required this.title,
    required this.color,
    required this.icon,
    required this.levels,
  });

  bool get hasContent => levels.any((l) => l.hasContent);

  factory QuizTheme.fromJson(
    Map<String, dynamic> json, {
    required Color color,
    required IconData icon,
  }) {
    final rawLevels = json['levels'] as List? ?? const [];
    return QuizTheme(
      id: json['themeId'] as String,
      title: json['title'] as String,
      color: color,
      icon: icon,
      levels: rawLevels
          .map((l) => QuizLevel.fromJson(l as Map<String, dynamic>))
          .toList(),
    );
  }
}
