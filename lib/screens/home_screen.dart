import 'package:flutter/material.dart';

import '../app_data.dart';
import '../l10n/app_strings.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import '../widgets/responsive_design.dart';
import 'coming_soon_screen.dart';
import 'themes_screen.dart';

/// Tableau de bord : salutation personnalisée, livre lumineux, JOUER,
/// carte de progression (barre + reflet), carte succès, 4 raccourcis
/// illustrés, baseline entre l'agneau et le lion.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openThemes(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const ThemesScreen()));

  void _openComingSoon(
    BuildContext context, {
    required String title,
    required String artAsset,
    required Color color,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ComingSoonScreen(title: title, artAsset: artAsset, color: color),
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
              if (progress
                      .resultFor(theme.id, level.index, stage.index)
                      ?.passed ??
                  false) {
                passedStages++;
              }
            }
          }
        }
        final ratio = totalStages == 0 ? 0.0 : passedStages / totalStages;
        final name = progress.childName;

        return Scaffold(
          body: GameBackground(
            child: SafeArea(
              child: ResponsiveDesign(
                designWidth: 560,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Image.asset(
                              GameAssets.wordmark,
                              width: 132,
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  name == null
                                      ? 'Bienvenue !'
                                      : 'Salut $name !',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    shadows: GameTheme.textShadow,
                                  ),
                                ),
                                Text(
                                  strings.welcomeBanner.split('!').last.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDCEEFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Bob(child: Image.asset(GameAssets.glowBook, width: 230)),
                      GlowingButton(
                        tapKey: const Key('play_button'),
                        label: strings.play.toUpperCase(),
                        fontSize: 24,
                        onTap: () => _openThemes(context),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        strings.playCaption,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEAF5FF),
                        ),
                      ),
                      const SizedBox(height: 16),
                      RiseIn(
                        delay: const Duration(milliseconds: 100),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _ProgressCard(
                                  passed: passedStages,
                                  total: totalStages,
                                  ratio: ratio,
                                  strings: strings,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: _AchievementsCard(
                                  strings: strings,
                                  onTap: () => _openComingSoon(
                                    context,
                                    title: strings.myAchievements,
                                    artAsset: GameAssets.starGold,
                                    color: GameTheme.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 13),
                      RiseIn(
                        delay: const Duration(milliseconds: 220),
                        child: Row(
                          children: [
                            Expanded(
                              child: _Shortcut(
                                tapKey: const Key('themes_button'),
                                artAsset: GameAssets.bookOpen,
                                artWidth: 34,
                                label: strings.themes.toUpperCase(),
                                color: GameTheme.purpleLight,
                                onTap: () => _openThemes(context),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _Shortcut(
                                tapKey: const Key('challenges_button'),
                                artAsset: GameAssets.questionMark,
                                artWidth: 26,
                                label: strings.challenges.toUpperCase(),
                                color: GameTheme.amberLight,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.challenges,
                                  artAsset: GameAssets.questionMark,
                                  color: GameTheme.amberLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _Shortcut(
                                tapKey: const Key('leaderboard_button'),
                                artAsset: GameAssets.bulb,
                                artWidth: 30,
                                label: strings.leaderboard.toUpperCase(),
                                color: GameTheme.blueLight,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.leaderboard,
                                  artAsset: GameAssets.bulb,
                                  color: GameTheme.blueLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: _Shortcut(
                                tapKey: const Key('favorites_button'),
                                artAsset: GameAssets.flowerPink,
                                artWidth: 28,
                                label: strings.favorites.toUpperCase(),
                                color: GameTheme.pinkLight,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.favorites,
                                  artAsset: GameAssets.flowerPink,
                                  color: GameTheme.pinkLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Absorbe l'espace vertical en trop sur les écrans très
                      // allongés : garde la rangée agneau/lion ancrée près du
                      // sol au lieu de laisser un vide sous les raccourcis.
                      const Expanded(child: SizedBox.shrink()),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 94,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: Image.asset(GameAssets.lamb, width: 94),
                            ),
                          ),
                          Flexible(
                            flex: 196,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Image.asset(
                                  GameAssets.tagline,
                                  width: 196,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 90,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomRight,
                              child: Image.asset(GameAssets.lion, width: 90),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int passed;
  final int total;
  final double ratio;
  final AppStrings strings;

  const _ProgressCard({
    required this.passed,
    required this.total,
    required this.ratio,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [GameTheme.navyLight, GameTheme.navy],
        ),
        border: Border.all(color: const Color(0xFF0C2F6B), width: 3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: GameTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.myProgress, style: _cardTitle),
          Text(strings.stagesCompletedLabel, style: _cardSubtitle),
          const SizedBox(height: 11),
          Row(
            children: [
              Image.asset(GameAssets.starYellow, width: 38),
              const SizedBox(width: 9),
              Expanded(
                child: TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: passed),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$value / $total ${strings.stagesWord}',
                      maxLines: 1,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          _ShinyBar(ratio: ratio),
          const SizedBox(height: 7),
          Text(
            strings.keepGoing,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFC9DDF7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre de progression avec reflet qui la balaie.
class _ShinyBar extends StatefulWidget {
  final double ratio;

  const _ShinyBar({required this.ratio});

  @override
  State<_ShinyBar> createState() => _ShinyBarState();
}

class _ShinyBarState extends State<_ShinyBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: SizedBox(
        height: 11,
        child: Stack(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(color: GameTheme.navyDeep),
              child: SizedBox.expand(),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.ratio.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                widthFactor: value,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF9BD84B), Color(0xFF5FA61C)],
                    ),
                  ),
                  child: SizedBox.expand(),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => FractionalTranslation(
                translation: Offset(-1.2 + _c.value * 4.4, 0),
                child: FractionallySizedBox(
                  widthFactor: .4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0),
                          Colors.white.withValues(alpha: .55),
                          Colors.white.withValues(alpha: 0),
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
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

class _AchievementsCard extends StatelessWidget {
  final AppStrings strings;
  final VoidCallback onTap;

  const _AchievementsCard({required this.strings, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppData.of(context).audio.playPop();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [GameTheme.green, GameTheme.greenDark],
          ),
          border: Border.all(color: const Color(0xFF14601F), width: 3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: GameTheme.cardShadow,
        ),
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(strings.myAchievements, style: _cardTitle),
            Text(strings.discoverBadges, style: _cardSubtitle),
            const SizedBox(height: 11),
            Row(
              children: [
                Image.asset(GameAssets.starGold, width: 31),
                const SizedBox(width: 6),
                Opacity(
                  opacity: .55,
                  child: Image.asset(GameAssets.starBlue, width: 29),
                ),
                const SizedBox(width: 6),
                Opacity(
                  opacity: .55,
                  child: Image.asset(GameAssets.starPink, width: 29),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.seeAchievements,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Shortcut extends StatefulWidget {
  final String artAsset;
  final double artWidth;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Key? tapKey;

  const _Shortcut({
    required this.artAsset,
    required this.artWidth,
    required this.label,
    required this.color,
    required this.onTap,
    this.tapKey,
  });

  @override
  State<_Shortcut> createState() => _ShortcutState();
}

class _ShortcutState extends State<_Shortcut> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.tapKey,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        AppData.of(context).audio.playPop();
        widget.onTap();
      },
      child: AnimatedSlide(
        offset: Offset(0, _pressed ? .06 : 0),
        duration: const Duration(milliseconds: 90),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [widget.color, GameTheme.darken(widget.color, .14)],
            ),
            border: Border.all(
              color: GameTheme.darken(widget.color, .28),
              width: 3,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Color(0x38000000), offset: Offset(0, 5)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(4, 11, 4, 9),
          child: Column(
            children: [
              Image.asset(widget.artAsset, width: widget.artWidth),
              const SizedBox(height: 6),
              Text(
                widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _cardTitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 13,
  fontWeight: FontWeight.w900,
  color: Colors.white,
);

const _cardSubtitle = TextStyle(
  fontFamily: 'Montserrat',
  fontSize: 10.5,
  fontWeight: FontWeight.w800,
  color: GameTheme.gold,
);
