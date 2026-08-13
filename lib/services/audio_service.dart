import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Musique de fond en boucle et effets sonores (bonne/mauvaise réponse,
/// victoire), avec un réglage "muet" sauvegardé localement (§9).
///
/// Les sons sont un agrément, pas une fonctionnalité critique : toute erreur
/// de lecture (plateforme sans sortie audio, fichier manquant, etc.) est
/// silencieusement ignorée pour ne jamais bloquer le jeu.
class AudioService extends ChangeNotifier {
  static const _mutedKey = 'le_grand_quiz.audio_muted.v1';
  static const _musicVolume = 0.35;
  static const _sfxVolume = 0.9;

  final SharedPreferences _prefs;
  final AudioPlayer _musicPlayer = AudioPlayer(playerId: 'background_music');
  final AudioPlayer _sfxPlayer = AudioPlayer(playerId: 'sfx');

  bool _muted;
  bool get muted => _muted;

  AudioService(this._prefs) : _muted = _prefs.getBool(_mutedKey) ?? false;

  static Future<AudioService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AudioService(prefs);
  }

  Future<void> startBackgroundMusic() async {
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.setVolume(_muted ? 0 : _musicVolume);
      await _musicPlayer.play(AssetSource('audio/background_music.wav'));
    } catch (_) {
      // Pas de sortie audio disponible : le jeu continue normalement.
    }
  }

  Future<void> toggleMuted() async {
    _muted = !_muted;
    await _prefs.setBool(_mutedKey, _muted);
    try {
      await _musicPlayer.setVolume(_muted ? 0 : _musicVolume);
    } catch (_) {
      // idem.
    }
    notifyListeners();
  }

  Future<void> _playSfx(String fileName) async {
    if (_muted) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.play(AssetSource('audio/$fileName'), volume: _sfxVolume);
    } catch (_) {
      // idem.
    }
  }

  Future<void> playCorrect() => _playSfx('correct.wav');
  Future<void> playWrong() => _playSfx('wrong.wav');
  Future<void> playVictory() => _playSfx('victory.wav');

  @override
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
    super.dispose();
  }
}
