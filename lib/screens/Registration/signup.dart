import 'package:flutter/material.dart';
import 'package:mobileprogramming/services/auth_service.dart';
import 'package:mobileprogramming/widgets/Signin/customTextField.dart';
import 'package:mobileprogramming/widgets/Signin/custom_button.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

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
                // SizedBox(height: 16),
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
                SizedBox(height: 30),
                CustomButton(
                  text: "Sign Up",
                  onPressed: () async {
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    const role = "user";

                    try {
                      await AuthService().signUp(email, password, role);
                      if (context.mounted) {
                        Navigator.pushNamed(context, '/user_home');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Sign-Up Failed: $e"),
                          ),
                        );
                      }
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
