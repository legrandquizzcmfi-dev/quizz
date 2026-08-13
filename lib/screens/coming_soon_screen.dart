import 'package:flutter/material.dart';

import '../app_data.dart';

/// Écran générique « bientôt disponible », utilisé pour les sections du
/// tableau de bord pas encore développées (Défis, Classements, Favoris) —
/// même esprit que les vignettes « Bientôt » déjà utilisées pour les
/// niveaux/étapes sans contenu (§9).
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: color,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 96, color: color),
              const SizedBox(height: 24),
              Text(
                strings.featureComingSoon,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
