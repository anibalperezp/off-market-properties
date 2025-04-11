import 'dart:async';

import 'package:flutter/cupertino.dart';

class MainAnimation extends StatefulWidget {
  final Widget? child;
  final int? delay;

  MainAnimation({@required this.child, this.delay});

  @override
  _MainAnimationState createState() => _MainAnimationState();
}

class _MainAnimationState extends State<MainAnimation>
    with TickerProviderStateMixin {
  AnimationController? _controller;
  Animation<Offset>? _animOffset;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    final curve =
        CurvedAnimation(curve: Curves.decelerate, parent: _controller!);
    _animOffset =
        Tween<Offset>(begin: const Offset(0.0, 0.35), end: Offset.zero)
            .animate(curve);

    if (widget.delay == null) {
      _controller!.forward();
    } else {
      Timer(Duration(milliseconds: widget.delay!), () {
        if (mounted) {
          _controller!.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      child: SlideTransition(
        position: _animOffset!,
        child: widget.child,
      ),
      opacity: _controller!,
    );
  }
}
