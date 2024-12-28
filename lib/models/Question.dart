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

  // Converts the object to a map for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  // Parses a JSON object into a Question instance
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: json['options'] != null ? List<String>.from(json['options']) : null,
      correctAnswer: json['correctAnswer'],
    );
  }
}
