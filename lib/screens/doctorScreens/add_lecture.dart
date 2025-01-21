import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/lecture.dart';
import 'package:mobileprogramming/services/lecture_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddLectureScreen extends StatefulWidget {
  final String courseId;

  const AddLectureScreen({super.key, required this.courseId});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  String? uploadedFileUrl;

  Future<String?> pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      try {
        // Upload the file to Supabase and get the file URL (but we won't store the URL)
        await uploadFileToSupabase(fileName, file);
        
        // Store the file name in the variable
        setState(() {
          uploadedFileUrl = fileName;  // Store the file name instead of the URL
        });
        return fileName;  // Return the file name
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading file: $error')),
          );
        }
      }
    }
    return null; // Return null if the user cancels or upload fails
  }


  Future<String> uploadFileToSupabase(String fileName, File file) async {
    try {
      final filePath = await Supabase.instance.client.storage
          .from('lecture-files') // Bucket name
          .upload(fileName, file);

      if (filePath.isEmpty) {
        throw Exception('File upload failed.');
      }

      // Get the public URL for the uploaded file
      final fileUrl = Supabase.instance.client.storage
          .from('lecture-files')
          .getPublicUrl(filePath);

      return fileUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveLecture() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty || selectedDate == null || uploadedFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and upload a file")),
      );
      return;
    }

    final lecture = Lecture(
      title: title,
      description: description,
      dateAdded: selectedDate!,
      courseId: widget.courseId,
      fileUrl: uploadedFileUrl!,
    );

    try {
      await LectureService().addLecture(lecture);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lecture saved successfully!")),
      );

      // Clear fields after saving
      titleController.clear();
      descriptionController.clear();
      setState(() {
        selectedDate = null;
        uploadedFileUrl = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error saving lecture: $e"
          )
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Lecture'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title'
              ),
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description'
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                setState(() {
                  selectedDate = pickedDate;
                });
              },
              child: Text(
                selectedDate == null
                    ? 'Select Date'
                    : 'Selected Date: ${selectedDate!.toIso8601String()}',
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final fileUrl = await pickAndUploadFile();
                if (fileUrl != null) {
                  setState(() {
                    uploadedFileUrl = fileUrl;
                  });
                }
              },
              child: Text('Upload File'),
            ),
            if (uploadedFileUrl != null)
              Text(
                'Uploaded File name: $uploadedFileUrl',
                style: TextStyle(fontSize: 12),
              ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: saveLecture,
              child: Text('Save Lecture'),
            ),
          ],
        ),
      ),
    );
  }
}
