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

// Plusieurs écrans (accueil, profil, tableau de bord) ont désormais un fond
// étoilé et/ou un bouton à lueur pulsante — des animations en boucle
// infinie qui restent actives même une fois l'écran quitté (la route reste
// montée sous la nouvelle). pumpAndSettle() ne se stabiliserait donc jamais
// une fois l'un de ces écrans visité : on avance le temps virtuel par petits
// pas avec pump() à la place, comme le veut le fonctionnement du testeur
// (un seul grand pump(duration) ne rejoue pas les frames intermédiaires).
Future<void> _settleTransition(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Simule un écran de téléphone réaliste (plutôt que le petit canevas par
/// défaut de 800×600) pour que le tableau de bord et l'écran de profil
/// tiennent entièrement sans avoir besoin de défiler.
void _usePhoneSizedSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets(
      'Returning user: start screen leads to the dashboard, '
      'and JOUER leads to the theme tabs', (WidgetTester tester) async {
    _usePhoneSizedSurface(tester);
    // Un profil déjà enregistré simule un utilisateur qui a déjà ouvert
    // l'application : l'écran « Parlons un peu de toi ! » doit être sauté.
    SharedPreferences.setMockInitialValues({
      'le_grand_quiz.child_name.v1': 'Josué',
      'le_grand_quiz.child_age.v1': 7,
    });

    await tester.pumpWidget(await _loadAppData(tester));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await _settleTransition(tester);

    // On atterrit sur le tableau de bord, pas directement sur les thèmes.
    expect(find.text('Le Camp des Agneaux'), findsNothing);
    expect(find.byKey(const Key('play_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('play_button')));
    await _settleTransition(tester);

    expect(find.text('Le Camp des Agneaux'), findsWidgets);
    expect(find.text('Le Message des 3B'), findsOneWidget);
    expect(find.text('Instant ZTF'), findsOneWidget);
    expect(find.text('La Vie de Maman Emily Tendo'), findsOneWidget);
  });

  testWidgets('Dashboard: Défis/Classements/Favoris open a coming-soon screen',
      (WidgetTester tester) async {
    _usePhoneSizedSurface(tester);
    SharedPreferences.setMockInitialValues({
      'le_grand_quiz.child_name.v1': 'Josué',
      'le_grand_quiz.child_age.v1': 7,
    });

    await tester.pumpWidget(await _loadAppData(tester));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await _settleTransition(tester);

    await tester.tap(find.byKey(const Key('challenges_button')));
    await _settleTransition(tester);
    expect(find.text('Défis'), findsOneWidget);
    expect(find.text('Cette fonctionnalité arrive bientôt !'), findsOneWidget);
    await tester.pageBack();
    await _settleTransition(tester);

    await tester.tap(find.byKey(const Key('leaderboard_button')));
    await _settleTransition(tester);
    expect(find.text('Classements'), findsOneWidget);
    await tester.pageBack();
    await _settleTransition(tester);

    await tester.tap(find.byKey(const Key('favorites_button')));
    await _settleTransition(tester);
    expect(find.text('Favoris'), findsOneWidget);
  });

  testWidgets(
      'First launch: start screen leads to the profile setup screen, '
      'which saves the profile and unlocks the dashboard',
      (WidgetTester tester) async {
    _usePhoneSizedSurface(tester);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(await _loadAppData(tester));
    await tester.pump();

    await tester.tap(find.byKey(const Key('start_button')));
    await _settleTransition(tester);

    final continueButton = find.byKey(const Key('continue_button'));
    expect(continueButton, findsOneWidget);

    // Le bouton « Continuer » est désactivé tant que le formulaire n'est
    // pas valide.
    await tester.tap(continueButton);
    await _settleTransition(tester);
    expect(find.byKey(const Key('play_button')), findsNothing);

    await tester.enterText(find.byType(TextField).first, 'Josué');
    await tester.enterText(find.byType(TextField).last, '7');
    await tester.pump();

    await tester.tap(continueButton);
    await _settleTransition(tester);

    expect(find.byKey(const Key('play_button')), findsOneWidget);
  });
}
