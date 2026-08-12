import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_stage.dart';
import '../models/quiz_theme.dart';
import '../services/progress_service.dart';
import 'quiz_screen.dart';

/// Score de fin d'étape et déblocage progressif (§5.2, §13.1).
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

  @override
  void initState() {
    super.initState();
    final total = widget.stage.questions.length;
    _passed = widget.score >= (total * ProgressService.passRatio).ceil();

    // Sauvegarde locale, sans compte ni réseau (§8).
    AppData.of(context).progress.recordStageResult(
          themeId: widget.theme.id,
          levelIndex: widget.level.index,
          stageIndex: widget.stage.index,
          score: widget.score,
          totalQuestions: total,
        );
  }

  QuizStage? get _nextStage {
    final stages = widget.level.stages;
    final idx = stages.indexWhere((s) => s.index == widget.stage.index + 1);
    return idx == -1 ? null : stages[idx];
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.stage.questions.length;
    final color = widget.theme.color;
    final nextStage = _nextStage;

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                color: Colors.white,
                size: 96,
              ),
              const SizedBox(height: 16),
              Text(
                _passed ? 'Bravo !' : 'Presque !',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Score : ${widget.score} / $total',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                _passed
                    ? 'Étape validée, la suite est débloquée !'
                    : 'Il faut au moins 8 bonnes réponses pour débloquer la suite.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              _ActionButton(
                label: 'Rejouer cette étape',
                icon: Icons.refresh_rounded,
                color: color,
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
              if (_passed && nextStage != null && nextStage.hasContent) ...[
                const SizedBox(height: 14),
                _ActionButton(
                  label: 'Étape suivante',
                  icon: Icons.arrow_forward_rounded,
                  color: color,
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
              ],
              const SizedBox(height: 14),
              _ActionButton(
                label: 'Retour aux étapes',
                icon: Icons.list_rounded,
                color: color,
                outlined: true,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: outlined
          ? OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: Colors.white),
              label: Text(label, style: const TextStyle(fontSize: 17, color: Colors.white)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, color: color),
              label: Text(
                label,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
    );
  }
}
