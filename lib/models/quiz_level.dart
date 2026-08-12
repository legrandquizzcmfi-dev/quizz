import 'quiz_stage.dart';

/// Un niveau : 12 étapes de difficulté progressive (§5.1, §6).
class QuizLevel {
  final int index;
  final List<QuizStage> stages;

  const QuizLevel({required this.index, required this.stages});

  bool get hasContent => stages.any((s) => s.hasContent);

  factory QuizLevel.fromJson(Map<String, dynamic> json) {
    final rawStages = json['stages'] as List? ?? const [];
    return QuizLevel(
      index: json['index'] as int,
      stages: rawStages
          .map((s) => QuizStage.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
