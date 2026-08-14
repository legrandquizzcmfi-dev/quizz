import 'package:flutter/material.dart';

/// Fait grandir un contenu conçu pour une largeur de téléphone
/// (`designWidth`) afin qu'il occupe l'espace réellement disponible sur un
/// écran plus grand (tablette), au lieu de rester épinglé à sa taille de
/// conception au milieu d'une zone vide (§9) — c'est ce que faisait un
/// simple `ConstrainedBox(maxWidth: ...)`, qui plafonne la largeur sans
/// jamais agrandir le contenu.
///
/// La hauteur de conception se déduit de la hauteur réellement disponible
/// (divisée par le facteur d'échelle appliqué à la largeur), de sorte que
/// la boîte mise à l'échelle ait exactement le même rapport largeur/hauteur
/// que l'écran réel : `child` peut donc utiliser `mainAxisAlignment.center`
/// (ou tout autre agencement dépendant d'une hauteur bornée) et remplir
/// l'écran sans bandes vides ni en haut ni en bas — contrairement à une
/// simple boîte de largeur fixe et de hauteur naturelle, qui ne partage pas
/// forcément le rapport d'aspect de l'écran et laisse alors le
/// `FittedBox` ajouter ces bandes pour préserver les proportions.
///
/// `maxScale` évite un agrandissement démesuré sur un très grand écran (au
/// prix, dans ce cas seulement, d'une marge résiduelle). Le contenu garde
/// toujours ses proportions et ne déborde jamais : sur un écran plus petit
/// que `designWidth`, il rétrécit au lieu de dépasser.
///
/// `child` reçoit une hauteur bornée et exacte (`designHeight`), pas une
/// hauteur infinie : c'est ce qui permet à `mainAxisAlignment.center`,
/// `Expanded` et `Spacer` de vraiment répartir l'espace disponible dans
/// `child`, plutôt que de laisser Flutter replier la colonne sur la taille
/// intrinsèque de son contenu (elle ne peut pas viser "max" une hauteur
/// infinie) et peindre le reste de `designHeight` en vide — c'est ce bug
/// précis qui écrasait tout le contenu en haut de l'écran avec une grande
/// bande vide en dessous quand un `SingleChildScrollView` fournissait une
/// hauteur non bornée ici.
///
/// Pas de filet de sécurité anti-débordement : les écrans doivent être
/// conçus pour tenir dans `designHeight` (via `Expanded`/`Flexible`), ce que
/// permet justement cette hauteur bornée.
class ResponsiveDesign extends StatelessWidget {
  final double designWidth;
  final double maxScale;
  final Widget child;

  const ResponsiveDesign({
    super.key,
    required this.designWidth,
    this.maxScale = 1.5,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = (constraints.maxWidth / designWidth).clamp(
          0.5,
          maxScale,
        );
        final designHeight = constraints.maxHeight / scale;
        return Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(width: designWidth, height: designHeight, child: child),
          ),
        );
      },
    );
  }
}
