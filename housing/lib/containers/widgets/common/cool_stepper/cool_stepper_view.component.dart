import 'package:flutter/material.dart';

import 'cool_step.component.dart';
import 'cool_stepper_config.component.dart';

class CoolStepperView extends StatelessWidget {
  final CoolStep? step;
  final VoidCallback? onStepNext;
  final VoidCallback? onStepBack;
  final EdgeInsetsGeometry? contentPadding;
  final CoolStepperConfig? config;

  const CoolStepperView({
    Key? key,
    @required this.step,
    this.onStepNext,
    this.onStepBack,
    this.contentPadding,
    @required this.config,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final title = config!.isHeaderEnabled! && step!.isHeaderEnabled!
        ? Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      )
                      //Add floating action help button to title
                    ]),
              ],
            ),
          )
        : SizedBox();

    final content = Expanded(
      child: SingleChildScrollView(
        padding: contentPadding,
        child: step!.content,
      ),
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, content],
      ),
    );
  }
}
