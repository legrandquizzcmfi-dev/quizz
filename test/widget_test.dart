import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:le_grand_quiz/app.dart';
import 'package:le_grand_quiz/app_data.dart';
import 'package:le_grand_quiz/data/content_repository.dart';
import 'package:le_grand_quiz/models/quiz_theme.dart';
import 'package:le_grand_quiz/services/audio_service.dart';
import 'package:le_grand_quiz/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home screen shows the 4 theme tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final repository = ContentRepository();
    final themesByLanguage = <String, List<QuizTheme>>{};
    for (final language in ProgressService.supportedLanguages) {
      themesByLanguage[language] = (await tester.runAsync(
        () => repository.loadThemes(languageCode: language),
      ))!;
    }
    final progress = await tester.runAsync(() => ProgressService.create());
    final audio = await tester.runAsync(() => AudioService.create());

    await tester.pumpWidget(AppData(
      themesByLanguage: themesByLanguage,
      progress: progress!,
      audio: audio!,
      child: const LeGrandQuizApp(),
    ));
    await tester.pumpAndSettle();

    // L'application démarre sur l'écran d'accueil illustré : on tape sur le
    // bouton « Commencer » pour atteindre l'écran des thèmes.
    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pumpAndSettle();

    expect(find.text('Le Camp des Agneaux'), findsWidgets);
    expect(find.text('Le Message des 3B'), findsOneWidget);
    expect(find.text('Instant ZTF'), findsOneWidget);
    expect(find.text('La Vie de Maman Emily Tendo'), findsOneWidget);
  });
}
