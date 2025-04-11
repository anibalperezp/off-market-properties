import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class MaintenanceMode extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => MaintenanceMode());
  }

  @override
  _MaintainModeState createState() => _MaintainModeState();
}

class _MaintainModeState extends State<MaintenanceMode> {
  UserRepository userRepository = new UserRepository();
  var email;
  var phone;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor, body: Center(child: Container()));
  }
}
