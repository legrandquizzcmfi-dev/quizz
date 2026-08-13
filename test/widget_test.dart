import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:le_grand_quiz/app.dart';
import 'package:le_grand_quiz/app_data.dart';
import 'package:le_grand_quiz/data/content_repository.dart';
import 'package:le_grand_quiz/models/quiz_theme.dart';
import 'package:le_grand_quiz/services/audio_service.dart';
import 'package:le_grand_quiz/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppData> _loadAppData(WidgetTester tester) async {
  final repository = ContentRepository();
  final themesByLanguage = <String, List<QuizTheme>>{};
  for (final language in ProgressService.supportedLanguages) {
    themesByLanguage[language] = (await tester.runAsync(
      () => repository.loadThemes(languageCode: language),
    ))!;
  }
  final progress = await tester.runAsync(() => ProgressService.create());
  final audio = await tester.runAsync(() => AudioService.create());

  return AppData(
    themesByLanguage: themesByLanguage,
    progress: progress!,
    audio: audio!,
    child: const LeGrandQuizApp(),
  );
}

void main() {
  testWidgets(
      'Returning user: start screen leads to the dashboard, '
      'and JOUER leads to the theme tabs', (WidgetTester tester) async {
    // Un profil déjà enregistré simule un utilisateur qui a déjà ouvert
    // l'application : l'écran « Parlons un peu de toi ! » doit être sauté.
    SharedPreferences.setMockInitialValues({
      'le_grand_quiz.child_name.v1': 'Josué',
      'le_grand_quiz.child_age.v1': 7,
    });

    await tester.pumpWidget(await _loadAppData(tester));
    // Un seul pump : l'écran d'accueil illustré a une lueur animée en boucle
    // infinie autour du bouton « Commencer », donc pumpAndSettle() ne se
    // stabiliserait jamais tant qu'on reste sur cet écran.
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pumpAndSettle();

    // On atterrit sur le tableau de bord, pas directement sur les thèmes.
    expect(find.text('Le Camp des Agneaux'), findsNothing);
    expect(find.byKey(const Key('play_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('play_button')));
    await tester.pumpAndSettle();

    expect(find.text('Le Camp des Agneaux'), findsWidgets);
    expect(find.text('Le Message des 3B'), findsOneWidget);
    expect(find.text('Instant ZTF'), findsOneWidget);
    expect(find.text('La Vie de Maman Emily Tendo'), findsOneWidget);
  });

  testWidgets('Dashboard: Défis/Classements/Favoris open a coming-soon screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'le_grand_quiz.child_name.v1': 'Josué',
      'le_grand_quiz.child_age.v1': 7,
    });

    await tester.pumpWidget(await _loadAppData(tester));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('challenges_button')));
    await tester.pumpAndSettle();
    expect(find.text('Défis'), findsOneWidget);
    expect(find.text('Cette fonctionnalité arrive bientôt !'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('leaderboard_button')));
    await tester.pumpAndSettle();
    expect(find.text('Classements'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favorites_button')));
    await tester.pumpAndSettle();
    expect(find.text('Favoris'), findsOneWidget);
  });

  testWidgets(
      'First launch: start screen leads to the profile setup screen, '
      'which saves the profile and unlocks the dashboard',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(await _loadAppData(tester));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await tester.pumpAndSettle();

    // L'écran est une longue image défilable (pour rester utilisable même
    // clavier ouvert) : il faut faire défiler jusqu'aux champs/bouton avant
    // d'interagir avec, comme le ferait un vrai doigt.
    final continueButton = find.byKey(const Key('continue_button'));
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();

    // Le bouton « Continuer » est désactivé tant que le formulaire n'est
    // pas valide.
    await tester.tap(continueButton);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('play_button')), findsNothing);

    await tester.ensureVisible(find.byType(TextField).first);
    await tester.enterText(find.byType(TextField).first, 'Josué');
    await tester.ensureVisible(find.byType(TextField).last);
    await tester.enterText(find.byType(TextField).last, '7');
    await tester.pumpAndSettle();

    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('play_button')), findsOneWidget);
  });
}
