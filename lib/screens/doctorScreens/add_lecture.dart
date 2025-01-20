import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddLectureScreen extends StatefulWidget {
  const AddLectureScreen({super.key});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;
  String? uploadedFileUrl;

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result != null) {
      final file = File(result.files.single.path!);
      final fileName = result.files.single.name;
      try {
        final imageUrl = await uploadFileToSupabase(fileName, file);
        setState(() {
          uploadedFileUrl = imageUrl;
        });
      } catch (error) {
        print('Error uploading file: $error');
      }
    }
  }

  Future<String> uploadFileToSupabase(String fileName, File file) async {
    try {
      final filePath = await Supabase.instance.client.storage
          .from('lecture-files') // Bucket name 'lecture-files'
          .upload(fileName, file);

      // If the upload fails, `filePath` will be null or empty
      if (filePath.isEmpty) {
        throw Exception('File upload failed.');
      }

      final imageUrl = Supabase.instance.client.storage
          .from('lecture-files')
          .getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Lecture'
        ),
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
                    : 'Selected Date: ${selectedDate!.toIso8601String()}'
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: uploadFile,
              child: Text(
                'Upload File'
              ),
            ),
            if (uploadedFileUrl != null)
              Text(
                'Uploaded File URL: $uploadedFileUrl',
                style: TextStyle(
                  fontSize: 12
                ),
              ),
            ElevatedButton(
              onPressed: () {
                // Implement logic to save lecture data to your database (e.g., Firestore, Supabase)
                // Include the uploadedFileUrl in the lecture data
              },
              child: Text(
                'Save Lecture'
              ),
            ),
          ],
        ),
      ),
    );
  }
}