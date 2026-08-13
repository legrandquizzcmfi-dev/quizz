import 'package:flutter/material.dart';

import 'app.dart';
import 'app_data.dart';
import 'data/content_repository.dart';
import 'models/quiz_theme.dart';
import 'services/audio_service.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppLoader());
}

/// Charge le contenu JSON (dans chaque langue disponible), la progression
/// sauvegardée et le service audio avant d'afficher l'application
/// (fonctionnement autonome, sans réseau, §7).
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  Future<(Map<String, List<QuizTheme>>, ProgressService, AudioService)> _load() async {
    final repository = ContentRepository();
    final themesByLanguage = <String, List<QuizTheme>>{
      for (final language in ProgressService.supportedLanguages)
        language: await repository.loadThemes(languageCode: language),
    };
    final progress = await ProgressService.create();
    final audio = await AudioService.create();
    return (themesByLanguage, progress, audio);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image(
                      image: AssetImage('assets/icon/icon.png'),
                      width: 160,
                      height: 160,
                    ),
                    SizedBox(height: 24),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          );
        }
        final (themesByLanguage, progress, audio) = snapshot.data!;
        audio.startBackgroundMusic();
        return AppData(
          themesByLanguage: themesByLanguage,
          progress: progress,
          audio: audio,
          child: const LeGrandQuizApp(),
        );
      },
    );
  }
}
