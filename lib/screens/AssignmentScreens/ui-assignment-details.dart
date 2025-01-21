import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/design_course_app_theme.dart';
import 'package:mobileprogramming/screens/Assignment/SubmitAssignmentScreen.dart';
// import 'package:mobileprogramming/screens/AssignmentScreens/student-view-submission.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/ui-student-submission.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/ui-student-view-submission.dart';
// import 'package:mobileprogramming/screens/AssignmentScreens/student_submission_form_screen.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  final Map<String, dynamic> assignmentData;

  
  const AssignmentDetailScreen({
    super.key,
    required this.assignmentId,
    required this.assignmentData,
  });
  @override
  _AssignmentDetailScreenState createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  bool _isOverdue = false;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
    String? _submissionUrl;
  String? _submissionGrade;
  String? _gradeStatus = "Not graded yet";
PlatformFile? pickedFile;
UploadTask? uploadTask;
 bool _isLoading = true;
  bool _hasSubmitted = false;
    String _submissionStatus = 'Not Submitted';
  DateTime? _dueDate;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
    _checkSubmission();
     _fetchAssignmentDetails();
     _fetchSubmissionData();
  }
  Future<void> _fetchSubmissionData() async {
    final userId = widget.assignmentData['userId']; // Replace with actual user ID (from auth)
    final firestoreRef = FirebaseFirestore.instance
      .collection('submissions')
      .where('assignmentId', isEqualTo: widget.assignmentId)
      .where('userId', isEqualTo: userId)
      .limit(1);

    final querySnapshot = await firestoreRef.get();

    if (querySnapshot.docs.isNotEmpty) {
     final submissionDoc = querySnapshot.docs.first;
    final data = submissionDoc.data();
      setState(() {
        _isSubmitted = true;
        _submissionUrl = data['notes'];
        _submissionGrade = data['grade'];
        _gradeStatus = _submissionGrade ?? "Not graded yet";
      });
    } else {
      setState(() {
        _isSubmitted = false;
        _gradeStatus = "Not graded yet";
      });
    }
  }
  Future<void> _fetchAssignmentDetails() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Fetch the assignment details
      final assignmentSnapshot = await FirebaseFirestore.instance
          .collection('assignments')
          .doc(widget.assignmentId)
          .get();

      if (assignmentSnapshot.exists) {
        final assignmentData = assignmentSnapshot.data();
        _dueDate  = (assignmentData?['dueDateTime'] as Timestamp?)?.toDate();

        // Check if the assignment is overdue
        if (_dueDate != null && _dueDate!.isBefore(DateTime.now())) {
          _isOverdue = true;
        }

        // Check if the user has submitted the assignment
        final submissionSnapshot = await FirebaseFirestore.instance
            .collection('submissions')
            .where('assignmentId', isEqualTo: widget.assignmentId)
            .where('userId', isEqualTo: userId)
            .get();

        if (submissionSnapshot.docs.isNotEmpty) {
          _hasSubmitted = true;
          _submissionStatus = 'Submitted';
        } else if (_isOverdue) {
          _submissionStatus = 'Overdue';
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch assignment details: ${e.toString()}')),
      );
    }
  }
  Future<void> _checkSubmission() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final query = await FirebaseFirestore.instance
          .collection('submissions')
          .where('assignmentId', isEqualTo: widget.assignmentId)
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        _hasSubmitted = query.docs.isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to check submission: ${e.toString()}')),
      );
    }
  }

