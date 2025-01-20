import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> pickFileAndUpload() async {
    // Request storage permission
    // final storageStatus = await Permission.storage.request();

    // if (!storageStatus.isGranted) {
    //   if (!mounted) return;
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('Storage permission is required to upload files.'),
    //     ),
    //   );
    //   return;
    // }

    // If permission is granted, proceed with file picking
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      print(result.files);
      final file = result.files.first;

      try {
        if(file.bytes == null) {
          print("File data is empty!");
          throw Exception('File data is empty');
        }

        // Write bytes to a temporary file
        // final tempDir = await getTemporaryDirectory();
        // final tempFile = File('${tempDir.path}/${file.name}');
        final tempFile = File(file.path!);
        // await tempFile.writeAsBytes(file.bytes!);

        // Upload file to Supabase
        final path = await Supabase.instance.client.storage
            .from('lecture-files')
            .upload(file.name, tempFile);

        // Get the file's public URL
        final publicUrl = Supabase.instance.client.storage
            .from('lecture-files')
            .getPublicUrl(path);

        setState(() {
          uploadedFileUrl = publicUrl;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File uploaded Successfully!'
            ),
          )
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'File upload failed: ${e.toString()}'
            ),
          )
        );
      }
    }
  }

  Future<void> saveLecture() async {
    final title = titleController.text;
    final description = descriptionController.text;

    if (title.isEmpty || 
        selectedDate == null || 
        uploadedFileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please complete all fields',
          ),
        )
      );
      return;
    }

    final response = await Supabase.instance.client.from('lectures').insert({
      'title': title,
      'description': description,
      'date': selectedDate!.toIso8601String(),
      'file_url': uploadedFileUrl,
    });

    if (response.error == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lecture added successfully!'
          ),
        )
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error adding lecture'
          ),
        )
      );
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
              onPressed: pickFileAndUpload,
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
              onPressed: saveLecture,
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