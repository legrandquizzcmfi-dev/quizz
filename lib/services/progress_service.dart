import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_theme.dart';
import '../models/stage_result.dart';

/// Sauvegarde de la progression sur l'appareil, sans compte ni réseau (§7, §8).
///
/// Seuil de déblocage retenu : 8 bonnes réponses sur 12 (~67 %), voir §13.1.
class ProgressService extends ChangeNotifier {
  static const _storageKey = 'le_grand_quiz.progress.v1';
  static const _languageKey = 'le_grand_quiz.language.v1';
  static const passRatio = 8 / 12;
  static const supportedLanguages = ['fr', 'en'];
  static const defaultLanguage = 'fr';

  final SharedPreferences _prefs;

  /// results[themeId][levelIndex][stageIndex] = StageResult
  final Map<String, Map<int, Map<int, StageResult>>> _results = {};

  String _languageCode = defaultLanguage;
  String get languageCode => _languageCode;

  ProgressService(this._prefs) {
    _load();
    _languageCode = _prefs.getString(_languageKey) ?? defaultLanguage;
  }

  static Future<ProgressService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs);
  }

  /// Change la langue du contenu et de l'interface, et la sauvegarde
  /// localement pour la prochaine ouverture de l'application.
  Future<void> setLanguage(String code) async {
    if (!supportedLanguages.contains(code) || code == _languageCode) return;
    _languageCode = code;
    await _prefs.setString(_languageKey, code);
    notifyListeners();
  }

  void _load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.forEach((themeId, levelsJson) {
      final levels = <int, Map<int, StageResult>>{};
      (levelsJson as Map<String, dynamic>).forEach((levelKey, stagesJson) {
        final stages = <int, StageResult>{};
        (stagesJson as Map<String, dynamic>).forEach((stageKey, resultJson) {
          stages[int.parse(stageKey)] =
              StageResult.fromJson(resultJson as Map<String, dynamic>);
        });
        levels[int.parse(levelKey)] = stages;
      });
      _results[themeId] = levels;
    });
  }

  Future<void> _persist() async {
    final encoded = _results.map((themeId, levels) => MapEntry(
          themeId,
          levels.map((levelIndex, stages) => MapEntry(
                levelIndex.toString(),
                stages.map((stageIndex, result) =>
                    MapEntry(stageIndex.toString(), result.toJson())),
              )),
        ));
    await _prefs.setString(_storageKey, jsonEncode(encoded));
  }

  StageResult? resultFor(String themeId, int levelIndex, int stageIndex) {
    return _results[themeId]?[levelIndex]?[stageIndex];
  }

  bool isLevelUnlocked(QuizTheme theme, int levelIndex) {
    if (levelIndex == 1) return true;
    final previousLevel =
        theme.levels.where((l) => l.index == levelIndex - 1).firstOrNull;
    if (previousLevel == null || previousLevel.stages.isEmpty) return false;
    final lastStageIndex = previousLevel.stages.last.index;
    return resultFor(theme.id, levelIndex - 1, lastStageIndex)?.passed ??
        false;
  }

  bool isStageUnlocked(QuizTheme theme, int levelIndex, int stageIndex) {
    if (!isLevelUnlocked(theme, levelIndex)) return false;
    if (stageIndex == 1) return true;
    return resultFor(theme.id, levelIndex, stageIndex - 1)?.passed ?? false;
  }

  /// Enregistre le résultat d'une étape et conserve le meilleur score
  /// (§5.2 "Rejouer une étape").
  Future<void> recordStageResult({
    required String themeId,
    required int levelIndex,
    required int stageIndex,
    required int score,
    required int totalQuestions,
  }) async {
    final passed = score >= (totalQuestions * passRatio).ceil();
    final existing = resultFor(themeId, levelIndex, stageIndex);
    final bestScore =
        existing == null ? score : (score > existing.bestScore ? score : existing.bestScore);
    final passedEver = passed || (existing?.passed ?? false);

    final themeResults = _results.putIfAbsent(themeId, () => {});
    final levelResults = themeResults.putIfAbsent(levelIndex, () => {});
    levelResults[stageIndex] = StageResult(
      bestScore: bestScore,
      totalQuestions: totalQuestions,
      passed: passedEver,
    );

    await _persist();
    notifyListeners();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
