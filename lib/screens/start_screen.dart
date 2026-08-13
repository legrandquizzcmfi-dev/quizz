import 'package:flutter/material.dart';

import '../app_data.dart';
import '../widgets/glowing_button.dart';
import '../widgets/starry_background.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

/// Écran d'accueil, affiché juste après le chargement de l'application :
/// entièrement natif (fond étoilé animé + logo + bouton), donc pleinement
/// responsive (téléphone comme tablette) et chaque élément s'anime pour
/// lui-même, plutôt qu'une illustration figée avec une simple zone de tap
/// invisible par-dessus (§9).
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _start(BuildContext context) {
    // Le tout premier lancement passe par « Parlons un peu de toi ! » pour
    // recueillir le prénom et l'âge de l'enfant ; les suivants vont
    // directement au tableau de bord (§9).
    final hasProfile = AppData.of(context).progress.hasProfile;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasProfile ? const HomeScreen() : const ProfileSetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      body: StarryBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/icon/icon.png', width: 240),
                    const SizedBox(height: 12),
                    Text(
                      strings.welcomeBanner,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 44),
                    GlowingButton(
                      tapKey: const Key('start_button'),
                      label: strings.start,
                      color: const Color(0xFFFFA726),
                      trailingIcon: Icons.arrow_forward_rounded,
                      onTap: () => _start(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
