import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final double currentPage;
  final int totalPages;

  const CustomProgressBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 280,
          child: LinearProgressIndicator(
            value: (currentPage + 1) / totalPages,
            backgroundColor: const Color(0xFFB881FF),
            borderRadius: BorderRadius.circular(3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 255, 255, 255)),
            minHeight: 7,
          ),
        ),
      ),
    );
  }
}
