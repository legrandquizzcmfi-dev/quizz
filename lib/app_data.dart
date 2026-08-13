import 'package:flutter/widgets.dart';

import 'l10n/app_strings.dart';
import 'models/quiz_theme.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';

/// Rend le contenu (chargé une fois, dans chaque langue disponible) et les
/// services de progression et d'audio (mutables, sauvegardés en local)
/// disponibles à tout l'arbre de widgets. L'ensemble se reconstruit dès que
/// l'un des deux services notifie un changement (progression, langue,
/// muet…).
class AppData extends InheritedNotifier<Listenable> {
  final Map<String, List<QuizTheme>> themesByLanguage;
  final ProgressService progress;
  final AudioService audio;

  AppData({
    super.key,
    required this.themesByLanguage,
    required this.progress,
    required this.audio,
    required super.child,
  }) : super(notifier: Listenable.merge([progress, audio]));

  /// Thèmes dans la langue actuellement sélectionnée.
  List<QuizTheme> get themes =>
      themesByLanguage[progress.languageCode] ?? themesByLanguage.values.first;

  /// Textes d'interface dans la langue actuellement sélectionnée.
  AppStrings get strings => AppStrings(progress.languageCode);

  static AppData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AppData>();
    assert(data != null, 'AppData.of() called with no AppData ancestor.');
    return data!;
  }
}
