import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_theme.dart';
import '../widgets/progress_tile.dart';
import 'quiz_screen.dart';

/// Sélection d'étape à l'intérieur d'un niveau : 12 étapes, déblocage
/// progressif, indicateur de progression (§5.2).
class StagesScreen extends StatelessWidget {
  final QuizTheme theme;
  final QuizLevel level;

  const StagesScreen({super.key, required this.theme, required this.level});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final progress = appData.progress;

    return Scaffold(
      appBar: AppBar(
        title: Text(appData.strings.levelTitle(theme.title, level.index)),
        backgroundColor: theme.color,
      ),
      body: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          if (level.stages.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  appData.strings.levelEmptyBody,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ),
            );
          }

          return GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 4,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: [
              for (final stage in level.stages)
                Builder(builder: (context) {
                  final unlocked =
                      progress.isStageUnlocked(theme, level.index, stage.index);
                  final result =
                      progress.resultFor(theme.id, level.index, stage.index);

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
                    icon: Icons.emoji_events_rounded,
                    color: theme.color,
                    state: state,
                    stars: result?.stars ?? 0,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            theme: theme,
                            level: level,
                            stage: stage,
                          ),
                        ),
                      );
                    },
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
