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
/// Filet de sécurité : si `child` a malgré tout besoin de plus de hauteur
/// que `designHeight` (texte plus long dans une langue, très grand écran en
/// paysage…), il devient défilable à l'intérieur de la boîte mise à
/// l'échelle plutôt que de déborder.
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
            child: SizedBox(
              width: designWidth,
              height: designHeight,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: designHeight),
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
