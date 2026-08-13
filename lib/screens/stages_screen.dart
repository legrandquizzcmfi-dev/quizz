import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_theme.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import 'quiz_screen.dart';

/// Grille des 12 étapes d'un niveau, avec légende en bas de page pour que
/// l'écran ne se termine pas sur du vide.
class StagesScreen extends StatelessWidget {
  final QuizTheme theme;
  final QuizLevel level;

  const StagesScreen({super.key, required this.theme, required this.level});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final progress = appData.progress;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) => Scaffold(
        body: GameBackground(
          child: Column(
            children: [
              ScreenHeader(
                title: appData.strings.levelTitle(theme.title, level.index),
                color: theme.color,
                onBack: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: level.stages.isEmpty
                        ? Center(
                            child: Text(
                              appData.strings.levelEmptyBody,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                children: [
                                  for (final stage in level.stages)
                                    Builder(builder: (context) {
                                      final unlocked = progress.isStageUnlocked(
                                          theme, level.index, stage.index);
                                      final result = progress.resultFor(
                                          theme.id, level.index, stage.index);

                                      final TileState state;
                                      if (!unlocked) {
                                        state = TileState.locked;
                                      } else if (!stage.hasContent) {
                                        state = TileState.comingSoon;
                                      } else if (result != null) {
                                        state = TileState.completed;
                                      } else {
                                        state = TileState.available;
                                      }

                                      return ProgressTile(
                                        label: '${stage.index}',
                                        color: theme.color,
                                        state: state,
                                        stars: result?.stars ?? 0,
                                        delayIndex: stage.index - 1,
                                        onTap: () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => QuizScreen(
                                              theme: theme,
                                              level: level,
                                              stage: stage,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                              const Spacer(),
                              const _Legend(),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Image.asset(GameAssets.lamb, width: 74),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        border: Border.all(color: GameTheme.wood, width: 3),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          _swatch(GameTheme.green, 'Réussie'),
          const SizedBox(width: 14),
          _swatch(GameTheme.locked, 'Verrouillée'),
          const Spacer(),
          Image.asset(GameAssets.starYellow, width: 18),
          const SizedBox(width: 6),
          const Text('3 étoiles = sans faute', style: _legendText),
        ],
      ),
    );
  }

  Widget _swatch(Color color, String label) => Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
          ),
          const SizedBox(width: 6),
          Text(label, style: _legendText),
        ],
      );
}

const _legendText = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: Color(0xFF4A5B70),
);
