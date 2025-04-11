import 'package:flutter/material.dart';
import 'package:zipcular/commons/common.global.dart';

class AnimatedButton extends StatefulWidget {
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _animation = ColorTween(
      begin: Color.fromARGB(255, 243, 212, 33),
      end: Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return TextButton(
          onPressed: () async {
            await updateApp();
          },
          style: TextButton.styleFrom(
            shadowColor: Colors.grey[800],
            elevation: 5,
            backgroundColor: _animation.value ?? Colors.blue,
          ),
          child: Text(
            'Update App',
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }
}
