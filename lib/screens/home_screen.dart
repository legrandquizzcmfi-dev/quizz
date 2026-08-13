import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_theme.dart';
import '../widgets/language_selector.dart';
import '../widgets/progress_tile.dart';
import 'stages_screen.dart';

/// Écran d'accueil : navigation par onglets (un par thème), puis sélection
/// de niveau à l'intérieur de l'onglet (§5.2).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final themes = appData.themes;

    return DefaultTabController(
      length: themes.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(appData.strings.appTitle),
          actions: const [LanguageSelector()],
          bottom: TabBar(
            tabs: [
              for (final theme in themes)
                Tab(icon: Icon(theme.icon), text: theme.title),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final theme in themes) _LevelsTab(theme: theme),
          ],
        ),
      ),
    );
  }
}

class _LevelsTab extends StatelessWidget {
  final QuizTheme theme;

  const _LevelsTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final progress = appData.progress;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Container(
          color: theme.color.withValues(alpha: 0.08),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                theme.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.color,
                    ),
              ),
              const SizedBox(height: 4),
              if (!theme.hasContent)
                Text(
                  appData.strings.comingSoonBody,
                  style: const TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    for (final level in theme.levels)
                      _LevelCard(theme: theme, level: level),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LevelCard extends StatelessWidget {
  final QuizTheme theme;
  final QuizLevel level;

  const _LevelCard({required this.theme, required this.level});

  @override
  Widget build(BuildContext context) {
    final progress = AppData.of(context).progress;
    final unlocked = progress.isLevelUnlocked(theme, level.index);

    final TileState state;
    if (!unlocked) {
      state = TileState.locked;
    } else if (!level.hasContent) {
      state = TileState.comingSoon;
    } else {
      state = TileState.available;
    }

    return ProgressTile(
      label: AppData.of(context).strings.level(level.index),
      icon: Icons.flag_rounded,
      color: theme.color,
      state: state,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StagesScreen(theme: theme, level: level),
          ),
        );
      },
    );
  }
}
