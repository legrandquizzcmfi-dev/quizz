import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../ui/game_theme.dart';

/// Décor de fond commun à tous les écrans : ciel dégradé, halo de soleil
/// pulsant, nuages qui dérivent, colombe qui traverse, petites icônes
/// flottantes, sol herbeux avec buissons et fleurs qui se balancent.
///
/// Remplace `StarryBackground` : même rôle (fond natif, responsive), mais
/// habillé avec les illustrations fournies.
class GameBackground extends StatefulWidget {
  final Widget? child;

  /// Mettre à `false` pour les écrans qui posent une grande carte blanche
  /// par-dessus le sol (aucun aujourd'hui, prévu pour extension).
  final bool showGround;

  const GameBackground({super.key, this.child, this.showGround = true});

  @override
  State<GameBackground> createState() => _GameBackgroundState();
}

class _GameBackgroundState extends State<GameBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    // Une seule horloge lente pour tout le décor : les éléments en dérivent
    // à des vitesses différentes (économe en CPU/batterie).
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 60))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _loop(double t, double speed, double phase) => (t * speed + phase) % 1.0;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: GameTheme.sky),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              final sun = (sin(t * 2 * pi * 8) + 1) / 2; // ~7,5 s par cycle

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Halo de soleil derrière le logo
                  Positioned(
                    top: h * .16,
                    left: w / 2 - 260,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: .35 + sun * .35,
                        child: Transform.scale(
                          scale: 1 + sun * .08,
                          child: Container(
                            width: 520,
                            height: 520,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [Color(0x8CFFECA0), Color(0x00FFECA0)],
                                stops: [0, .62],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Nuages
                  _cloud(w, top: h * .09, width: 136, opacity: .42, t: _loop(t, 1.3, 0)),
                  _cloud(w, top: h * .35, width: 112, opacity: .30, t: _loop(t, 0.95, .45)),
                  _cloud(w, top: h * .58, width: 158, opacity: .24, t: _loop(t, 0.77, .78)),

                  // Colombe qui traverse
                  Positioned(
                    top: h * .24 - _loop(t, 2.3, .2) * 46,
                    left: -90 + _loop(t, 2.3, .2) * (w + 180),
                    child: Opacity(
                      opacity: _fadeEdges(_loop(t, 2.3, .2)),
                      child: Image.asset(GameAssets.dove, width: 52),
                    ),
                  ),

                  // Petites icônes flottantes
                  Positioned(
                    top: h * .13,
                    right: 16,
                    child: Bob(child: Image.asset(GameAssets.bulb, width: 34)),
                  ),
                  Positioned(
                    top: h * .29,
                    left: 18,
                    child: Bob(
                      period: const Duration(milliseconds: 7500),
                      child: Image.asset(GameAssets.questionMark, width: 26),
                    ),
                  ),
                  Positioned(
                    top: h * .50,
                    right: 34,
                    child: Bob(
                      period: const Duration(seconds: 8),
                      child: Image.asset(GameAssets.starGold, width: 22),
                    ),
                  ),

                  if (widget.showGround) ...[
                    // Sol
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: GameTheme.groundHeight,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(gradient: GameTheme.grass),
                      ),
                    ),
                    Positioned(
                      left: -14,
                      bottom: 0,
                      child: Image.asset(GameAssets.bushLight, width: 112),
                    ),
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Image.asset(GameAssets.bushDark, width: 104),
                    ),
                    Positioned(
                      left: 104,
                      bottom: 12,
                      child: Sway(child: Image.asset(GameAssets.flowerPink, width: 26)),
                    ),
                    Positioned(
                      right: 112,
                      bottom: 16,
                      child: Sway(
                        period: const Duration(milliseconds: 6500),
                        child: Image.asset(GameAssets.flowerBlue, width: 26),
                      ),
                    ),
                    Positioned(
                      left: 158,
                      bottom: 6,
                      child: Sway(
                        period: const Duration(milliseconds: 5500),
                        child: Image.asset(GameAssets.flowerYellow, width: 22),
                      ),
                    ),
                    Positioned(
                      right: 66,
                      bottom: 22,
                      child: Sway(
                        period: const Duration(seconds: 6),
                        child: Image.asset(GameAssets.flowerYellow, width: 17),
                      ),
                    ),
                  ],

                  if (widget.child != null) widget.child!,
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _fadeEdges(double t) {
    if (t < .08) return t / .08;
    if (t > .92) return (1 - t) / .08;
    return .95;
  }

  Widget _cloud(
    double screenWidth, {
    required double top,
    required double width,
    required double opacity,
    required double t,
  }) {
    return Positioned(
      top: top,
      left: -160 + t * (screenWidth + 320),
      child: IgnorePointer(child: _Cloud(width: width, opacity: opacity)),
    );
  }
}

