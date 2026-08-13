import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_theme.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import '../widgets/language_selector.dart';
import '../widgets/mute_button.dart';
import 'stages_screen.dart';

/// Sélection du thème (pastilles illustrées, plus d'onglets Material) puis du
/// niveau. Le décor du jeu reste visible : le contenu flotte par-dessus.
class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  int _index = 0;

  /// Illustration associée à chaque thème, dans l'ordre de
  /// `ContentRepository._themeMeta`.
  static const _themeArt = [
    GameAssets.lamb,
    GameAssets.bookOpen,
    GameAssets.bulb,
    GameAssets.dove,
  ];

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final themes = appData.themes;
    final theme = themes[_index.clamp(0, themes.length - 1)];

    return AnimatedBuilder(
      animation: appData.progress,
      builder: (context, _) => Scaffold(
        body: GameBackground(
          child: Column(
            children: [
              ScreenHeader(
                title: appData.strings.appTitle,
                color: GameTheme.navyLight,
                onBack: () => Navigator.of(context).pop(),
                actions: const [LanguageSelector(), MuteButton()],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (var i = 0; i < themes.length; i++)
                      _ThemeChip(
                        theme: themes[i],
                        artAsset: _themeArt[i % _themeArt.length],
                        selected: i == _index,
                        onTap: () => setState(() => _index = i),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          theme.title,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: theme.color,
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          theme.hasContent
                              ? 'Choisis ton niveau'
                              : appData.strings.comingSoonBody,
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEAF5FF),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: .92,
                          children: [
                            for (final level in theme.levels)
                              _LevelTile(theme: theme, level: level),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _HintCard(),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Image.asset(GameAssets.lamb, width: 76),
                            Image.asset(GameAssets.lion, width: 72),
                          ],
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

class _ThemeChip extends StatelessWidget {
  final QuizTheme theme;
  final String artAsset;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.theme,
    required this.artAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? theme.color : Colors.white,
          border: Border.all(
            color: selected
                ? GameTheme.darken(theme.color, .2)
                : const Color(0xFFCBD8E7),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(artAsset, width: 22),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                theme.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : const Color(0xFF5A6B80),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final QuizTheme theme;
  final QuizLevel level;

  const _LevelTile({required this.theme, required this.level});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final unlocked = appData.progress.isLevelUnlocked(theme, level.index);
    final stageCount = level.stages.where((s) => s.hasContent).length;

    final TileState state;
    if (!unlocked) {
      state = TileState.locked;
    } else if (!level.hasContent) {
      state = TileState.comingSoon;
    } else {
      state = TileState.available;
    }

    return ProgressTile(
      label: appData.strings.level(level.index),
      color: theme.color,
      state: state,
      delayIndex: level.index - 1,
      iconAsset: state == TileState.available
          ? GameAssets.starGold
          : GameAssets.bulb,
      subLabel: switch (state) {
        TileState.locked => 'Verrouillé',
        TileState.comingSoon => appData.strings.soon,
        _ => '$stageCount ${appData.strings.stagesWord}',
      },
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => StagesScreen(theme: theme, level: level),
        ),
      ),
    );
  }
}

class _HintCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        border: Border.all(color: GameTheme.wood, width: 3),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Image.asset(GameAssets.glowBook, width: 74),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Termine la dernière étape d'un niveau pour débloquer le niveau suivant.",
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A5B70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
