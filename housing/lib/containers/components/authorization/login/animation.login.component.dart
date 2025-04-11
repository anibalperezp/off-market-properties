import 'package:flutter/material.dart';
import 'package:sa4_migration_kit/sa4_migration_kit.dart';
import 'package:supercharged/supercharged.dart';

enum AniProps { opacity, translateY }

class LoginAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final tween = MultiTween<AniProps>()
    ..add(AniProps.opacity, 0.0.tweenTo(1), 500.milliseconds)
    ..add(AniProps.translateY, (-30.0).tweenTo(0.0), 500.milliseconds,
        Curves.easeOut);

  LoginAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    return PlayAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: tween.duration,
      tween: tween,
      child: child,
      builder: (context, child, MultiTweenValues<AniProps> value) => Opacity(
        opacity: value.get(AniProps.opacity),
        child: Transform.translate(
            offset: Offset(0, value.get(AniProps.translateY)), child: child),
      ),
    );
  }
}
