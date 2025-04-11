import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';

import '../../../../repository/services/auth/auth.service.dart';
import '../login/animation.login.component.dart';
import 'forgot_password_authorization.component.dart';

class ForgotPasswordView extends StatefulWidget {
  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  bool isloading = false, isSuccess = false;
  String email = '';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: LoginAnimation(
                            1.6,
                            Container(
                              margin: EdgeInsets.only(bottom: 50),
                              child: Center(
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                      color: headerColor,
                                      fontSize: 37,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 50, left: 20.0, right: 20.0, bottom: 70.0),
                  child: Column(
                    children: <Widget>[
                      LoginAnimation(
                          1.8,
                          Container(
                            padding: EdgeInsets.all(5),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    autocorrect: true,
                                    onChanged: (value) {
                                      email = value;
                                    },
                                    validator: (value) {
                                      if (value?.length == 0) {
                                        return 'Required';
                                      } else {
                                        return this.isValidEmail(value!)
                                            ? null
                                            : "Invalid Email";
                                      }
                                    },
                                    style: TextStyle(color: Colors.grey[800]),
                                    decoration: InputDecoration(
                                      suffixIcon: GestureDetector(
                                          onTap: () {},
                                          child: Icon(
                                              Icons.alternate_email_outlined,
                                              color: Colors.grey[700],
                                              size: 25)),
                                      fillColor: buttonsColor,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 3,
                                          color: Colors.grey[400]!,
                                        ), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                      hintStyle: TextStyle(color: buttonsColor),
                                      labelText: 'Email',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      errorStyle: TextStyle(
                                          color: headerColor, fontSize: 13),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 50,
                      ),
                      LoginAnimation(
                          2,
                          GestureDetector(
                              onTap: () async {
                                if (email.length > 0) {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  setState(() {
                                    isloading = true;
                                  });
                                  final result = await forgotPassword(email);
                                  setState(() {
                                    if (result!.data!) {
                                      isSuccess = true;
                                    }
                                    isloading = false;
                                  });
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ForgotPasswordAuthorizationView(
                                              email: email),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100.0),
                                    color: headerColor),
                                height: 50,
                                child: Center(
                                  child: isloading
                                      ? Container(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white)))
                                      : isSuccess
                                          ? Icon(
                                              Icons.done_outline_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          : Text(
                                              "Send",
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                ),
                              ))),
                      SizedBox(
                        height: 30,
                      ),
                      LoginAnimation(
                          1.5,
                          GestureDetector(
                              onTap: () {
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);

                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Back",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: headerColor,
                                ),
                              ))),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  bool isValidEmail(String value) {
    bool result = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
    return result;
  }
}
