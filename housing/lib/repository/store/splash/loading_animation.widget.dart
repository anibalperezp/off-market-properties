import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class LoadingAnimation extends StatefulWidget {
  LoadingAnimation({super.key});

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  Random random = Random();
  List<String> loadingTexts = [
    splashBucket + '/splash1.jpg',
    splashBucket + '/splash2.jpg',
    splashBucket + '/splash3.jpg',
    splashBucket + '/splash4.jpg',
    splashBucket + '/splash5.jpg'
  ];
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentTextIndex = random.nextInt(loadingTexts.length);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0),
      ),
    );

    _startAnimationLoop();
  }

  void _startAnimationLoop() {
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            // Check if the widget is still in the tree
            _controller.reset();
            // Create a Random object
            // Generate a random index
            setState(() {
              _currentTextIndex = random.nextInt(loadingTexts.length);
            });
            _controller.forward();
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 45, bottom: 5, left: 15, right: 15),
      alignment: Alignment.center,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: AnimatedOpacity(
          opacity: _fadeOutAnimation.value,
          duration: const Duration(milliseconds: 800),
          child: Image.network(
            loadingTexts[_currentTextIndex],
            height: MediaQuery.of(context).size.height * 0.85,
            width: MediaQuery.of(context).size.width * 0.90,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
