import 'package:flutter/material.dart';

import '../app_data.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

/// Écran d'accueil (splash jouable) : décor animé, logo, baseline, livre
/// lumineux, bouton COMMENCER, les deux enfants en bas.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  void _start(BuildContext context) {
    final hasProfile = AppData.of(context).progress.hasProfile;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) =>
            hasProfile ? const HomeScreen() : const ProfileSetupScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;

    return Scaffold(
      body: GameBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(GameAssets.wordmark, width: 300),
                        const SizedBox(height: 0),
                        Transform.translate(
                          offset: const Offset(0, -14),
                          child: Image.asset(GameAssets.tagline, width: 280),
                        ),
                        Bob(
                          period: const Duration(seconds: 5),
                          child: Image.asset(GameAssets.glowBook, width: 238),
                        ),
                        const SizedBox(height: 14),
                        GlowingButton(
                          tapKey: const Key('start_button'),
                          label: strings.start.toUpperCase(),
                          fontSize: 23,
                          onTap: () => _start(context),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                  Positioned(
                    left: -18,
                    bottom: 36,
                    child: Sway(
                      period: const Duration(milliseconds: 4600),
                      child: Image.asset(GameAssets.kidBoy, width: 150),
                    ),
                  ),
                  Positioned(
                    right: -24,
                    bottom: 34,
                    child: Sway(
                      period: const Duration(milliseconds: 5400),
                      child: Image.asset(GameAssets.kidGirl, width: 174),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
