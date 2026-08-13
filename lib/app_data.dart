import 'package:flutter/widgets.dart';

import 'l10n/app_strings.dart';
import 'models/quiz_theme.dart';
import 'services/progress_service.dart';

/// Rend le contenu (chargé une fois, dans chaque langue disponible) et le
/// service de progression (mutable, sauvegardé en local, qui porte aussi la
/// langue choisie) disponibles à tout l'arbre de widgets.
class AppData extends InheritedNotifier<ProgressService> {
  final Map<String, List<QuizTheme>> themesByLanguage;

  const AppData({
    super.key,
    required this.themesByLanguage,
    required ProgressService progressService,
    required super.child,
  }) : super(notifier: progressService);

  ProgressService get progress => notifier!;

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
