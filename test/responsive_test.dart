import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:le_grand_quiz/app_data.dart';
import 'package:le_grand_quiz/data/content_repository.dart';
import 'package:le_grand_quiz/models/quiz_theme.dart';
import 'package:le_grand_quiz/screens/coming_soon_screen.dart';
import 'package:le_grand_quiz/screens/home_screen.dart';
import 'package:le_grand_quiz/screens/quiz_screen.dart';
import 'package:le_grand_quiz/screens/result_screen.dart';
import 'package:le_grand_quiz/screens/stages_screen.dart';
import 'package:le_grand_quiz/screens/start_screen.dart';
import 'package:le_grand_quiz/screens/themes_screen.dart';
import 'package:le_grand_quiz/services/audio_service.dart';
import 'package:le_grand_quiz/services/progress_service.dart';
import 'package:le_grand_quiz/ui/game_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Éventail de tailles d'écran réelles (portrait et paysage, téléphone et
/// tablette) : c'est le point sensible de toute la refonte visuelle,
/// puisque le premier jet en image plein écran ne tenait que sur un seul
/// gabarit (§9). Chaque écran doit rester exempt de dépassement (overflow)
/// sur l'ensemble de cette plage.
const _sizes = <String, Size>{
  'petit téléphone (320x568)': Size(320, 568),
  'téléphone étroit (360x640)': Size(360, 640),
  'téléphone standard (390x844)': Size(390, 844),
  'grand téléphone (430x932)': Size(430, 932),
  'petite tablette portrait (600x960)': Size(600, 960),
  'tablette portrait (768x1024)': Size(768, 1024),
  'tablette paysage (1024x768)': Size(1024, 768),
  'téléphone paysage (844x390)': Size(844, 390),
};

Future<void> main() async {
  late List<QuizTheme> themesFr;
  late List<QuizTheme> themesEn;

  setUpAll(() async {
    final repository = ContentRepository();
    themesFr = await repository.loadThemes(languageCode: 'fr');
    themesEn = await repository.loadThemes(languageCode: 'en');
  });

  // Chaque écran (sauf StartScreen) est en réalité atteint par
  // `Navigator.push` sur un arbre déjà monté, jamais construit en même
  // temps que `AppData` : on reproduit ce cheminement ici plutôt que de
  // monter l'écran directement en racine de `pumpWidget`, pour ne pas
  // fabriquer de faux positifs propres au test (ex. lookup d'un
  // InheritedWidget dans initState()) qui ne se produiraient jamais dans
  // l'app réelle.
  Future<void> pumpScreenAtSizes(
    WidgetTester tester,
    String screenLabel,
    ProgressService progress,
    AudioService audio,
    Widget Function() screenBuilder,
  ) async {
    for (final entry in _sizes.entries) {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        AppData(
          themesByLanguage: {'fr': themesFr, 'en': themesEn},
          progress: progress,
          audio: audio,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(fontFamily: 'Montserrat'),
            home: const SizedBox.shrink(),
          ),
        ),
      );
      await tester.pump();

      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => screenBuilder()),
      );
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }

      final error = tester.takeException();
      expect(
        error,
        isNull,
        reason: '$screenLabel @ ${entry.key} (${entry.value}) : $error',
      );
    }
  }

  testWidgets('StartScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();

    await pumpScreenAtSizes(
      tester,
      'StartScreen',
      progress,
      audio,
      () => const StartScreen(),
    );
  });

  testWidgets('HomeScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();

    await pumpScreenAtSizes(
      tester,
      'HomeScreen',
      progress,
      audio,
      () => const HomeScreen(),
    );
  });

  testWidgets('ThemesScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();

    await pumpScreenAtSizes(
      tester,
      'ThemesScreen',
      progress,
      audio,
      () => const ThemesScreen(),
    );
  });

  testWidgets('StagesScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();
    final theme = themesFr.firstWhere((t) => t.hasContent);
    final level = theme.levels.firstWhere((l) => l.hasContent);

    await pumpScreenAtSizes(
      tester,
      'StagesScreen',
      progress,
      audio,
      () => StagesScreen(theme: theme, level: level),
    );
  });

  testWidgets('QuizScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();
    final theme = themesFr.firstWhere((t) => t.hasContent);
    final level = theme.levels.firstWhere((l) => l.hasContent);
    final stage = level.stages.firstWhere((s) => s.hasContent);

    await pumpScreenAtSizes(
      tester,
      'QuizScreen',
      progress,
      audio,
      () => QuizScreen(theme: theme, level: level, stage: stage),
    );
  });

  testWidgets('ResultScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();
    final theme = themesFr.firstWhere((t) => t.hasContent);
    final level = theme.levels.firstWhere((l) => l.hasContent);
    final stage = level.stages.firstWhere((s) => s.hasContent);

    await pumpScreenAtSizes(
      tester,
      'ResultScreen',
      progress,
      audio,
      () => ResultScreen(
        theme: theme,
        level: level,
        stage: stage,
        score: stage.questions.length,
      ),
    );
  });

  testWidgets('ComingSoonScreen sans overflow sur toute la plage de tailles', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressService.create();
    final audio = await AudioService.create();

    await pumpScreenAtSizes(
      tester,
      'ComingSoonScreen',
      progress,
      audio,
      () => const ComingSoonScreen(
        title: 'Défis',
        artAsset: GameAssets.questionMark,
        color: GameTheme.amberLight,
      ),
    );
  });
}
