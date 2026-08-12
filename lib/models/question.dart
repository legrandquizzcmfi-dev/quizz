/// Une question de quiz : un énoncé, 4 propositions, une seule bonne réponse (§6).
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctIndex;

  const Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      options: List<String>.from(json['options'] as List),
      correctIndex: json['correctIndex'] as int,
    );
  }

  bool isCorrect(int selectedIndex) => selectedIndex == correctIndex;
}
