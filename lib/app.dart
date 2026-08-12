import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

/// Thème visuel : lisible, couleurs franches, gros textes et boutons,
/// adapté à un public dès 3 ans et aux différentes tailles d'écran (§9).
class LeGrandQuizApp extends StatelessWidget {
  const LeGrandQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Le Grand Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6A4C93),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
