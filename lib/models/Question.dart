class Question {
  String id;
  String text;
  String type;
  List<String>? options;
  String correctAnswer;

  Question({
    required this.id,
    required this.text,
    required this.type,
    this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
