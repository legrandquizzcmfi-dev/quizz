import 'package:flutter/material.dart';

import '../app_data.dart';
import '../ui/game_theme.dart';
import 'game_decor.dart';

/// Joue le son "pop" avant d'exécuter [onTap], si présent. Utilisé par tous
/// les contrôles tactiles du jeu pour un retour sonore cohérent.
VoidCallback? _withPop(BuildContext context, VoidCallback? onTap) {
  if (onTap == null) return null;
  return () {
    AppData.of(context).audio.playPop();
    onTap();
  };
}

/// Gros bouton d'action principal (COMMENCER / JOUER / CONTINUER / SUIVANT) :
/// dégradé orange, bordure marine, ombre portée « posée », lueur pulsante,
/// pastille blanche avec chevron, enfoncement au tap.
class GlowingButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final bool showArrow;
  final double fontSize;
  final bool expand;
  final Key? tapKey;

  const GlowingButton({
    super.key,
    required this.label,
    this.onTap,
    this.showArrow = true,
    this.fontSize = 22,
    this.expand = false,
    this.tapKey,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);
  bool _pressed = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;

    final content = Container(
      padding: EdgeInsets.symmetric(
        vertical: widget.fontSize * .72,
        horizontal: widget.expand ? 20 : 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: enabled
              ? const [GameTheme.orangeLight, GameTheme.orange]
              : const [Color(0xFFB9C2CE), Color(0xFF98A3B2)],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: enabled ? GameTheme.navy : const Color(0xFF6E7A8C),
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: enabled ? GameTheme.orangeShadow : const Color(0xFF6E7A8C),
            offset: const Offset(0, 6),
          ),
          const BoxShadow(
            color: Color(0x47000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
                color: Colors.white,
                shadows: GameTheme.textShadow,
              ),
            ),
          ),
          if (widget.showArrow) ...[
            const SizedBox(width: 12),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 22,
                  color: enabled ? GameTheme.orange : const Color(0xFF98A3B2),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        key: widget.tapKey,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: _withPop(context, widget.onTap),
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final glow = enabled ? .3 + _pulse.value * .35 : 0.0;
            return AnimatedSlide(
              offset: Offset(0, _pressed ? .06 : 0),
              duration: const Duration(milliseconds: 90),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: GameTheme.orangeLight.withValues(alpha: glow),
                      blurRadius: 34,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: content,
        ),
      ),
    );
  }
}

/// Panneau « bois + parchemin » avec ruban bleu en surtitre.
/// Utilisé par l'écran « Parlons un peu de toi ! ».
class WoodPanel extends StatelessWidget {
  final String title;
  final Widget child;

  const WoodPanel({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [GameTheme.parchmentTop, GameTheme.parchmentBottom],
            ),
            border: Border.all(color: GameTheme.wood, width: 9),
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(color: Color(0x33000000), offset: Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 34, 20, 22),
          child: child,
        ),
        Positioned(
          top: -22,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [GameTheme.ribbonTop, GameTheme.ribbonBottom],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Color(0xFF0F4184), offset: Offset(0, 5)),
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                shadows: GameTheme.textShadow,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// En-tête coloré des écrans internes (thèmes, étapes, quiz, bientôt).
class ScreenHeader extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onBack;
  final List<Widget> actions;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.color,
    this.onBack,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 14,
        right: 14,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, GameTheme.darken(color)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              key: const Key('screen_back_button'),
              onTap: _withPop(context, onBack),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Vignette de niveau / d'étape : disponible, réussie, verrouillée, bientôt.
enum TileState { locked, comingSoon, available, completed }

class ProgressTile extends StatelessWidget {
  final String label;
  final Color color;
  final TileState state;
  final int stars;
  final String? subLabel;
  final String? iconAsset;
  final VoidCallback? onTap;
  final int delayIndex;

  const ProgressTile({
    super.key,
    required this.label,
    required this.color,
    required this.state,
    this.stars = 0,
    this.subLabel,
    this.iconAsset,
    this.onTap,
    this.delayIndex = 0,
  });

  bool get _enabled =>
      state == TileState.available || state == TileState.completed;

  @override
  Widget build(BuildContext context) {
    final bg = !_enabled
        ? GameTheme.locked
        : (state == TileState.completed ? GameTheme.green : color);

    return RiseIn(
      delay: Duration(milliseconds: delayIndex * 35),
      child: Opacity(
        opacity: _enabled ? 1 : .72,
        child: GestureDetector(
          onTap: _withPop(context, _enabled ? onTap : null),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.black.withValues(alpha: .18),
                width: 3,
              ),
              boxShadow: const [
                BoxShadow(color: Color(0x29000000), offset: Offset(0, 5)),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state == TileState.locked)
                    const _Padlock()
                  else if (iconAsset != null)
                    Image.asset(iconAsset!, width: 34)
                  else
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  if (iconAsset != null || state == TileState.locked) ...[
                    const SizedBox(height: 5),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  if (subLabel != null)
                    Text(
                      subLabel!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: state == TileState.available
                            ? const Color(0xFFFFF3C4)
                            : const Color(0xFFEFF3F8),
                      ),
                    ),
                  if (state == TileState.completed) ...[
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          Opacity(
                            opacity: i < stars ? 1 : .3,
                            child: Image.asset(
                              GameAssets.starYellow,
                              width: 11,
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cadenas dessiné (pas d'emoji, pas d'icône Material) pour les vignettes
/// verrouillées.
class _Padlock extends StatelessWidget {
  const _Padlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 13,
          height: 9,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.white, width: 3),
              left: BorderSide(color: Colors.white, width: 3),
              right: BorderSide(color: Colors.white, width: 3),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
          ),
        ),
        Container(
          width: 22,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
