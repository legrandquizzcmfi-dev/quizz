import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Musique de fond en boucle et effets sonores (bonne/mauvaise réponse,
/// victoire), avec un réglage "muet" sauvegardé localement (§9).
///
/// Les sons sont un agrément, pas une fonctionnalité critique : toute erreur
/// de lecture (plateforme sans sortie audio, fichier manquant, etc.) est
/// silencieusement ignorée pour ne jamais bloquer le jeu. Les lecteurs ne
/// sont créés qu'à la première utilisation réelle (et non dans le
/// constructeur), pour ne jamais toucher au canal de la plateforme tant
/// qu'aucun son n'a été demandé (utile notamment pour les tests widgets).
class AudioService extends ChangeNotifier {
  static const _mutedKey = 'le_grand_quiz.audio_muted.v1';
  static const _musicVolume = 0.35;
  static const _sfxVolume = 0.9;

  final SharedPreferences _prefs;
  AudioPlayer? _musicPlayer;
  AudioPlayer? _sfxPlayer;

  AudioPlayer get _music => _musicPlayer ??= AudioPlayer(playerId: 'background_music');
  AudioPlayer get _sfx => _sfxPlayer ??= AudioPlayer(playerId: 'sfx');

  bool _muted;
  bool get muted => _muted;

  AudioService(this._prefs) : _muted = _prefs.getBool(_mutedKey) ?? false;

  static Future<AudioService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AudioService(prefs);
  }

  Future<void> startBackgroundMusic() async {
    try {
      await _music.setReleaseMode(ReleaseMode.loop);
      await _music.setVolume(_muted ? 0 : _musicVolume);
      await _music.play(AssetSource('audio/background_music.wav'));
    } catch (_) {
      // Pas de sortie audio disponible : le jeu continue normalement.
    }
  }

  Future<void> toggleMuted() async {
    _muted = !_muted;
    await _prefs.setBool(_mutedKey, _muted);
    // Ne touche au lecteur de musique que s'il a déjà été créé : pas besoin
    // d'en démarrer un juste pour appliquer un volume à une musique qui ne
    // joue pas encore.
    if (_musicPlayer != null) {
      try {
        await _musicPlayer!.setVolume(_muted ? 0 : _musicVolume);
      } catch (_) {
        // idem.
      }
    }
    notifyListeners();
  }

  Future<void> _playSfx(String fileName) async {
    if (_muted) return;
    try {
      await _sfx.stop();
      await _sfx.play(AssetSource('audio/$fileName'), volume: _sfxVolume);
    } catch (_) {
      // idem.
    }
  }

  Future<void> playCorrect() => _playSfx('correct.wav');
  Future<void> playWrong() => _playSfx('wrong.wav');
  Future<void> playVictory() => _playSfx('victory.wav');

  @override
  void dispose() {
    _musicPlayer?.dispose();
    _sfxPlayer?.dispose();
    super.dispose();
  }
}
