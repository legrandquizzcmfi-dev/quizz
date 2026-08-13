import 'package:flutter/material.dart';

import '../app_data.dart';
import 'coming_soon_screen.dart';
import 'themes_screen.dart';

/// Tableau de bord, affiché après le premier lancement (ou juste après avoir
/// renseigné son profil) : illustration plein écran fournie par EFDET, avec
/// le bouton « JOUER » et les 4 raccourcis (Thèmes, Défis, Classements,
/// Favoris) rendus cliquables par-dessus, plus la vraie progression de
/// l'enfant superposée sur la carte « Ma progression » (§9).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Coordonnées mesurées sur assets/images/default_screen.jpeg (900×1600).
  static const double _playLeft = 0.1556;
  static const double _playTop = 0.4938;
  static const double _playRight = 0.1722;
  static const double _playBottom = 0.4125;

  static const double _rowTop = 0.8406;
  static const double _rowBottom = 0.0875;
  static const double _themesLeft = 0.0911;
  static const double _themesRight = 0.7356;
  static const double _challengesLeft = 0.2989;
  static const double _challengesRight = 0.5178;
  static const double _leaderboardLeft = 0.5178;
  static const double _leaderboardRight = 0.3033;
  static const double _favoritesLeft = 0.7333;
  static const double _favoritesRight = 0.0922;

  static const double _statBoxLeft = 0.1444;
  static const double _statBoxTop = 0.6750;
  static const double _statBoxRight = 0.5156;
  static const double _statBoxBottom = 0.2288;

  static const double _barLeft = 0.0267;
  static const double _barTop = 0.7770;
  static const double _barRight = 0.5220;
  static const double _barBottom = 0.2075;

  void _openThemes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ThemesScreen()),
    );
  }

  void _openComingSoon(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ComingSoonScreen(title: title, icon: icon, color: color),
      ),
    );
  }

  Widget _tapArea(
    BuildContext context, {
    required double width,
    required double height,
    required double left,
    required double top,
    required double right,
    required double bottom,
    required String label,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Positioned(
      left: width * left,
      top: height * top,
      right: width * right,
      bottom: height * bottom,
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: key,
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final strings = appData.strings;
    final progress = appData.progress;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        var totalStages = 0;
        var passedStages = 0;
        for (final theme in appData.themes) {
          for (final level in theme.levels) {
            for (final stage in level.stages) {
              if (!stage.hasContent) continue;
              totalStages++;
              if (progress.resultFor(theme.id, level.index, stage.index)?.passed ?? false) {
                passedStages++;
              }
            }
          }
        }
        final ratio = totalStages == 0 ? 0.0 : passedStages / totalStages;

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final height = constraints.maxHeight;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/default_screen.jpeg',
                    fit: BoxFit.cover,
                  ),
                  // « Ma progression » : les vrais chiffres de l'enfant, par-dessus
                  // le « 18 / 36 » dessiné dans l'illustration.
                  Positioned(
                    left: width * _statBoxLeft,
                    top: height * _statBoxTop,
                    right: width * _statBoxRight,
                    bottom: height * _statBoxBottom,
                    child: Semantics(
                      label: strings.stagesCompleted(passedStages, totalStages),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFF02316D),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$passedStages / $totalStages',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  strings.stagesWord,
                                  style: const TextStyle(color: Colors.white, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: width * _barLeft,
                    top: height * _barTop,
                    right: width * _barRight,
                    bottom: height * _barBottom,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF001A46),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ratio.clamp(0.0, 1.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8CD44A), Color(0xFF5A9A1E)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _tapArea(
                    context,
                    width: width,
                    height: height,
                    left: _playLeft,
                    top: _playTop,
                    right: _playRight,
                    bottom: _playBottom,
                    label: strings.play,
                    key: const Key('play_button'),
                    onTap: () => _openThemes(context),
                  ),
                  _tapArea(
                    context,
                    width: width,
                    height: height,
                    left: _themesLeft,
                    top: _rowTop,
                    right: _themesRight,
                    bottom: _rowBottom,
                    label: strings.themes,
                    key: const Key('themes_button'),
                    onTap: () => _openThemes(context),
                  ),
                  _tapArea(
                    context,
                    width: width,
                    height: height,
                    left: _challengesLeft,
                    top: _rowTop,
                    right: _challengesRight,
                    bottom: _rowBottom,
                    label: strings.challenges,
                    key: const Key('challenges_button'),
                    onTap: () => _openComingSoon(
                      context,
                      title: strings.challenges,
                      icon: Icons.track_changes_rounded,
                      color: const Color(0xFFFF9800),
                    ),
                  ),
                  _tapArea(
                    context,
                    width: width,
                    height: height,
                    left: _leaderboardLeft,
                    top: _rowTop,
                    right: _leaderboardRight,
                    bottom: _rowBottom,
                    label: strings.leaderboard,
                    key: const Key('leaderboard_button'),
                    onTap: () => _openComingSoon(
                      context,
                      title: strings.leaderboard,
                      icon: Icons.leaderboard_rounded,
                      color: const Color(0xFF1E88E5),
                    ),
                  ),
                  _tapArea(
                    context,
                    width: width,
                    height: height,
                    left: _favoritesLeft,
                    top: _rowTop,
                    right: _favoritesRight,
                    bottom: _rowBottom,
                    label: strings.favorites,
                    key: const Key('favorites_button'),
                    onTap: () => _openComingSoon(
                      context,
                      title: strings.favorites,
                      icon: Icons.favorite_rounded,
                      color: const Color(0xFFEC407A),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
