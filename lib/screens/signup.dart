// signup_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/Signin/custom_button.dart';
import '../widgets/Signin/customTextField.dart';

class SignUpScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final roleController = TextEditingController(); // For role input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Create an Account",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                // SizedBox(height: 20),
                // CustomTextField(
                //   labelText: "Name",
                //   controller: nameController,
                // ),
                SizedBox(height: 16),
                CustomTextField(
                  labelText: "Email",
                  controller: emailController,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  labelText: "Password",
                  controller: passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 16),
                CustomTextField(
                  labelText: "Role (admin/user)",
                  controller: roleController,
                ),
                SizedBox(height: 30),
                CustomButton(
                  text: "Sign Up",
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final role = roleController.text.trim();

                    try {
                      await AuthService().signUp(email, password, role);
                      Navigator.pushReplacementNamed(context, './signin.dart');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sign-Up Failed: $e")));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
