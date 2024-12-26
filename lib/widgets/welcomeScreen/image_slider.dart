import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final PageController pageController;
  final List<String> images;
  final Function(int) onPageChanged;

  const ImageSlider({super.key, required this.pageController, required this.images, required this.onPageChanged});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return Center(
          child: Image.asset(
            images[index],
            height: 400,
            width: 400,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
