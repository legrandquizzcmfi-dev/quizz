import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_stage.dart';
import '../models/quiz_theme.dart';
import 'result_screen.dart';

/// Déroulement d'une étape : 12 questions posées une à une, 4 options,
/// retour immédiat après chaque réponse, pas de chronomètre (§5.2, §13.4).
class QuizScreen extends StatefulWidget {
  final QuizTheme theme;
  final QuizLevel level;
  final QuizStage stage;

  const QuizScreen({
    super.key,
    required this.theme,
    required this.level,
    required this.stage,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool get _answered => _selectedIndex != null;

  List get _questions => widget.stage.questions;

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      if (_questions[_questionIndex].isCorrect(index)) {
        _score++;
      }
    });
  }

  void _next() {
    final isLast = _questionIndex == _questions.length - 1;
    if (isLast) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            theme: widget.theme,
            level: widget.level,
            stage: widget.stage,
            score: _score,
          ),
        ),
      );
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppData.of(context).strings;
    final question = _questions[_questionIndex];
    final total = _questions.length;
    final color = widget.theme.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.stageTitle(widget.theme.title, widget.stage.index)),
        backgroundColor: color,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_questionIndex + 1) / total,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Text(
              strings.questionProgress(_questionIndex + 1, total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              question.text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  return _OptionButton(
                    label: question.options[index],
                    onTap: () => _selectOption(index),
                    highlight: _optionHighlight(index, question.correctIndex),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _answered ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _questionIndex == total - 1 ? strings.finish : strings.next,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionHighlight _optionHighlight(int index, int correctIndex) {
    if (!_answered) return _OptionHighlight.none;
    if (index == correctIndex) return _OptionHighlight.correct;
    if (index == _selectedIndex) return _OptionHighlight.wrong;
    return _OptionHighlight.dimmed;
  }
}

enum _OptionHighlight { none, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final _OptionHighlight highlight;

  const _OptionButton({
    required this.label,
    required this.onTap,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground = Colors.black87;
    IconData? icon;

    switch (highlight) {
      case _OptionHighlight.none:
        background = Colors.grey.shade100;
      case _OptionHighlight.correct:
        background = Colors.green.shade400;
        foreground = Colors.white;
        icon = Icons.check_circle_rounded;
      case _OptionHighlight.wrong:
        background = Colors.red.shade300;
        foreground = Colors.white;
        icon = Icons.cancel_rounded;
      case _OptionHighlight.dimmed:
        background = Colors.grey.shade100;
        foreground = Colors.black38;
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              if (icon != null) Icon(icon, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
