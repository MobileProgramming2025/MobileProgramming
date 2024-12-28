import 'package:flutter/material.dart';
import '../../services/DoctorService.dart';

class EditDoctorScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  EditDoctorScreen({super.key, required this.doctor});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _specializationController = TextEditingController();
  final DoctorService _doctorService = DoctorService();

  @override
  void initState() {
    _nameController.text = doctor['name'];
    _emailController.text = doctor['email'];
    _specializationController.text = doctor['specialization'];
  }

  void _updateDoctor(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _doctorService.updateDoctor(
          id: doctor['id'],
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          specialization: _specializationController.text.trim(),
        );
        // Check if the widget is still in the tree before using context
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Doctor updated successfully")),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update doctor: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Doctor")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the name" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the email" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(labelText: "Specialization"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter the specialization" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _updateDoctor(context),
                child: const Text("Update"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
