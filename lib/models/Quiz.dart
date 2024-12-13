import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  String id;
  String title;
  List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
  });
}
