import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/design_course_app_theme.dart';
import 'package:mobileprogramming/screens/Assignment/SubmitAssignmentScreen.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student-view-submission.dart';
import 'package:mobileprogramming/screens/AssignmentScreens/student_submission_form_screen.dart';

class ViewSubmissionScreen extends StatefulWidget {
    final String assignmentId;
  final String assignmentDescription;


  const ViewSubmissionScreen({Key? key, required this.assignmentId,  required this.assignmentDescription,}) : super(key: key);
 
  @override
  _ViewSubmissionScreenState createState() => _ViewSubmissionScreenState();
}

class _ViewSubmissionScreenState extends State<ViewSubmissionScreen> with TickerProviderStateMixin {
  final double infoHeight = 364.0;
  AnimationController? animationController;
  Animation<double>? animation;
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  double opacity3 = 0.0;
  bool _isOverdue = false;

PlatformFile? pickedFile;
UploadTask? uploadTask;
 final TextEditingController _notesController = TextEditingController();
  bool _isUploading = false;
 bool _isLoading = true;
  bool _isSaving = false;
  String? _submissionId;
  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: animationController!,
        curve: Interval(0, 1.0, curve: Curves.fastOutSlowIn)));
    setData();
    super.initState();
    // _checkSubmission();
    _fetchSubmission();
  }
  Future<void> _submitForm() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some answers before submitting.')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Get current user ID
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Prepare the submission data
      final submissionData = {
        'assignmentId': widget.assignmentId,
        'userId': userId,
        'notes': _notesController.text.trim(),
        'submittedAt': Timestamp.now(),
      };

      // Save to Firestore (submissions collection)
      await FirebaseFirestore.instance.collection('submissions').add(submissionData);

      setState(() {
        _isUploading = false;
      });

      // Navigate back or show a confirmation message
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment submitted successfully!')),
      );
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit assignment: ${e.toString()}')),
      );
    }
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
Future<void> _fetchSubmission() async {
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

      if (query.docs.isNotEmpty) {
        final submission = query.docs.first;
        _submissionId = submission.id;
        _notesController.text = submission['notes'];
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load submission: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveSubmission() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some notes before saving.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final submissionData = {
        'notes': _notesController.text.trim(),
        'submittedAt': Timestamp.now(),
      };

      if (_submissionId != null) {
        // Update existing submission
        await FirebaseFirestore.instance
            .collection('submissions')
            .doc(_submissionId)
            .update(submissionData);
      } else {
        // Create a new submission if none exists
        submissionData.addAll({
          'assignmentId': widget.assignmentId,
          'userId': userId,
        });
        await FirebaseFirestore.instance.collection('submissions').add(submissionData);
      }

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Submission saved successfully!')),
      );
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save submission: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    //final dueDate = widget.assignmentData['dueDateTime'].toDate();
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
                              widget.assignmentDescription,
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
                              //   Text(
                              //  //   dueDate.toString(),
                              //    // '\$${courseData['price'] ?? '0.00'}',
                              //     textAlign: TextAlign.left,
                              //     style: TextStyle(
                              //       fontWeight: FontWeight.w200,
                              //       fontSize: 22,
                              //       letterSpacing: 0.27,
                              //       color: Colors.indigo[800],
                              //     ),
                              //   ),
                                Container(
                                  child: Row(
                                    
                                  ),
                                )
                              ],
                            ),
                          ),
                  //              AnimatedOpacity(
                  //   duration: const Duration(milliseconds: 500),
                  //   opacity: opacity1,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8),
                  //     child: Row(
                  //       children: <Widget>[
                  //         // getTimeBoxUI(_isOverdue ? 'Overdue' : 'On Time', 'Deadline Status'),
                  //         // getTimeBoxUI(_hasSubmitted ? 'Submitted' : 'Not Submitted', 'Submission Status'),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: opacity2,
                              child:  Padding(
                            padding: const EdgeInsets.only(
                                top: 32.0, left: 18, right: 16),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _notesController,
                                  decoration: const InputDecoration(
                                    labelText: 'Edit Answer',
                                  ),
                                  maxLines: 8,
                              )],
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
                                  // Container(
                                  //   width: 48,
                                  //   height: 48,
                                  //   child: Container(
                                  //     decoration: BoxDecoration(
                                  //       color: Colors.indigo[800],
                                  //       borderRadius: const BorderRadius.all(
                                  //         Radius.circular(16.0),
                                  //       ),
                                  //       border: Border.all(
                                  //           color: DesignCourseAppTheme.grey
                                  //               .withOpacity(0.2)),
                                  //     ),
                                  //     child: Icon(
                                  //       Icons.book,
                                  //       color: DesignCourseAppTheme
                                  //               .nearlyWhite,
                                  //       size: 28,
                                  //     ),
                                  //   ),
                                  // ),
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
                              //          child: ElevatedButton(
                                       
                              // //         Navigator.push(
                              // //           context,
                                          
                              // // //           MaterialPageRoute(
                                          
                              // // //            builder: (context) => 
                              // // //            _hasSubmitted
                              // // // ? ViewSubmissionScreen(assignmentId: widget.assignmentId)
                              // // // : SubmissionFormScreen(assignmentId: widget.assignmentId),
                              // // //           ),
                              // //         );
                              //  onPressed: _isUploading ? null : _submitForm,
                                                                       
                              //        style: ElevatedButton.styleFrom( backgroundColor: Colors.indigo[800]!
                              //                     .withOpacity(0.5),),   
                              //        child: Text('Submit',
                              //             textAlign: TextAlign.left,
                              //             style: TextStyle(
                              //               fontWeight: FontWeight.w600,
                              //               fontSize: 18,
                              //               letterSpacing: 0.0,
                              //               color: DesignCourseAppTheme
                              //                   .nearlyWhite,
                              //                  )),),
                
           
                                    )  ,
                                  
                                ],
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
                                        color: Colors.indigo[800],
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(16.0),
                                        ),
                                        border: Border.all(
                                            color: DesignCourseAppTheme.grey
                                                .withOpacity(0.2)),
                                      ),
                                      child: Icon(
                                        Icons.assignment,
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
                                       
                              //         Navigator.push(
                              //           context,
                                          
                              // //           MaterialPageRoute(
                                          
                              // //            builder: (context) => 
                              // //            _hasSubmitted
                              // // ? ViewSubmissionScreen(assignmentId: widget.assignmentId)
                              // // : SubmissionFormScreen(assignmentId: widget.assignmentId),
                              // //           ),
                              //         );
                               onPressed: _isUploading ? null : 
                               _saveSubmission,
                                                                       
                                     style: ElevatedButton.styleFrom( backgroundColor: Colors.indigo[800]!
                                                  .withOpacity(0.5),  minimumSize: Size(240, 50)),   
                                     child:  _isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes',
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            letterSpacing: 0.0,
                                            color: DesignCourseAppTheme
                                                .nearlyWhite,
                                                
                                               )),)
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
