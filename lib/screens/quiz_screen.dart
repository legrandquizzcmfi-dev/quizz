import 'package:flutter/material.dart';

import '../app_data.dart';
import '../models/quiz_level.dart';
import '../models/quiz_stage.dart';
import '../models/quiz_theme.dart';
import '../ui/game_theme.dart';
import '../widgets/game_controls.dart';
import '../widgets/game_decor.dart';
import 'result_screen.dart';

/// Déroulement d'une étape : 12 questions, énoncé sur carte parchemin,
/// options blanches avec pastille A/B/C, retour immédiat (vert/rouge),
/// bouton SUIVANT / TERMINER collé en bas.
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
    final correct = _questions[_questionIndex].isCorrect(index);
    setState(() {
      _selectedIndex = index;
      if (correct) _score++;
    });
    final audio = AppData.of(context).audio;
    correct ? audio.playCorrect() : audio.playWrong();
  }

  void _next() {
    if (_questionIndex == _questions.length - 1) {
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

    return Scaffold(
      body: GameBackground(
        child: Column(
          children: [
            ScreenHeader(
              title: strings.stageTitle(widget.theme.title, widget.stage.index),
              color: widget.theme.color,
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: (_questionIndex + 1) / total),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOut,
                          builder: (context, value, _) => LinearProgressIndicator(
                            value: value,
                            minHeight: 12,
                            backgroundColor: Colors.white.withValues(alpha: .55),
                            valueColor: const AlwaysStoppedAnimation(GameTheme.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.questionProgress(_questionIndex + 1, total),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              shadows: GameTheme.textShadow,
                            ),
                          ),
                          Text(
                            '$_score / $total',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: GameTheme.gold,
                              shadows: GameTheme.textShadow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [GameTheme.parchmentTop, Color(0xFFEBD59F)],
                          ),
                          border: Border.all(color: GameTheme.wood, width: 6),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Color(0x29000000), offset: Offset(0, 6)),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(GameAssets.questionMark, width: 26),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                question.text,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 15.5,
                                  height: 1.4,
                                  fontWeight: FontWeight.w800,
                                  color: GameTheme.inkBrownDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: ListView.separated(
                          itemCount: question.options.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _OptionButton(
                            label: question.options[index],
                            letter: String.fromCharCode(65 + index),
                            highlight: _highlight(index, question.correctIndex),
                            onTap: () => _selectOption(index),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlowingButton(
                        label: _questionIndex == total - 1
                            ? strings.finish.toUpperCase()
                            : strings.next.toUpperCase(),
                        fontSize: 19,
                        expand: true,
                        showArrow: false,
                        onTap: _answered ? _next : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _OptionHighlight _highlight(int index, int correctIndex) {
    if (!_answered) return _OptionHighlight.none;
    if (index == correctIndex) return _OptionHighlight.correct;
    if (index == _selectedIndex) return _OptionHighlight.wrong;
    return _OptionHighlight.dimmed;
  }
}

enum _OptionHighlight { none, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  final String label;
  final String letter;
  final _OptionHighlight highlight;
  final VoidCallback onTap;

  const _OptionButton({
    required this.label,
    required this.letter,
    required this.highlight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color fg = const Color(0xFF33445C);
    Color border = const Color(0xFFCBD8E7);
    bool showCheck = false;

    switch (highlight) {
      case _OptionHighlight.none:
        break;
      case _OptionHighlight.correct:
        bg = GameTheme.green;
        fg = Colors.white;
        border = const Color(0xFF14601F);
        showCheck = true;
      case _OptionHighlight.wrong:
        bg = GameTheme.red;
        fg = Colors.white;
        border = GameTheme.redDark;
      case _OptionHighlight.dimmed:
        bg = const Color(0xFFF1F5FA);
        fg = const Color(0xFF93A2B5);
        border = const Color(0xFFDCE5EF);
    }

    final answered = highlight != _OptionHighlight.none;

    return GestureDetector(
      onTap: answered
          ? null
          : () {
              AppData.of(context).audio.playPop();
              onTap();
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border, width: 3),
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Color(0x1F000000), offset: Offset(0, 4))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: answered ? Colors.white.withValues(alpha: .3) : const Color(0xFFEAF1FA),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                letter,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: answered ? Colors.white : GameTheme.navy,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            if (showCheck)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .6, end: 1),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (context, t, child) => Transform.scale(scale: t, child: child),
                child: Image.asset(GameAssets.checkGreen, width: 26),
              ),
          ],
        ),
      ),
    );
  }
}
