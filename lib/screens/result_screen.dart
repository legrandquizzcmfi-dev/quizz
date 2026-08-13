import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_stage.dart';
import '../models/quiz_theme.dart';
import '../services/progress_service.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import 'quiz_screen.dart';

/// Fin d'étape : pluie d'étoiles, illustration (étoile d'or si réussi,
/// agneau si presque), score, 3 étoiles, actions.
class ResultScreen extends StatefulWidget {
  final QuizTheme theme;
  final QuizLevel level;
  final QuizStage stage;
  final int score;

  const ResultScreen({
    super.key,
    required this.theme,
    required this.level,
    required this.stage,
    required this.score,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final bool _passed;
  bool _resultRecorded = false;

  @override
  void initState() {
    super.initState();
    final total = widget.stage.questions.length;
    _passed = widget.score >= (total * ProgressService.passRatio).ceil();
  }

  // AppData.of(context) ne peut pas être appelé depuis initState() (il n'est
  // valide qu'à partir de build()/didChangeDependencies()) ; on enregistre
  // donc le résultat ici, une seule fois grâce à _resultRecorded.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_resultRecorded) return;
    _resultRecorded = true;

    final total = widget.stage.questions.length;
    final appData = AppData.of(context);
    appData.progress.recordStageResult(
      themeId: widget.theme.id,
      levelIndex: widget.level.index,
      stageIndex: widget.stage.index,
      score: widget.score,
      totalQuestions: total,
    );
    if (_passed) appData.audio.playVictory();
  }

  QuizStage? get _nextStage {
    final stages = widget.level.stages;
    final idx = stages.indexWhere((s) => s.index == widget.stage.index + 1);
    return idx == -1 ? null : stages[idx];
  }

  int get _stars {
    final total = widget.stage.questions.length;
    if (widget.score >= total) return 3;
    if (widget.score >= total - 2) return 2;
    if (_passed) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;
    final total = widget.stage.questions.length;
    final nextStage = _nextStage;

    return Scaffold(
      body: GameBackground(
        child: Stack(
          children: [
            const FallingStars(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: .85, end: 1),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      builder: (context, t, child) =>
                          Transform.scale(scale: t, child: child),
                      child: Image.asset(
                        _passed ? GameAssets.starGold : GameAssets.lamb,
                        width: 126,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _passed ? strings.bravo : strings.almost,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black38,
                            offset: Offset(0, 4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.score(widget.score, total),
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: GameTheme.gold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Opacity(
                              opacity: i < _stars ? 1 : .35,
                              child: Image.asset(
                                GameAssets.starYellow,
                                width: i < _stars ? 40 : 34,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _passed ? strings.passedMessage : strings.failedMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 13.5,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEAF5FF),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_passed &&
                        nextStage != null &&
                        nextStage.hasContent) ...[
                      GlowingButton(
                        label: strings.nextStage.toUpperCase(),
                        fontSize: 17,
                        expand: true,
                        onTap: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => QuizScreen(
                              theme: widget.theme,
                              level: widget.level,
                              stage: nextStage,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    _SecondaryButton(
                      label: strings.replayStage,
                      filled: true,
                      onTap: () => Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            theme: widget.theme,
                            level: widget.level,
                            stage: widget.stage,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SecondaryButton(
                      label: strings.backToStages,
                      filled: false,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: -22,
              bottom: 8,
              child: Image.asset(GameAssets.kidBoy, width: 128),
            ),
            Positioned(
              right: -26,
              bottom: 6,
              child: Image.asset(GameAssets.kidGirl, width: 146),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: filled ? Colors.white : Colors.transparent,
          border: Border.all(
            color: filled
                ? GameTheme.navy
                : Colors.white.withValues(alpha: .85),
            width: 3,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: filled
              ? const [
                  BoxShadow(color: Color(0x2E000000), offset: Offset(0, 5)),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: filled ? 15 : 14,
            fontWeight: FontWeight.w900,
            color: filled ? GameTheme.navy : Colors.white,
          ),
        ),
      ),
    );
  }
}
