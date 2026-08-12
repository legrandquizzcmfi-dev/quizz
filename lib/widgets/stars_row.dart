import 'package:flutter/material.dart';

/// Indicateur de progression (étoiles) pour une étape validée (§5.2).
class StarsRow extends StatelessWidget {
  final int stars;
  final double size;

  const StarsRow({super.key, required this.stars, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < stars;
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          color: filled ? const Color(0xFFFFC107) : Colors.white70,
          size: size,
        );
      }),
    );
  }
}
