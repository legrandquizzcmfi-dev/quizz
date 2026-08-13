import 'dart:math';

import 'package:flutter/material.dart';

/// Fond dégradé « ciel nocturne » avec un léger champ d'étoiles scintillantes,
/// entièrement natif (aucune image) : reste net et bien proportionné sur
/// n'importe quelle taille d'écran, y compris tablette, contrairement à une
/// illustration plein écran figée (§9).
class StarryBackground extends StatefulWidget {
  final Widget? child;

  const StarryBackground({super.key, this.child});

  @override
  State<StarryBackground> createState() => _StarryBackgroundState();
}

class _StarryBackgroundState extends State<StarryBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    final random = Random(7); // graine fixe : disposition stable entre les builds
    _stars = List.generate(46, (_) {
      return _Star(
        dx: random.nextDouble(),
        dy: random.nextDouble() * 0.8,
        radius: 1.0 + random.nextDouble() * 1.8,
        phase: random.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B1E3D), Color(0xFF1B2E5C), Color(0xFF35538F)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _StarfieldPainter(stars: _stars, t: _controller.value),
              );
            },
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class _Star {
  final double dx;
  final double dy;
  final double radius;
  final double phase;

  const _Star({required this.dx, required this.dy, required this.radius, required this.phase});
}

class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double t;

  const _StarfieldPainter({required this.stars, required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final star in stars) {
      final twinkle = (sin((t + star.phase) * 2 * pi) + 1) / 2;
      paint.color = Colors.white.withValues(alpha: 0.25 + twinkle * 0.65);
      canvas.drawCircle(Offset(star.dx * size.width, star.dy * size.height), star.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}
