import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/DoctorService.dart';
import 'package:mobileprogramming/services/TaService.dart';
import 'package:mobileprogramming/services/user_service.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class EnrollInstructorScreen extends StatefulWidget {
  const EnrollInstructorScreen({super.key});

  @override
  State<EnrollInstructorScreen> createState() {
    return _EnrollInstructorScreenState();
  }
}

class _EnrollInstructorScreenState extends State<EnrollInstructorScreen> {
  final CourseService _courseService = CourseService();
  final DoctorService _doctorService = DoctorService();
  final UserService _userService = UserService();
  final TaService _taService = TaService();
  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();
  late String departmentId;

  final List<String> instructors = ['Doctor', 'Teaching Assistant'];
  var selectedCourse = '';
  var selectedDoctorName;
  var selectedTaName;
  var selectedInstructor;

  //hold value of textfields, called whnerver button is pressed
  void _submit() {
    final isValid = _form.currentState!.validate();
    //! -> will not be null, filled later, validate()-> bool
    if (isValid) {
      _form.currentState!.save();
      _EnrollInstructor();
    }
  }

  void _clearFields() {
    setState(() {
      selectedCourse = '';
      selectedInstructor;
      selectedDoctorName = '';
      selectedTaName = '';
    });
  }

  void _EnrollInstructor() {
    String _uuid = uuid.v4();
    try {
      if (selectedInstructor == 'Doctor') {
        _userService.enrollInstructor(selectedDoctorName, selectedCourse);
      } else if (selectedInstructor == 'Teaching Assistant') {
        _userService.enrollInstructor(selectedTaName, selectedCourse);
      }

      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Instructor enrolled successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to enroll instructor: $e')),
      );
    }
  }

  /// initialization is here:
  @override
  void initState() {
    super.initState();
    // selectedInstructor = "Doctor";
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve arguments passed via Navigator
    departmentId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enroll Instructors",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedInstructor, // currently selected value
                    // List of dropdown items
                    items: instructors.map((instructor) {
                      return DropdownMenuItem(
                        value: instructor,
                        child: Text(
                          instructor,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Updates the selected instructor with the new value
                      setState(() {
                        selectedInstructor = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Instructor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  if (selectedInstructor == "Doctor")
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream:
                          _doctorService.getDoctorByDepartmentId(departmentId),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> dritems = [];
                        if (!snapshot.hasData) {
                          const CircularProgressIndicator();
                        } else {
                          final items = snapshot.data!;
                          for (var item in items) {
                            dritems.add(
                              DropdownMenuItem(
                                value: item['id'],
                                child: Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        }
                        return DropdownButtonFormField(
                            validator: (value) {
                              if (value == null) {
                                return "please select a Doctor Name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Instructor Name',
                              border: OutlineInputBorder(),
                            ),
                            items: dritems,
                            onChanged: (value) {
                              setState(() {
                                selectedDoctorName = value!;
                              });
                            });
                      },
                    ),
                  if (selectedInstructor == "Teaching Assistant")
                    StreamBuilder<List<Map<String, dynamic>>>(
                      stream: _taService.getTaByDepartmentId(departmentId),
                      builder: (context, snapshot) {
                        List<DropdownMenuItem> taitems = [];
                        if (!snapshot.hasData) {
                          const CircularProgressIndicator();
                        } else {
                          final items = snapshot.data!;
                          for (var item in items) {
                            taitems.add(
                              DropdownMenuItem(
                                value: item['id'],
                                child: Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        }
                        return DropdownButtonFormField(
                            validator: (value) {
                              if (value == null) {
                                return "please select a Teaching Assitant Name";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Instructor Name',
                              border: OutlineInputBorder(),
                            ),
                            items: taitems,
                            onChanged: (value) {
                              setState(() {
                                selectedTaName = value!;
                              });
                            });
                      },
                    ),
                  SizedBox(height: 16),
                  StreamBuilder<List<Course>>(
                    stream:
                        _courseService.getCoursesByDepartmentId(departmentId),
                    builder: (context, snapshot) {
                      List<DropdownMenuItem> courseItems = [];
                      if (!snapshot.hasData) {
                        const CircularProgressIndicator();
                      } else {
                        final items = snapshot.data!;
                        for (var item in items!) {
                          courseItems.add(
                            DropdownMenuItem(
                              value: item.id,
                              child: Text(
                                item.name,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          );
                        }
                      }
                      return DropdownButtonFormField(
                          validator: (value) {
                            if (value == null) {
                              return "Please select a Course";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Course Name',
                            border: OutlineInputBorder(),
                          ),
                          items: courseItems,
                          onChanged: (value) {
                            setState(() {
                              selectedCourse = value!;
                            });
                          });
                    },
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'Enroll Instructor',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
