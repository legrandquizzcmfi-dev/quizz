import 'package:flutter_test/flutter_test.dart';

import 'package:le_grand_quiz/app.dart';
import 'package:le_grand_quiz/app_data.dart';
import 'package:le_grand_quiz/data/content_repository.dart';
import 'package:le_grand_quiz/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Home screen shows the 3 theme tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final themes = await ContentRepository().loadThemes();
    final progress = await ProgressService.create();

    await tester.pumpWidget(AppData(
      themes: themes,
      progressService: progress,
      child: const LeGrandQuizApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Le Camp des Agneaux'), findsWidgets);
    expect(find.text('Le Message des 3B'), findsOneWidget);
    expect(find.text('Instant ZTF'), findsOneWidget);
  });
}
