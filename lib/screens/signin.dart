import 'package:flutter/material.dart';
import 'package:mobileprogramming/utils/color_utils.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("C82893"),
          hexStringToColor("9546C4"),
          hexStringToColor("5E61F4"),
        ])),
      ),
    );
  }
}
