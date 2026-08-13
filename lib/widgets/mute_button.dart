import 'package:flutter/material.dart';

import '../app_data.dart';

/// Bouton muet/son affiché dans la barre d'application (§9). Coupe la
/// musique de fond et les effets sonores, et sauvegarde le réglage
/// localement.
class MuteButton extends StatelessWidget {
  const MuteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appData = AppData.of(context);
    final audio = appData.audio;

    return AnimatedBuilder(
      animation: audio,
      builder: (context, _) {
        return IconButton(
          icon: Icon(
            audio.muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
          ),
          tooltip: appData.strings.soundTooltip(audio.muted),
          onPressed: audio.toggleMuted,
        );
      },
    );
  }
}
