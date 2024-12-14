
import 'package:mobileprogramming/models/Question.dart';

class Quiz {
  final String id;
  final String title;
  final List<Question> questions;
  final int duration; 

  Quiz({
    required this.id,
    required this.title,
    required this.questions,
    this.duration = 0, 
  });
}
