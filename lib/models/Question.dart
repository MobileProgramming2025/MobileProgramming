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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'type': type,
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      type: json['type'],
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
      correctAnswer: json['correctAnswer'],
    );
  }

 
Question copyWith({
    String? id,
    String? text,
    String? type,
    List<String>? options,
    String? correctAnswer,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      type: type ?? this.type,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
    );
  }
}