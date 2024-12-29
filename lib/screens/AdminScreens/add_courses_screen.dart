import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Course.dart';

class AddCoursesScreen extends StatefulWidget {
  const AddCoursesScreen({super.key});

  @override
  State<AddCoursesScreen> createState() {
    return _AddCoursesScreenState();
  }
}

class _AddCoursesScreenState extends State<AddCoursesScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _drNameController = TextEditingController();
  final _taNameController = TextEditingController();
  final _yearController = TextEditingController();
  final _departmentController = TextEditingController();

  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  var _enteredName = '';
  var _enteredCode = '';
  var _enteredDrName = '';
  var _enteredTaName = '';
  var _enteredYear = '';

  //hold value of textfields, called whnerver button is pressed
  void _submit() {
    final isValid = _form.currentState!.validate();
    //! -> will not be null, filled later, validate()-> bool

    if (isValid) {
      _form.currentState!.save();
      print(_enteredName);
      print(_enteredCode);
      print(_enteredDrName);
      print(_enteredTaName);
      print(_enteredYear);
      _addCourse();
    }
  }

  Future<void> _addCourse() async {
    Course newCourse = Course(
      name: _enteredName,
      code: _enteredCode,
      drName: _enteredDrName,
      taName: _enteredTaName,
      departmentName: _departmentController.text.trim(),
      year: _enteredYear,
    );

    try {
      await newCourse.saveToFirestore();
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

  void _clearFields() {
    _nameController.clear();
    _codeController.clear();
    _drNameController.clear();
    _taNameController.clear();
    _departmentController.clear();
    _yearController.clear();
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
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lecturer Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _drNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Lecturer Name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredDrName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Teaching Assistant Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _taNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Course Name";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredTaName = value!;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Eductaion Year',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    controller: _yearController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Education Year";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredYear = value!;
                    },
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
