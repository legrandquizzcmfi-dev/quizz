import 'package:flutter/material.dart';

/// Jetons visuels de la nouvelle direction artistique « Le grand Quizz »
/// (repris 1:1 de la maquette HTML `Le Grand Quizz.dc.html`).
class GameTheme {
  // Ciel
  static const skyTop = Color(0xFF0B4FA8);
  static const skyMid = Color(0xFF1878D2);
  static const skyLow = Color(0xFF57AFEF);
  static const skyBottom = Color(0xFF9BD8F8);

  // Herbe
  static const grassTop = Color(0xFF5FB63F);
  static const grassBottom = Color(0xFF2C7A22);
  static const groundHeight = 118.0;

  // Marque
  static const navy = Color(0xFF123E86);
  static const navyLight = Color(0xFF1B4FA0);
  static const navyDeep = Color(0xFF0A2350);
  static const ribbonTop = Color(0xFF3189DE);
  static const ribbonBottom = Color(0xFF1657AE);

  // Bouton principal
  static const orange = Color(0xFFF5960C);
  static const orangeLight = Color(0xFFFFD35C);
  static const orangeShadow = Color(0xFFB96D06);

  // Etats
  static const green = Color(0xFF2FA84F);
  static const greenDark = Color(0xFF1E7D2E);
  static const red = Color(0xFFE5484D);
  static const redDark = Color(0xFFA62229);
  static const locked = Color(0xFFA8B4C4);
  static const gold = Color(0xFFFFE082);

  // Bois / parchemin
  static const wood = Color(0xFFB07A33);
  static const parchmentTop = Color(0xFFF6E5BC);
  static const parchmentBottom = Color(0xFFE8CE93);
  static const inkBrown = Color(0xFF6B4A22);
  static const inkBrownDark = Color(0xFF3E2C16);

  // Raccourcis du tableau de bord (couleurs du code existant)
  static const purple = Color(0xFF8E24AA);
  static const purpleLight = Color(0xFFA238C4);
  static const amber = Color(0xFFFF9800);
  static const amberLight = Color(0xFFFFAE33);
  static const blue = Color(0xFF1E88E5);
  static const blueLight = Color(0xFF2E9BF0);
  static const pink = Color(0xFFEC407A);
  static const pinkLight = Color(0xFFF4568C);

  static const sky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [skyTop, skyMid, skyLow, skyBottom],
    stops: [0, .42, .74, 1],
  );

  static const grass = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [grassTop, grassBottom],
  );

  /// Assombrit une couleur de thème pour les bordures / en-têtes.
  static Color darken(Color c, [double amount = .16]) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  static const List<Shadow> textShadow = [
    Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 3),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Color(0x38000000), blurRadius: 0, offset: Offset(0, 6)),
  ];
}

/// Chemins des assets illustrés (PNG détourés fournis par le client).
class GameAssets {
  static const _d = 'assets/images/';

  static const wordmark = '${_d}title_quizz.png';
  static const appLogo = '${_d}app_logo.png';
  static const tagline = '${_d}banner_tagline.png';
  static const glowBook = '${_d}glow_book.png';
  static const boardWood = '${_d}board_wood.png';

  static const kidBoy = '${_d}kid_boy.png';
  static const kidGirl = '${_d}kid_girl.png';
  static const lion = '${_d}lion.png';
  static const lamb = '${_d}lamb.png';
  static const dove = '${_d}dove.png';

  static const bushLight = '${_d}bush_a.png';
  static const bushDark = '${_d}bush_b.png';
  static const flowerPink = '${_d}flower_pink.png';
  static const flowerBlue = '${_d}flower_blue.png';
  static const flowerYellow = '${_d}flower_yellow.png';

  static const starYellow = '${_d}star_yellow.png';
  static const starGold = '${_d}star_gold.png';
  static const starBlue = '${_d}star_blue.png';
  static const starPink = '${_d}star_pink.png';
  static const starSmall = '${_d}star_small.png';

  static const bookOpen = '${_d}book_open.png';
  static const bibleGreen = '${_d}bible_green.png';
  static const bulb = '${_d}bulb.png';
  static const questionMark = '${_d}question_mark.png';
  static const checkGreen = '${_d}check_green.png';
  static const cross = '${_d}cross.png';
  static const logoCmfi = '${_d}logo_cmfi.png';
}
