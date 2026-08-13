import 'package:flutter/material.dart';

import '../app_data.dart';
import 'stars_row.dart';

enum TileState { locked, comingSoon, available, completed }

/// Carte utilisée pour les niveaux et les étapes : distingue nettement
/// verrouillé / accessible / validé (§9).
class ProgressTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final TileState state;
  final int stars;
  final VoidCallback? onTap;

  const ProgressTile({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.state,
    this.stars = 0,
    this.onTap,
  });

  bool get _isEnabled => state == TileState.available || state == TileState.completed;

  @override
  Widget build(BuildContext context) {
    final baseColor = _isEnabled ? color : Colors.grey.shade400;

    return Material(
      color: baseColor,
      borderRadius: BorderRadius.circular(20),
      elevation: _isEnabled ? 4 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: _isEnabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(icon, size: 40, color: Colors.white),
                    if (state == TileState.locked)
                      const Positioned(
                        right: -4,
                        top: -4,
                        child: Icon(Icons.lock_rounded, size: 20, color: Colors.white),
                      ),
                    if (state == TileState.comingSoon)
                      const Positioned(
                        right: -6,
                        top: -6,
                        child: Icon(Icons.hourglass_top_rounded, size: 18, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (state == TileState.comingSoon)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      AppData.of(context).strings.soon,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                if (state == TileState.completed)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: StarsRow(stars: stars),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
