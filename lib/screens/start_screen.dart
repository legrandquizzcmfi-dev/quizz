import 'package:flutter/material.dart';

import '../app_data.dart';
import 'home_screen.dart';
import 'profile_setup_screen.dart';

/// Écran d'accueil illustré, affiché juste après le chargement de
/// l'application : image plein écran fournie par EFDET, avec une zone de
/// tap invisible calée sur le bouton « COMMENCER » dessiné dans
/// l'illustration, entourée d'une lueur animée pour attirer l'œil (§9).
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with SingleTickerProviderStateMixin {
  // Coordonnées du bouton « COMMENCER » dans assets/images/start_page.jpeg
  // (900×1600), mesurées sur l'image puis élargies légèrement pour une zone
  // de tap plus confortable pour de jeunes enfants.
  static const double _buttonLeft = 0.04;
  static const double _buttonRight = 0.02;
  static const double _buttonTop = 0.83;
  static const double _buttonBottom = 0.02;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _start(BuildContext context) {
    // Le tout premier lancement passe par « Parlons un peu de toi ! » pour
    // recueillir le prénom et l'âge de l'enfant ; les suivants vont
    // directement aux thèmes (§9).
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/images/start_page.jpeg',
                fit: BoxFit.cover,
              ),
              Positioned(
                left: constraints.maxWidth * _buttonLeft,
                right: constraints.maxWidth * _buttonRight,
                top: constraints.maxHeight * _buttonTop,
                bottom: constraints.maxHeight * _buttonBottom,
                child: Stack(
                  clipBehavior: Clip.none,
                  fit: StackFit.expand,
                  children: [
                    // Lueur pulsante autour du bouton, pour inviter à taper.
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, child) {
                        final t = _pulse.value;
                        final scale = 1.0 + t * 0.08;
                        final opacity = 0.35 + t * 0.4;
                        return Transform.scale(
                          scale: scale,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withValues(alpha: opacity),
                                  blurRadius: 24,
                                  spreadRadius: 6,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Semantics(
                      button: true,
                      label: strings.start,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('start_button'),
                          borderRadius: BorderRadius.circular(40),
                          onTap: () => _start(context),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
