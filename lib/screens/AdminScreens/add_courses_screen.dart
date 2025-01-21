import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprogramming/models/user.dart';
import 'package:mobileprogramming/providers/courses_provider.dart';
import 'package:mobileprogramming/screens/partials/adminDrawer.dart';
import 'package:mobileprogramming/services/CourseService.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class AddCoursesScreen extends ConsumerStatefulWidget {
  final User admin;
  const AddCoursesScreen({super.key, required this.admin});

  @override
  ConsumerState<AddCoursesScreen> createState() {
    return _AddCoursesScreenState();
  }
}

class _AddCoursesScreenState extends ConsumerState<AddCoursesScreen> {
  final CourseService _courseService = CourseService();
  final DepartmentService _departmentService = DepartmentService();
  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  var _enteredName = '';
  var _enteredCode = '';
  var _selectedYear = '1';
  var _selectedDepartment = '';

  final List<String> years = ['1', '2', '3', '4', '5'];

  //To avoid memory leak
  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
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
    setState(() {
      _selectedYear = '1';
      _selectedDepartment = '';
    });
  }

  void _saveCourse() async {
    String uid = uuid.v4();
    try {
      await _courseService.addCourse(
        id: uid,
        name: _enteredName,
        code: _enteredCode,
        departmentId: _selectedDepartment,
        year: _selectedYear,
      );

      ref.read(courseStateProvider.notifier).fetchAllCourses(); // Reload courses

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

  Widget getCourseNameField() {
    return TextFormField(
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
    );
  }

  Widget getCourseCodeField() {
    return TextFormField(
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
    );
  }

  Widget getDepartmentsDropdown() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _departmentService.getAllDepartments(),
      builder: (context, snapshot) {
        List<DropdownMenuItem> depItems = [];
        if (!snapshot.hasData) {
          const CircularProgressIndicator();
        } else {
          final items = snapshot.data!;
          for (var item in items) {
            depItems.add(
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
                return "please select a Department";
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
            items: depItems,
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value!;
              });
            });
      },
    );
  }

  Widget getYearsDropdown() {
    return DropdownButtonFormField<String>(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the stream of courses using Riverpod
    final courses = ref.watch(courseStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Course",
        ),
      ),
      // widget: access the properties of the parent StatefulWidget class.
      drawer: AdminDrawer(user: widget.admin),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  getCourseNameField(),
                  SizedBox(height: 16),
                  getCourseCodeField(),
                  SizedBox(height: 16),
                  getDepartmentsDropdown(),
                  SizedBox(height: 16),
                  getYearsDropdown(),
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
