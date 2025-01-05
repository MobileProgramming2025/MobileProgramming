import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({super.key});

  @override
  State<AddCoursesScreen> createState() {
    return _AddCoursesScreenState();
  }
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final CourseService _courseService = CourseService();
  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _departmentController = TextEditingController();

  var _enteredName = '';
  var _enteredCode = '';
  var _enteredDepartment = '';
  var _selectedYear = '1';
  var _selectedDr = '';
  var _selectedTa = '';

  final List<String> years = ['1', '2', '3', '4', '5'];

  //To avoid memory leak
  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  //hold value of textfields, called whnerver button is pressed
  void _submit() {
    final isValid = _form.currentState!.validate();
    //! -> will not be null, filled later, validate()-> bool
    if (isValid) {
      _form.currentState!.save();
      _saveCourse();
    }
  }

  void _clearFields() {
    _nameController.clear();
    _codeController.clear();
    _departmentController.clear();
    setState(() {
      _selectedYear = '1';
    });
  }

  void _saveCourse() async {
    String _uuid = uuid.v4();
    try {
      await _courseService.addCourse(
        id: _uuid,
        name: _enteredName,
        code: _enteredCode,
        drName: _selectedDr,
        taName: _selectedTa,
        departmentName: _enteredDepartment,
        year: _selectedYear,
      );
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course added successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add course: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Course",
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Course Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Course Name";
                      }
                      return null;
                    },
                    //gets entered  automatically
                    onSaved: (value) {
                      _enteredName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Course Code',
                      border: OutlineInputBorder(),
                    ),
                    controller: _codeController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Course Code";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredCode = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      List<DropdownMenuItem> doctorItems = [];
                      if (!snapshot.hasData) {
                        const CircularProgressIndicator();
                      } else {
                        final items = snapshot.data?.docs.reversed.toList();
                        for (var item in items!) {
                          if (item['role'] == 'Doctor') {
                            doctorItems.add(
                              DropdownMenuItem(
                                value: item.id,
                                child: Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        }
                      }
                      return DropdownButtonFormField(
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "please select a Lecturer Name";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Lecturer Name',
                          border: OutlineInputBorder(),
                        ),
                        items: doctorItems,
                        onChanged: (value) {
                          setState(() {
                            _selectedDr = value!;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context, snapshot) {
                      List<DropdownMenuItem> taItems = [];
                      if (!snapshot.hasData) {
                        const CircularProgressIndicator();
                      } else {
                        final items = snapshot.data?.docs.reversed.toList();
                        for (var item in items!) {
                          if (item['role'] == 'Teaching Assistant') {
                            taItems.add(
                              DropdownMenuItem(
                                value: item.id,
                                child: Text(
                                  item['name'],
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            );
                          }
                        }
                      }
                      return DropdownButtonFormField(
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "please select a Teaching Assistant Name";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Teaching Assistant Name',
                            border: OutlineInputBorder(),
                          ),
                          items: taItems,
                          onChanged: (value) {
                            setState(() {
                              _selectedTa = value!;
                            });
                          });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Department Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _departmentController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Department Name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredDepartment = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedYear,
                    items: years.map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(
                          year,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedYear = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Education Year',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'Add Course',
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
