import 'package:flutter/material.dart';

import '../app_data.dart';

/// Petit sélecteur FR / EN affiché dans la barre d'application (§9).
///
/// Change la langue du contenu des questions et de l'interface ; se
/// reconstruit tout seul via [AnimatedBuilder] sur le service de progression,
/// qui porte aussi la langue choisie et la sauvegarde localement.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = AppData.of(context).progress;

    return AnimatedBuilder(
      animation: progress,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguageButton(
                  label: 'FR',
                  selected: progress.languageCode == 'fr',
                  onTap: () => progress.setLanguage('fr'),
                ),
                _LanguageButton(
                  label: 'EN',
                  selected: progress.languageCode == 'en',
                  onTap: () => progress.setLanguage('en'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          AppData.of(context).audio.playPop();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: selected ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
