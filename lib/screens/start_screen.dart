import 'package:flutter/material.dart';

import '../app_data.dart';
import 'home_screen.dart';

/// Écran d'accueil illustré, affiché juste après le chargement de
/// l'application : image plein écran fournie par EFDET, avec une zone de
/// tap invisible calée sur le bouton « COMMENCER » dessiné dans
/// l'illustration (§9).
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  // Coordonnées du bouton « COMMENCER » dans assets/images/start_page.jpeg
  // (900×1600), mesurées sur l'image puis élargies légèrement pour une zone
  // de tap plus confortable pour de jeunes enfants.
  static const double _buttonLeft = 0.04;
  static const double _buttonRight = 0.02;
  static const double _buttonTop = 0.83;
  static const double _buttonBottom = 0.02;

  void _start(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
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
                child: Semantics(
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
              ),
            ],
          );
        },
      ),
    );
  }
}
