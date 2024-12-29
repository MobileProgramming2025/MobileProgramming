import 'package:flutter/material.dart';

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

  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _drNameController.dispose();
    _taNameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  //hold value of textfields, called whnerver button is pressed
  void _submit() {
    final isValid = _form.currentState!.validate(); //! -> will not be null, filled later, validate()-> bool

    if(isValid){
      _form.currentState!.save();
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
                      }),
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
                      }),
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
                      }),
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
                      }),
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
                      }),
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
