import 'package:flutter/material.dart';

import '../app_data.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';

/// Écran « bientôt disponible » (Défis, Classements, Favoris, Succès) :
/// même décor que le reste du jeu, illustration qui flotte.
///
/// ⚠ Signature modifiée : `IconData icon` devient `String artAsset`.
/// Les appels se font depuis HomeScreen avec les assets illustrés.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final String artAsset;
  final Color color;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.artAsset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            ScreenHeader(
              title: title,
              color: color,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Bob(child: Image.asset(artAsset, width: 110)),
                      const SizedBox(height: 18),
                      Text(
                        strings.featureComingSoon,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          height: 1.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: GameTheme.textShadow,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
