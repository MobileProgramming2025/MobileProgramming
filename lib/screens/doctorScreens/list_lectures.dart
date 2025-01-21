import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Lecture.dart';
import 'package:mobileprogramming/services/lecture_service.dart';

class LectureListScreen extends StatefulWidget {
  final String courseId;

  const LectureListScreen({super.key, required this.courseId});

  @override
  State<LectureListScreen> createState() => _LectureListScreenState();
}

class _LectureListScreenState extends State<LectureListScreen> {
  late Future<List<Lecture>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    _lecturesFuture = LectureService().getLecturesByCourse(widget.courseId) as Future<List<Lecture>>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures'),
      ),
      body: FutureBuilder<List<Lecture>>(
        future: _lecturesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No lectures found for this course.'),
            );
          }

          final lectures = snapshot.data!;
          return ListView.builder(
            itemCount: lectures.length,
            itemBuilder: (context, index) {
              final lecture = lectures[index];
              return ListTile(
                title: Text(lecture.title),
                subtitle: Text(lecture.description),
                trailing: Text(
                  lecture.dateAdded.toLocal().toString().split(' ')[0], // Display date in YYYY-MM-DD format
                ),
                onTap: () {
                   // Handle lecture item tap (e.g., navigate to a lecture details screen)
                },
              );
            },
          );
        },
      ),
    );
  }
}
