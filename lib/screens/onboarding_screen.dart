import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mobileprogramming/widgets/welcomeScreen/custom_progress_bar.dart';
import 'package:mobileprogramming/widgets/welcomeScreen/get_started_button.dart';
import 'package:mobileprogramming/widgets/welcomeScreen/image_slider.dart';
import 'package:mobileprogramming/widgets/welcomeScreen/static_text_section.dartstatic_text_section.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _currentPage = 0;
  late Timer _timer;

  final List<String> images = [
    'assets/reading.png',
    'assets/slide1.png',
    'assets/slide2.png',
    'assets/slide3.png',
    'assets/slide4.png'
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPageChange();
  }

  void _startAutoPageChange() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; 
      }
      _pageController.animateToPage(
        _currentPage.toInt(),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index.toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B4EFF), Color(0xFFB881FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            CustomProgressBar(currentPage: _currentPage, totalPages: images.length),
            Expanded(child: ImageSlider(pageController: _pageController, images: images, onPageChanged: _onPageChanged)),
            const StaticTextSection(),
            const GetStartedButton(),
          ],
        ),
      ),
    );
  }
}
