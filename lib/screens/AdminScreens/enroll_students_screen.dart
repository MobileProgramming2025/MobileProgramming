import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class EnrollStudentsScreen extends StatefulWidget {
  const EnrollStudentsScreen({super.key});

  @override
  State<EnrollStudentsScreen> createState() {
    return _EnrollStudentsScreenState();
  }
}

class _EnrollStudentsScreenState extends State<EnrollStudentsScreen> {
  final _form = GlobalKey<FormState>();

  // final _nameController = TextEditingController();
  // final _codeController = TextEditingController();
  // final _drNameController = TextEditingController();
  // final _taNameController = TextEditingController();
  // final _yearController = TextEditingController();
  // final _departmentController = TextEditingController();

  // var _enteredName = '';
  // var _enteredCode = '';
  // var _enteredDrName = '';
  // var _enteredTaName = '';
  // var _enteredYear = '';
  // var _enteredDepartment = '';

  //To avoid memory leak
  @override
  void dispose() {
    // _nameController.dispose();
    // _codeController.dispose();
    // _drNameController.dispose();
    // _taNameController.dispose();
    // _yearController.dispose();
    // _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enroll Students to Courses",
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            // key: _form,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Row(
                  //   children: [
                  //     TextFormField(
                  //       decoration: InputDecoration(
                  //         labelText: 'Choose Education Year...',
                  //         border: OutlineInputBorder(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 16),
                  // SizedBox(height: 20),
                  // Center(
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     child: Text(
                  //       'Add Course',
                  //       style: TextStyle(fontSize: 20),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void _clearFields() {
  // _nameController.clear();
  // _codeController.clear();
  // _drNameController.clear();
  // _taNameController.clear();
  // _yearController.clear();
  // _departmentController.clear();
}
