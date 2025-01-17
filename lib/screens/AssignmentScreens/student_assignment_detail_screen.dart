import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  final Map<String, dynamic> assignmentData;

  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentData,
  });

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  bool _isSubmitting = false;
  String? _submissionUrl;
  bool _isOverdue = false;
  bool _isSubmitted = false;
PlatformFile? pickedFile;
UploadTask? uploadTask;
  @override
  void initState() {
    super.initState();
   // _initializeSubmission();
  }
// void _selectFile() async {
//   final result = await FilePicker.platform.pickFiles();
//   if (result== null) return ;
//   setState(() {
//     pickedFile = result.files.first ; 
//   });
// }
// Future _submitAssignment()async{
//     final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('Error: User is not authenticated');
//     return;
//   }

//   final userId = user.uid;
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
//     withData: true,
//   );

//   if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
//     print('Error: No valid file selected');
//     return;
//   }
   
//     pickedFile = result.files.first ; 
//     final path= 'Submissions/assignmentId/fileUrl';
//  //final path= 'Submissions/${widget.assignmentId}/$userId/${pickedFile!.name}' ;
//  final file = File(pickedFile!.path!);
//   final ref = FirebaseStorage.instance.ref().child(path);
//  uploadTask =  ref.putFile(file);
//  final snapshot = await uploadTask!.whenComplete((){});
//  final urlDownload = await snapshot.ref.getDownloadURL();
//  print ('Downloas Link : $urlDownload');
// }
  /// Initializes the submission status and checks if the user has already submitted.
//  void _initializeSubmission() async {
//   final userId = FirebaseAuth.instance.currentUser!.uid;
//   final dueDate = widget.assignmentData['dueDateTime'].toDate();

//   setState(() {
//     _isOverdue = DateTime.now().isAfter(dueDate);
//   });

//   // Reference to the student's submission document
//   final studentSubmissionDoc = FirebaseFirestore.instance
//       .collection('submissions')
//       .doc(widget.assignmentId)
//       .collection('studentSubmissions')
//       .doc(userId);

//   // Check if submission document exists
//   final submissionSnapshot = await studentSubmissionDoc.get();

//   if (submissionSnapshot.exists) {
//     // Load existing data
//     setState(() {
//       _isSubmitted = true;
//       _submissionUrl = submissionSnapshot.data()?['fileUrl'];
//     });
//   } else {
//     // Create the submission document with placeholder values
//     await studentSubmissionDoc.set({
//       'fileUrl': null,
//       'submittedAt': null,
//       'assignmentId': widget.assignmentId,
//       'studentId': userId,
//     });
//   }
// }


//   /// Handles the submission of the assignment file.
//  void _submitAssignment() async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) {
//     print('Error: User is not authenticated');
//     return;
//   }

//   final userId = user.uid;
//   final result = await FilePicker.platform.pickFiles(
//     type: FileType.custom,
//     allowedExtensions: ['pdf', 'docx', 'jpg', 'png'],
//     withData: true,
//   );

//   if (result == null || result.files.isEmpty || result.files.first.bytes == null) {
//     print('Error: No valid file selected');
//     return;
//   }

//   final file = result.files.first;
//   final filePath = 'submissions/${widget.assignmentId}/$userId/${file.name}';

//   try {
//     final ref = FirebaseStorage.instance.ref(filePath);
//     await ref.putData(file.bytes!); // Upload the file
//     final fileUrl = await ref.getDownloadURL();

//     // Reference to the student's submission document
//     final studentSubmissionDoc = FirebaseFirestore.instance
//         .collection('submissions')
//         .doc(widget.assignmentId)
//         .collection('studentSubmissions')
//         .doc(userId);

//     // Update the Firestore document
//     await studentSubmissionDoc.update({
//       'fileUrl': fileUrl,
//       'submittedAt': FieldValue.serverTimestamp(),
//     });

//     print('Assignment submitted successfully with URL: $fileUrl');
//   } catch (e) {
//     print('Error during upload: $e');
//   }
// }

Future<void> _submitAssignment() async {
  // Simulate getting userId, assignmentId, and file selection
  final userId = 'exampleUserId'; // Replace with actual user ID (from auth)
  final assignmentId = widget.assignmentId; // From the widget data
  final result = await FilePicker.platform.pickFiles();

  if (result == null || result.files.single.path == null) {
    debugPrint('No file selected');
    return;
  }

  final filePath = result.files.single.path!;
  final fileName = result.files.single.name;
  final file = File(filePath);

  debugPrint('Selected file path: $filePath');
  debugPrint('File name: $fileName');

  // Firebase Storage Reference
  final storageRef = FirebaseStorage.instance
      .ref()
      .child('submissions/$userId/$assignmentId/$fileName');

  try {
    // Upload file to Firebase Storage
    final uploadTask = storageRef.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final fileUrl = await snapshot.ref.getDownloadURL();

    debugPrint('File uploaded successfully: $fileUrl');

    // Save submission data to Firestore
    final firestoreRef = FirebaseFirestore.instance
        .collection('submissions') // Main submissions collection
        .doc(assignmentId) // Document for the specific assignment
        .collection('users') // Sub-collection for users
        .doc(userId); // User-specific submission

    await firestoreRef.set({
      'fileName': fileName,
      'fileUrl': fileUrl,
      'submittedAt': FieldValue.serverTimestamp(),
    });

    debugPrint('Submission saved to Firestore successfully.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Assignment submitted successfully!')),
    );
  } catch (e) {
    debugPrint('Error during submission: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit assignment: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    final dueDate = widget.assignmentData['dueDateTime'].toDate();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentData['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Description:', style: TextStyle(color: Colors.black)),
            Text(widget.assignmentData['description'],
                style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            const Text('Due Date:', style: TextStyle(color: Colors.black)),
            Text(dueDate.toString(), style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            const Text('Status:', style: TextStyle(color: Colors.black)),
            Text(_isOverdue ? 'Overdue' : 'On Time',
                style: const TextStyle(color: Colors.black)),
            Text(_isSubmitted ? 'Submitted' : 'Not Submitted',
                style: const TextStyle(color: Colors.black)),
            const SizedBox(height: 20),
            _isSubmitted
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Submission:',
                          style: TextStyle(color: Colors.black)),
                      InkWell(
                        onTap: () {
                          // Open the file in a browser or external app
                        },
                        child: Text(
                          'View File :', 
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,

                          ),
                        ),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAssignment,
                    child: _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Assignment'),
                  ),
          ],
        ),
      ),
    );



//     Widget buildProgress()=> StreamBuilder<TaskSnapshot>
//     (
//       stream : uploadTask?.snapshotEvents,
//     builder: (context, snapshot)
//   {
//     if (snapshot.hasData)
//     {
//       final data = snapshot.data!;
//       double progress = data.bytesTransferred / data.totalBytes ;
//    return const SizedBox(height : 50,
//       child: Stack(
//         fit: StackFit.expand ,
// children: [
//   LinearProgressIndicator(
//     value:  progress ,
//     backgroundColor: Colors.grey,
//     color: Colors.green,
//   ),
// ],
//       ),
//       );
//     }
//     else {
//       return const SizedBox(height : 50);
//     }
//   });
  }
}


