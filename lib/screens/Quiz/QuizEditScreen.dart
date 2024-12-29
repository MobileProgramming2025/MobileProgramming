// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mobileprogramming/models/Question.dart';
// import 'package:mobileprogramming/models/Quiz.dart';
// import 'package:mobileprogramming/services/quiz_service.dart';
// import 'package:intl/intl.dart'; 

// class QuizEditScreen extends StatefulWidget {
//   final String quizId;

//   const QuizEditScreen({super.key, required this.quizId});

//   @override
//   _QuizEditScreenState createState() => _QuizEditScreenState();
// }

// class _QuizEditScreenState extends State<QuizEditScreen> {
//   final QuizService _quizService = QuizService();
//   late Quiz _quiz; 
//   bool _isLoading = true; 
//   bool _isSubmitting = false;

//   final _formKey = GlobalKey<FormState>(); 

//   @override
//   void initState() {
//     super.initState();
//     _fetchQuizData();
//   }

//   Future<void> _fetchQuizData() async {
//     try {
//       Quiz? quiz = await _quizService.getQuizById(widget.quizId);
//       if (quiz != null) {
//         setState(() {
//           _quiz = quiz;
//           _isLoading = false;
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Quiz not found!')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching quiz: $error')),
//       );
//     }
//   }

//   void _submitQuiz() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSubmitting = true);

//     try {

//       await _quizService.updateQuiz(_quiz);

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Quiz updated successfully')),
//       );
//       Navigator.pop(context); 
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error updating quiz: $error')),
//       );
//     } finally {
//       setState(() => _isSubmitting = false);
//     }
//   }

//   void _addNewQuestion() {
//     setState(() {
//       _quiz.questions.add(
//         Question(
//           id: DateTime.now().toIso8601String(),
//           text: '',
//           type: 'multiple choice',
//           options: ['Option 1', 'Option 2'],
//           correctAnswer: '',
//         ),
//       );
//     });
//   }

//   void _removeQuestion(int index) {
//     setState(() {
//       _quiz.questions.removeAt(index);
//     });
//   }


//   Future<void> _selectStartTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_quiz.startDate),
//     );
//     if (picked != null) {
//       setState(() {
//         _quiz.startDate = DateTime(
//           _quiz.startDate.year,
//           _quiz.startDate.month,
//           _quiz.startDate.day,
//           picked.hour,
//           picked.minute,
//         );
//       });
//     }
//   }


//   Future<void> _selectEndTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.fromDateTime(_quiz.endDate),
//     );
//     if (picked != null) {
//       setState(() {
//         _quiz.endDate = DateTime(
//           _quiz.endDate.year,
//           _quiz.endDate.month,
//           _quiz.endDate.day,
//           picked.hour,
//           picked.minute,
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Edit Quiz')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Quiz')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
             
//               TextFormField(
//                 decoration: const InputDecoration(labelText: 'Quiz Title'),
//                 initialValue: _quiz.title,
//                 validator: (value) => value == null || value.isEmpty
//                     ? 'Quiz title cannot be empty'
//                     : null,
//                 onChanged: (value) => _quiz.title = value,
//               ),
//               const SizedBox(height: 16),

           
//               ListTile(
//                 title: const Text('Start Date'),
//                 subtitle: Text(DateFormat('yyyy-MM-dd').format(_quiz.startDate)),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () async {
//                   DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: _quiz.startDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//                   if (pickedDate != null) {
//                     setState(() {
//                       _quiz.startDate = pickedDate;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 8),

              
//               ListTile(
//                 title: const Text('Start Time'),
//                 subtitle: Text(DateFormat('HH:mm').format(_quiz.startDate)),
//                 trailing: const Icon(Icons.access_time),
//                 onTap: () => _selectStartTime(context),
//               ),
//               const SizedBox(height: 16),

//               ListTile(
//                 title: const Text('End Date'),
//                 subtitle: Text(DateFormat('yyyy-MM-dd').format(_quiz.endDate)),
//                 trailing: const Icon(Icons.calendar_today),
//                 onTap: () async {
//                   DateTime? pickedDate = await showDatePicker(
//                     context: context,
//                     initialDate: _quiz.endDate,
//                     firstDate: DateTime(2000),
//                     lastDate: DateTime(2100),
//                   );
//                   if (pickedDate != null) {
//                     setState(() {
//                       _quiz.endDate = pickedDate;
//                     });
//                   }
//                 },
//               ),
//               const SizedBox(height: 8),

             
//               ListTile(
//                 title: const Text('End Time'),
//                 subtitle: Text(DateFormat('HH:mm').format(_quiz.endDate)),
//                 trailing: const Icon(Icons.access_time),
//                 onTap: () => _selectEndTime(context),
//               ),
//               const SizedBox(height: 16),

             
//               const Text('Questions', style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               ..._quiz.questions.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 Question question = entry.value;

//                 return Column(
//                   children: [
//                     TextFormField(
//                       decoration: InputDecoration(
//                         labelText: 'Question ${index + 1}',
//                       ),
//                       initialValue: question.text,
//                       onChanged: (value) {
//                         setState(() {
//                           question.text = value;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 8),
                   
//                     Column(
//                       children: question.options!.map((option) {
//                         int optionIndex = question.options!.indexOf(option);
//                         return TextFormField(
//                           decoration: InputDecoration(
//                             labelText: 'Option ${optionIndex + 1}',
//                           ),
//                           initialValue: option,
//                           onChanged: (value) {
//                             setState(() {
//                               question.options?[optionIndex] = value;
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 8),
                    
//                     TextFormField(
//                       decoration: const InputDecoration(labelText: 'Correct Answer'),
//                       initialValue: question.correctAnswer,
//                       onChanged: (value) {
//                         setState(() {
//                           question.correctAnswer = value;
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 16),
                   
//                     ElevatedButton(
//                       onPressed: () => _removeQuestion(index),
//                       child: const Text('Remove Question'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 );
//               }).toList(),

//               ElevatedButton(
//                 onPressed: _addNewQuestion,
//                 child: const Text('Add Question'),
//               ),
//               const SizedBox(height: 24),

          
//               ElevatedButton(
//                 onPressed: _isSubmitting ? null : _submitQuiz,
//                 child: _isSubmitting
//                     ? const CircularProgressIndicator()
//                     : const Text('Save Changes'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
