import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/common.global.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/main/animation.auth.component.dart';
import 'package:zipcular/repository/store/force_update/force_update_bloc.dart';
import 'package:zipcular/repository/store/force_update/force_update_event.dart';
import 'package:zipcular/repository/store/force_update/force_update_state.dart';

class ForceUpdatePartial extends StatelessWidget {
  ForceUpdatePartial({Key? key}) : super(key: key);
  final int delayedAmount = 500;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForceUpdateBloc, ForceUpdateState>(
        listener: (context, state) {},
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/ic_launcher.png',
                  height: 70,
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 20),
                MainAnimation(
                  child: Text(
                    "Zeamless",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28.0,
                        color: Color.fromRGBO(65, 64, 66, 1)),
                  ),
                  delay: delayedAmount + 400,
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                MainAnimation(
                  child: Center(
                    child: Text(
                      "Current version is deprecated.",
                      style: TextStyle(fontSize: 19, color: buttonsColor),
                    ),
                  ),
                  delay: delayedAmount + 450,
                ),
                SizedBox(height: 5),
                MainAnimation(
                  child: Center(
                    child: Text(
                      "Please update the app.",
                      style: TextStyle(fontSize: 19, color: buttonsColor),
                    ),
                  ),
                  delay: delayedAmount + 500,
                ),
                SizedBox(height: 24),
                MainAnimation(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 32),
                      backgroundColor: headerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.0),
                      ),
                    ),
                    onPressed: () async {
                      await updateApp();
                      context
                          .read<ForceUpdateBloc>()
                          .add(ForceUpdateSubmitted());
                    },
                    child: Text('Update',
                        style: TextStyle(fontSize: 22, color: Colors.white)),
                  ),
                  delay: delayedAmount + 600,
                ),
              ],
            ),
          ),
        ));
  }
}
