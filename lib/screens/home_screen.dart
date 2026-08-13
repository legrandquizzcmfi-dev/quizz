import 'package:flutter/material.dart';

import '../app_data.dart';
import '../l10n/app_strings.dart';
import '../widgets/glowing_button.dart';
import '../widgets/starry_background.dart';
import 'coming_soon_screen.dart';
import 'themes_screen.dart';

/// Tableau de bord, affiché après le premier lancement (ou juste après avoir
/// renseigné son profil) : entièrement natif (fond étoilé + carte de
/// progression + raccourcis), donc pleinement responsive (téléphone comme
/// tablette) et chaque carte/bouton s'anime indépendamment — contrairement à
/// une illustration plein écran figée avec des zones de tap superposées
/// (§9).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          body: StarryBackground(
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        Image.asset('assets/icon/icon.png', width: 130),
                        const SizedBox(height: 8),
                        Text(
                          strings.welcomeBanner,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GlowingButton(
                          tapKey: const Key('play_button'),
                          label: strings.play,
                          color: const Color(0xFFFFA726),
                          trailingIcon: Icons.arrow_forward_rounded,
                          onTap: () => _openThemes(context),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          strings.playCaption,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        IntrinsicHeight(
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AchievementsCard(
                                  strings: strings,
                                  onTap: () => _openComingSoon(
                                    context,
                                    title: strings.myAchievements,
                                    icon: Icons.emoji_events_rounded,
                                    color: const Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _ShortcutButton(
                                tapKey: const Key('themes_button'),
                                icon: Icons.menu_book_rounded,
                                label: strings.themes,
                                color: const Color(0xFF8E24AA),
                                delayIndex: 0,
                                onTap: () => _openThemes(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ShortcutButton(
                                tapKey: const Key('challenges_button'),
                                icon: Icons.track_changes_rounded,
                                label: strings.challenges,
                                color: const Color(0xFFFF9800),
                                delayIndex: 1,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.challenges,
                                  icon: Icons.track_changes_rounded,
                                  color: const Color(0xFFFF9800),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ShortcutButton(
                                tapKey: const Key('leaderboard_button'),
                                icon: Icons.leaderboard_rounded,
                                label: strings.leaderboard,
                                color: const Color(0xFF1E88E5),
                                delayIndex: 2,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.leaderboard,
                                  icon: Icons.leaderboard_rounded,
                                  color: const Color(0xFF1E88E5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ShortcutButton(
                                tapKey: const Key('favorites_button'),
                                icon: Icons.favorite_rounded,
                                label: strings.favorites,
                                color: const Color(0xFFEC407A),
                                delayIndex: 3,
                                onTap: () => _openComingSoon(
                                  context,
                                  title: strings.favorites,
                                  icon: Icons.favorite_rounded,
                                  color: const Color(0xFFEC407A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          strings.tagline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
    return Semantics(
      label: strings.stagesCompleted(passed, total),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1B3B7A),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.myProgress,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                strings.stagesCompletedLabel,
                style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B1E3D),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFFFFD54F), size: 26),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: passed),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '$value / $total',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      minHeight: 10,
                      backgroundColor: const Color(0xFF0B1E3D),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF7CB518)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.keepGoing,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
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
    return Material(
      color: const Color(0xFF2E7D32),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.myAchievements,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                strings.discoverBadges,
                style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD54F), size: 30),
                  SizedBox(width: 8),
                  Icon(Icons.military_tech_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 8),
                  Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.seeAchievements,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShortcutButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int delayIndex;
  final Key? tapKey;

  const _ShortcutButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.delayIndex,
    this.tapKey,
  });

  @override
  State<_ShortcutButton> createState() => _ShortcutButtonState();
}

class _ShortcutButtonState extends State<_ShortcutButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + widget.delayIndex * 100),
      curve: Curves.easeOutBack,
      builder: (context, t, child) {
        return Opacity(
          opacity: t.clamp(0, 1),
          child: Transform.translate(offset: Offset(0, (1 - t.clamp(0.0, 1.0)) * 18), child: child),
        );
      },
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          key: widget.tapKey,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.93 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Material(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
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
