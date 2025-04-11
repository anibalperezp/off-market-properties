import 'package:flutter/material.dart';
import 'package:zipcular/containers/components/authorization/main/main.auth.component.dart';

class MainView extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => MainView());
  }

  @override
  Widget build(BuildContext context) {
    return MainAuth();
  }
}
