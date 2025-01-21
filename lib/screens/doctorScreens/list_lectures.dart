import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/lecture.dart';
import 'package:mobileprogramming/services/lecture_service.dart';
import 'package:url_launcher/url_launcher.dart';

class LecturesListScreen extends StatefulWidget {
  final String courseId;

  const LecturesListScreen({super.key, required this.courseId});

  @override
  State<LecturesListScreen> createState() => _LecturesListScreenState();
}

class _LecturesListScreenState extends State<LecturesListScreen> {
  late Future<List<Lecture>> _lecturesFuture;

  @override
  void initState() {
    super.initState();
    _lecturesFuture = LectureService().getLecturesByCourse(widget.courseId) as Future<List<Lecture>>;
  }

  Future<void> _downloadFile(String fileUrl) async {
    if (await canLaunchUrl(Uri.parse(fileUrl))) {
      await launchUrl(Uri.parse(fileUrl), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the file.')),
      );
    }
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
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(lecture.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(lecture.description),
                      const SizedBox(height: 4),
                      Text(
                        'Added on: ${lecture.dateAdded.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _downloadFile(lecture.fileUrl),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