/// Nuage stylisé : trois disques blancs flous, sans image.
class _Cloud extends StatelessWidget {
  final double width;
  final double opacity;

  const _Cloud({required this.width, required this.opacity});

  @override
  Widget build(BuildContext context) {
    final h = width * .55;
    return Opacity(
      opacity: opacity,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: SizedBox(
          width: width,
          height: h,
          child: Stack(
            children: [
              Positioned(left: 0, bottom: 0, child: _blob(width * .38)),
              Positioned(left: width * .26, top: 0, child: _blob(width * .46)),
              Positioned(right: 0, bottom: h * .05, child: _blob(width * .34)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _blob(double d) => Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      );
}

/// Flottement vertical doux (icônes, livre lumineux).
class Bob extends StatefulWidget {
  final Widget child;
  final Duration period;
  final double amplitude;

  const Bob({
    super.key,
    required this.child,
    this.period = const Duration(seconds: 6),
    this.amplitude = 9,
  });

  @override
  State<Bob> createState() => _BobState();
}

class _BobState extends State<Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final v = sin(_c.value * 2 * pi);
        return Transform.translate(
          offset: Offset(0, v * widget.amplitude),
          child: Transform.rotate(angle: v * .026, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// Balancement autour de la base (fleurs, enfants).
class Sway extends StatefulWidget {
  final Widget child;
  final Duration period;
  final double maxAngle;

  const Sway({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 5000),
    this.maxAngle = .045,
  });

  @override
  State<Sway> createState() => _SwayState();
}

class _SwayState extends State<Sway> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => Transform.rotate(
        angle: sin(_c.value * 2 * pi) * widget.maxAngle,
        alignment: Alignment.bottomCenter,
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Entrée « monte + apparaît » utilisée pour les cartes et les vignettes.
class RiseIn extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const RiseIn({super.key, required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - t) * 26), child: child),
      ),
      child: child,
    );
  }
}

/// Pluie d'étoiles de l'écran de résultat.
class FallingStars extends StatefulWidget {
  final int count;

  const FallingStars({super.key, this.count = 7});

  @override
  State<FallingStars> createState() => _FallingStarsState();
}

class _FallingStarsState extends State<FallingStars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  final _rnd = Random(11);
  late final List<_StarSpec> _specs = List.generate(widget.count, (i) {
    const assets = [
      GameAssets.starYellow,
      GameAssets.starPink,
      GameAssets.starBlue,
      GameAssets.starGold,
      GameAssets.starSmall,
    ];
    return _StarSpec(
      asset: assets[i % assets.length],
      x: .06 + _rnd.nextDouble() * .88,
      size: 16 + _rnd.nextDouble() * 10,
      speed: .7 + _rnd.nextDouble() * .6,
      phase: _rnd.nextDouble(),
    );
  });

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Stack(
            children: [
              for (final s in _specs)
                Builder(builder: (context) {
                  final t = (_c.value * s.speed + s.phase) % 1.0;
                  return Positioned(
                    left: s.x * constraints.maxWidth,
                    top: -60 + t * (constraints.maxHeight + 120),
                    child: Opacity(
                      opacity: t < .12 ? t / .12 : 1,
                      child: Transform.rotate(
                        angle: t * 5.6,
                        child: Image.asset(s.asset, width: s.size),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarSpec {
  final String asset;
  final double x;
  final double size;
  final double speed;
  final double phase;

  const _StarSpec({
    required this.asset,
    required this.x,
    required this.size,
    required this.speed,
    required this.phase,
  });
}