Future<void> _submitAssignment() async {
  // try {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     print('Error: User is not authenticated');
  //     return;
  //   }

  //   final userId = user.uid;
  //   final assignmentId = widget.assignmentId; // From the widget data
  //   final result = await FilePicker.platform.pickFiles();

  //   if (result == null || result.files.single.path == null) {
  //     debugPrint('No file selected');
  //     return;
  //   }

  //   final filePath = result.files.single.path!;
  //   final fileName = result.files.single.name;
  //   final file = File(filePath);

  //   debugPrint('Selected file path: $filePath');
  //   debugPrint('File name: $fileName');

  //   // Sanitize file name if necessary
  //   final sanitizedFileName = Uri.encodeComponent(fileName);

  //   // Firebase Storage Reference
  //   final storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('submissions/$userId/$assignmentId/$sanitizedFileName');
  //   debugPrint('Storage Ref Path: submissions/$userId/$assignmentId/$sanitizedFileName');

  //   // Upload the file to Firebase Storage
  //   final uploadTask = storageRef.putFile(file);
  //   final snapshot = await uploadTask;

  //   // Retrieve the download URL
  //   final fileUrl = await snapshot.ref.getDownloadURL();

  //   debugPrint('File uploaded successfully: $fileUrl');

  //   // Save submission data to Firestore
  //   final firestoreRef = FirebaseFirestore.instance
  //       .collection('submissions')
  //       .doc(); // Auto-generate a document ID for each submission

  //   await firestoreRef.set({
  //     'userId': userId,
  //     'assignmentId': assignmentId,
  //     'fileName': fileName,
  //     'fileUrl': fileUrl,  // Store the file URL in Firestore
  //     'submittedAt': FieldValue.serverTimestamp(),
  //   });

  //   debugPrint('Submission saved to Firestore successfully.');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Assignment submitted successfully!')),
  //   );
  // } catch (e) {
  //   debugPrint('Error during submission: $e');
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Failed to submit assignment: $e')),
  //   );
  // }
}


  Future<void> setData() async {
    animationController?.forward();
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity1 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity2 = 1.0;
    });
    await Future<dynamic>.delayed(const Duration(milliseconds: 200));
    setState(() {
      opacity3 = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dueDate = widget.assignmentData['dueDateTime'].toDate();
    final double tempHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).size.width / 1.2) +
        24.0;
   // final courseData = widget.courseData;
    return Container(
      color: DesignCourseAppTheme.nearlyWhite,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.asset('assets/submit-assignment.jpg'),
                ),
              ],
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color:  Color.fromARGB(255, 245, 241, 236),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.indigo[800]!,
                        offset: const Offset(1.1, 1.1),
                        blurRadius: 10.0),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: BoxConstraints(
                          minHeight: infoHeight,
                          maxHeight: tempHeight > infoHeight
                              ? tempHeight
                              : infoHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 32.0, left: 18, right: 16),
                            child: Text(
                              widget.assignmentData['title'],
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                letterSpacing: 0.27,
                                color: Colors.indigo[800],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 8, top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  dueDate.toString(),
                                 // '\$${courseData['price'] ?? '0.00'}',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 22,
                                    letterSpacing: 0.27,
                                    color: Colors.indigo[800],
                                  ),
                                ),
                             
                              ],
                            ),
                          ),
                               AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: opacity1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: <Widget>[
                          getTimeBoxUI(_isOverdue ? 'Overdue' : 'On Time', 'Deadline Status'),
                          getTimeBoxUI(_hasSubmitted ? 'Submitted' : 'Not Submitted', 'Submission Status'),
                        ],
                      ),
                    ),
                  ),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, right: 16, top: 8, bottom: 8),
                                child: Text(
                                widget.assignmentData['description'] ??
                                      'No description available.',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontSize: 14,
                                    letterSpacing: 0.27,
                                    color: DesignCourseAppTheme.grey,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                
                              ),
                            ),
                          ),
                             Container(
                                  child: Column(
                                    children: <Widget>[
                                         Text(
                                        'Grade',
                                       
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontSize: 22,
                                          letterSpacing: 0.27,
                                          color: DesignCourseAppTheme.grey,
                                        ),
                                      ),
                                      Text(
                                        
                                         _gradeStatus ?? "Not graded yet",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w200,
                                          fontSize: 22,
                                          letterSpacing: 0.27,
                                          color: DesignCourseAppTheme.grey,
                                        ),
                                      ),
                                      // Icon(
                                      //   Icons.grade,
                                      //   color: Colors.indigo[800],
                                      //   size: 24,
                                      // ),
                                    ],
                                  ),
                                )
                        //    Expanded(
                        //     child: AnimatedOpacity(
                        //       duration: const Duration(milliseconds: 500),
                        //       opacity: opacity2,
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             left: 16, right: 16, top: 8, bottom: 1),
                        //         child: Text(
                        //     'Grade:',
                        //           textAlign: TextAlign.justify,
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.w700,
                        //             fontSize: 18,
                        //             letterSpacing: 0.27,
                        //             color: Colors.indigo[800]!,
                        //           ),
                        //           maxLines: 3,
                        //           overflow: TextOverflow.ellipsis,
                        //         ),
                                
                        //       ),
                        //     ),
                        //   ),
                        // Expanded(
                        //     child: AnimatedOpacity(
                        //       duration: const Duration(milliseconds: 500),
                        //       opacity: opacity2,
                        //       child: Padding(
                        //         padding: const EdgeInsets.only(
                        //             left: 16, right: 16, top: 1, bottom: 8),
                        //         child: Text(
                        //     _gradeStatus ?? "Not graded yet",
                        //           textAlign: TextAlign.justify,
                        //           style: TextStyle(
                        //             fontWeight: FontWeight.w700,
                        //             fontSize: 18,
                        //             letterSpacing: 0.27,
                        //             color: const Color.fromARGB(255, 57, 57, 58)!,
                        //           ),
                        //           maxLines: 3,
                        //           overflow: TextOverflow.ellipsis,
                        //         ),
                                
                        //       ),
                        //     ),
                        //   ),

                          ,AnimatedOpacity(
                            duration: const Duration(milliseconds: 500),
                            opacity: opacity3,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, bottom: 16, right: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 48,
                                    height: 48,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[800],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        border: Border.all(
                                            color: DesignCourseAppTheme.grey
                                                .withOpacity(0.2)),
                                      ),
                                      child: Icon(
                                        Icons.book,
                                        color: DesignCourseAppTheme
                                                .nearlyWhite,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                    
                                  ),

                                  // Expanded(
                                    Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.indigo[800],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Colors.indigo[800]!.withOpacity(0.5),
                                                 
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                       child: ElevatedButton(
                                       
                                              onPressed: () {
                                      Navigator.push(
                                        context,
                                          
                                        MaterialPageRoute(
                                          
                                         builder: (context) => _hasSubmitted
                              ? ViewSubmissionScreen(assignmentId: widget.assignmentId ,assignmentDescription: widget.assignmentData['description'])
                              : SubmissionFormScreen(assignmentId: widget.assignmentId,assignmentDescription: widget.assignmentData['description']),
                                        ),
                                      );
                                    } ,                                      
                                     style: ElevatedButton.styleFrom( backgroundColor: Colors.indigo[800]!
                                                  .withOpacity(0.5),),   
                                     child: Text(_hasSubmitted ? 'Edit Submission' : 'Submit Assignment',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                            color: DesignCourseAppTheme
                                                .nearlyWhite,
                                               )),
                                               )
                                               ,
                
           
                                    )  ,
                                    
                                         
                                
                                  
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom,
                          )
                        ],
                      ),
                      
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: (MediaQuery.of(context).size.width / 1.2) - 24.0 - 35,
              right: 35,
              child: ScaleTransition(
                alignment: Alignment.center,
                scale: CurvedAnimation(
                    parent: animationController!, curve: Curves.fastOutSlowIn),
                // child: Card(
                //   color:Colors.indigo[800],
                //   shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(50.0)),
                //   elevation: 10.0,
                //   child: Container(
                //     width: 60,
                //     height: 60,
                //     child: Center(
                //       child: Icon(
                //         Icons.favorite,
                //         color: DesignCourseAppTheme.nearlyWhite,
                //         size: 30,
                //       ),
                //     ),
                //   ),
                // ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 8,
                  right: 8),
              child: SizedBox(
                width: AppBar().preferredSize.height,
                height: AppBar().preferredSize.height,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                        AppBar().preferredSize.height),
                    child: Icon(
                      Icons.arrow_back_ios,
                      color: DesignCourseAppTheme.nearlyBlack,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getTimeBoxUI(String text1, String text2) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo[800],
          borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: const Color.fromARGB(255, 174, 187, 196).withOpacity(0.2),
                offset: const Offset(1.1, 1.1),
                blurRadius: 8.0),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 18.0, right: 18.0, top: 12.0, bottom: 12.0),
          child: Column(
            children: <Widget>[
              Text(
                text1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: DesignCourseAppTheme.nearlyWhite,
                ),
              ),
              Text(
                text2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w200,
                  fontSize: 14,
                  letterSpacing: 0.27,
                  color: const Color.fromARGB(255, 159, 171, 179),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
