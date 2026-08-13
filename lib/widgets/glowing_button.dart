import 'package:flutter/material.dart';

/// Gros bouton d'action principal (Commencer / Jouer / Continuer) : dégradé,
/// lueur pulsante, et léger effet d'enfoncement au tap — un vrai widget
/// Flutter animé indépendamment, contrairement à une zone de tap invisible
/// posée sur une image statique (§9).
class GlowingButton extends StatefulWidget {
  final String label;
  final IconData? trailingIcon;
  final Color color;
  final VoidCallback? onTap;
  final Key? tapKey;

  const GlowingButton({
    super.key,
    required this.label,
    required this.color,
    this.trailingIcon,
    this.onTap,
    this.tapKey,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    return Semantics(
      button: true,
      label: widget.label,
      enabled: enabled,
      child: GestureDetector(
        key: widget.tapKey,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final glowOpacity = enabled ? 0.3 + _pulse.value * 0.4 : 0.0;
            return AnimatedScale(
              scale: _pressed ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: glowOpacity),
                      blurRadius: 26,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: enabled
                    ? [Color.lerp(widget.color, Colors.white, 0.25)!, widget.color]
                    : [Colors.grey.shade400, Colors.grey.shade500],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.black.withValues(alpha: 0.15), width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 3))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black38, offset: Offset(0, 2), blurRadius: 2)],
                  ),
                ),
                if (widget.trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(widget.trailingIcon, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
