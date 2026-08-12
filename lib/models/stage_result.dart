/// Résultat sauvegardé pour une étape : meilleur score obtenu et validation.
class StageResult {
  final int bestScore;
  final int totalQuestions;
  final bool passed;

  const StageResult({
    required this.bestScore,
    required this.totalQuestions,
    required this.passed,
  });

  /// 0 à 3 étoiles selon le score, pour l'indicateur de progression (§5.2).
  int get stars {
    if (!passed) return 0;
    final ratio = bestScore / totalQuestions;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.85) return 2;
    return 1;
  }

  Map<String, dynamic> toJson() => {
        'bestScore': bestScore,
        'totalQuestions': totalQuestions,
        'passed': passed,
      };

  factory StageResult.fromJson(Map<String, dynamic> json) => StageResult(
        bestScore: json['bestScore'] as int,
        totalQuestions: json['totalQuestions'] as int,
        passed: json['passed'] as bool,
      );
}
