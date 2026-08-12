import 'question.dart';

/// Une étape : 12 questions posées une à une (§5.1).
class QuizStage {
  final int index;
  final List<Question> questions;

  const QuizStage({required this.index, required this.questions});

  /// Une étape sans contenu (pas encore fourni par EFDET) reste affichée
  /// mais désactivée avec un statut "Bientôt disponible".
  bool get hasContent => questions.isNotEmpty;

  factory QuizStage.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'] as List? ?? const [];
    return QuizStage(
      index: json['index'] as int,
      questions: rawQuestions
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }
}
