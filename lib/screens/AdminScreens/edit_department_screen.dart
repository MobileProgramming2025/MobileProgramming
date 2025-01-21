import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditDepartmentScreen extends StatefulWidget {
  final String departmentId; // ID of the department to edit

  const EditDepartmentScreen({Key? key, required this.departmentId})
      : super(key: key);

  @override
  _EditDepartmentScreenState createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loadDepartmentData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Departments')
          .doc(widget.departmentId)
          .get();
      if (doc.exists) {
        setState(() {
          _nameController.text = doc['name'] ?? '';
          _capacityController.text = doc['capacity'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading department data: $e")),
      );
    }
  }

  Future<void> _updateDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('Departments')
          .doc(widget.departmentId)
          .update({
        'name': _nameController.text.trim(),
        'capacity': _capacityController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Department updated successfully!")),
      );
      Navigator.pop(context); // Go back after updating
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating department: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDepartmentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Department"),
      ),
       body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 Center(
                   child: Text(
                    "Edit Department Details",
                    style: Theme.of(context).textTheme.titleLarge,
                                   ),
                 ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Course Name',
                    border: OutlineInputBorder(),
                  ),
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter the department name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Capacity',
                    border: OutlineInputBorder(),
                  ),
                  controller: _capacityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter the capacity";
                    }
                    if (int.tryParse(value) == null) {
                      return "Capacity must be a number";
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),

                
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateDepartment,
                    
                    child: _isLoading
                        ? const CircularProgressIndicator(
                          )
                        : const Text(
                            "Update Department",
                            style: TextStyle(fontSize: 24),
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
