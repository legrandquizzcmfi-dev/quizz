import 'package:flutter/widgets.dart';

import 'models/quiz_theme.dart';
import 'services/progress_service.dart';

/// Rend le contenu (chargé une fois) et le service de progression
/// (mutable, sauvegardé en local) disponibles à tout l'arbre de widgets.
class AppData extends InheritedNotifier<ProgressService> {
  final List<QuizTheme> themes;

  const AppData({
    super.key,
    required this.themes,
    required ProgressService progressService,
    required super.child,
  }) : super(notifier: progressService);

  ProgressService get progress => notifier!;

  static AppData of(BuildContext context) {
    final data = context.dependOnInheritedWidgetOfExactType<AppData>();
    assert(data != null, 'AppData.of() called with no AppData ancestor.');
    return data!;
  }
}
