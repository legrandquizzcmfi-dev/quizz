import 'package:flutter/material.dart';

/// Fait grandir un contenu conçu pour une largeur de téléphone
/// (`designWidth`) afin qu'il occupe l'espace réellement disponible sur un
/// écran plus grand (tablette), au lieu de rester épinglé à sa taille de
/// conception au milieu d'une zone vide (§9) — c'est ce que faisait un
/// simple `ConstrainedBox(maxWidth: ...)`, qui plafonne la largeur sans
/// jamais agrandir le contenu.
///
/// Le contenu garde ses proportions (mise à l'échelle uniforme) et ne
/// déborde jamais : sur un écran plus petit que `designWidth`, il rétrécit
/// au lieu de dépasser.
class ResponsiveDesign extends StatelessWidget {
  final double designWidth;
  final Widget child;

  const ResponsiveDesign({
    super.key,
    required this.designWidth,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(width: designWidth, child: child),
      ),
    );
  }
}
