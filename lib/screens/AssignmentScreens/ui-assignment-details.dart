import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/design_course_app_theme.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_submission_form_screen.dart';

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
  bool _isSubmitting = false;
  String? _submissionUrl;
  bool _isOverdue = false;
  bool _isSubmitted = false;
PlatformFile? pickedFile;
UploadTask? uploadTask;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
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
                  color:  Color.fromARGB(255, 243, 164, 99),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32.0),
                      topRight: Radius.circular(32.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: DesignCourseAppTheme.grey.withOpacity(0.2),
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
                                color: DesignCourseAppTheme.darkerText,
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
                                    color: DesignCourseAppTheme
                                                .nearlyWhite,
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    // children: <Widget>[
                                    //   Text(
                                    //     //'${courseData['rating'] ?? '0.0'}',
                                    //     _isOverdue ? 'Overdue' : 'On Time',
                                    //     textAlign: TextAlign.left,
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.w200,
                                    //       fontSize: 22,
                                    //       letterSpacing: 0.27,
                                    //       color: DesignCourseAppTheme.grey,
                                    //     ),
                                    //   ),
                                    //   Icon(
                                    //     Icons.star,
                                    //     color: DesignCourseAppTheme.nearlyBlue,
                                    //     size: 24,
                                    //   ),
                                    // ],
                                  ),
                                )
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
                                //  getTimeBoxUI('${dueDate.toString()}', 'Due Date'),
                                  getTimeBoxUI('${_isOverdue ? 'Overdue' : 'On Time'}', ' Deadline Status'),
                                  getTimeBoxUI('${_isSubmitted ? 'Submitted' : 'Not Submitted'}', 'Submission Status'),
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
                          AnimatedOpacity(
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
                                        color: Color(0xff132137),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        border: Border.all(
                                            color: DesignCourseAppTheme.grey
                                                .withOpacity(0.2)),
                                      ),
                                      child: Icon(
                                        Icons.add,
                                        color: DesignCourseAppTheme
                                                .nearlyWhite,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Color(0xff132137),
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Color(0xff132137)
                                                  .withOpacity(0.5),
                                              offset: const Offset(1.1, 1.1),
                                              blurRadius: 10.0),
                                        ],
                                      ),
                                       child: ElevatedButton(
                                       
                                              onPressed: () {
                                      Navigator.push(
                                        context,
                                          
                                        MaterialPageRoute(
                                          
                                          builder: (context) => SubmissionFormScreen(
                                            assignmentId: widget.assignmentId,
                                          ),
                                        ),
                                      );
                                    },    style: ElevatedButton.styleFrom( backgroundColor: Color(0xff132137)
                                                  .withOpacity(0.5),),   
                                     child: Text('Submit Assignment',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                            color: DesignCourseAppTheme
                                                .nearlyWhite,
                                               )),),
                
           
                                    )  ),
                                    
                                  
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
                child: Card(
                  color: Color(0xff132137),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0)),
                  elevation: 10.0,
                  child: Container(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Icon(
                        Icons.favorite,
                        color: DesignCourseAppTheme.nearlyWhite,
                        size: 30,
                      ),
                    ),
                  ),
                ),
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
          color: Color(0xff132137),
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
