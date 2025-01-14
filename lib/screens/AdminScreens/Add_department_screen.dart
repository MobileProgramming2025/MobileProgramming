import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/DepartmentService.dart';
import 'package:uuid/uuid.dart';

final uuid = Uuid();

class AddDepartmentScreen extends StatefulWidget {
  const AddDepartmentScreen({super.key});

  @override
  State<AddDepartmentScreen> createState() {
    return _AddDepartmentScreenState();
  }
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final DepartmentService _departmentService = DepartmentService();
  //Doesn't allow to re-build form widget, keeps its internal state (show validation state or not)
  //Access form
  final _form = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();


  var _enteredName = '';
  var _enteredCapacity = '';



  //clean memory, To avoid memory leak
  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  //hold value of textfields, called whnerver button is pressed
  void _submit() {
    final isValid = _form.currentState!.validate();
    //! -> will not be null, filled later, validate()-> bool
    if (isValid) {
      _form.currentState!.save();
      _saveDepartment();
    }
  }

  void _clearFields() {
    _nameController.clear();
    _capacityController.clear();
  }

  void _saveDepartment() async {
    String _uuid = uuid.v4();
    try {
      await _departmentService.addDepartment(
        id: _uuid,
        name: _enteredName,
        capacity: _enteredCapacity,
        
      );
      // Check if the widget is still in the tree before using context
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department added successfully!')),
      );
      _clearFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add department: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add New Department",
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
                      labelText: 'Department Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Department Name";
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
                      labelText: 'Department Capacity',
                      border: OutlineInputBorder(),
                    ),
                    controller: _capacityController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "please enter a valid Department Capacity";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _enteredCapacity = value!;
                    },
                  ),
                  SizedBox(height: 16),
                 
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'Add Department',
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
