import 'package:flutter/material.dart';

import 'app_data.dart';
import 'screens/start_screen.dart';

/// Thème visuel : lisible, couleurs franches, gros textes et boutons,
/// adapté à un public dès 3 ans et aux différentes tailles d'écran (§9).
class LeGrandQuizApp extends StatelessWidget {
  const LeGrandQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppData.of(context).strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6A4C93),
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(fontFamily: 'Montserrat'),
          bodySmall: TextStyle(fontFamily: 'Montserrat'),
          displayLarge: TextStyle(fontFamily: 'Montserrat'),
          displayMedium: TextStyle(fontFamily: 'Montserrat'),
          displaySmall: TextStyle(fontFamily: 'Montserrat'),
          headlineLarge: TextStyle(fontFamily: 'Montserrat'),
          headlineMedium: TextStyle(fontFamily: 'Montserrat'),
          labelLarge: TextStyle(fontFamily: 'Montserrat'),
          labelMedium: TextStyle(fontFamily: 'Montserrat'),
          labelSmall: TextStyle(fontFamily: 'Montserrat'),
          titleLarge: TextStyle(fontFamily: 'Montserrat'),
          titleMedium: TextStyle(fontFamily: 'Montserrat'),
          titleSmall: TextStyle(fontFamily: 'Montserrat'),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
      ),
      home: const StartScreen(),
    );
  }
}
