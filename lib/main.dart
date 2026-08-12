import 'package:flutter/material.dart';

import 'app.dart';
import 'app_data.dart';
import 'data/content_repository.dart';
import 'models/quiz_theme.dart';
import 'services/progress_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _AppLoader());
}

/// Charge le contenu JSON et la progression sauvegardée avant d'afficher
/// l'application (fonctionnement autonome, sans réseau, §7).
class _AppLoader extends StatelessWidget {
  const _AppLoader();

  Future<(List<QuizTheme>, ProgressService)> _load() async {
    final themes = await ContentRepository().loadThemes();
    final progress = await ProgressService.create();
    return (themes, progress);
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
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final (themes, progress) = snapshot.data!;
        return AppData(
          themes: themes,
          progressService: progress,
          child: const LeGrandQuizApp(),
        );
      },
    );
  }
}
