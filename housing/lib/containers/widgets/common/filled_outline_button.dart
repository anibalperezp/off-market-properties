import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';

class FillOutlineButton extends StatelessWidget {
  const FillOutlineButton({
    Key? key,
    this.isFilled = true,
    this.press,
    this.text,
  }) : super(key: key);

  final bool? isFilled;
  final VoidCallback? press;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Colors.white),
      ),
      elevation: isFilled! ? 2 : 0,
      color: isFilled! ? headerColor : Colors.grey[600],
      onPressed: press,
      child: Text(
        text!,
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
        ),
      ),
    );
  }
}
