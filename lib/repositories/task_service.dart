  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileprogramming/models/Quiz.dart';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<List<Map<String, dynamic>>> getAssignmentsByUser(String userId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('assignments')
        .where('createdBy', isEqualTo: userId)
        .orderBy('dueDateTime') // Sort by deadline
        .get();

    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch (error) {
    throw Exception('Error fetching assignments for user: $error');
  }
}
Future<List<Quiz>> getQuizzesByUser(String userId) async {
  try {
    QuerySnapshot snapshot = await _firestore.collection('quizzes')
        .where('createdBy', isEqualTo: userId)
        .orderBy('startDate') // Sort quizzes by start date
        .get();

    return snapshot.docs
        .map((doc) => Quiz.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (error) {
    throw Exception('Error fetching quizzes by user: $error');
  }
}
class TaskService {
  Future<List<Map<String, dynamic>>> getUserTasks(String userId) async {
    try {
      final assignments = await getAssignmentsByUser(userId);
      final quizzes = await getQuizzesByUser(userId);

      final tasks = [
        ...assignments.map((a) => {
              'type': 'assignment',
              'title': a['title'],
              'dueDateTime': a['dueDateTime'],
            }),
        ...quizzes.map((q) => {
              'type': 'quiz',
              'title': q.title,
              'dueDateTime': q.startDate.toIso8601String(),
            }),
      ];

      tasks.sort((a, b) => DateTime.parse(a['dueDateTime'])
          .compareTo(DateTime.parse(b['dueDateTime'])));

      return tasks;
    } catch (e) {
      throw Exception('Failed to retrieve user tasks: $e');
    }
  }
}
