import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';

import '../../../../repository/services/auth/auth.service.dart';
import '../login/animation.login.component.dart';

class ForgotPasswordAuthorizationView extends StatefulWidget {
  final email;
  ForgotPasswordAuthorizationView({Key? key, String? email})
      : email = email,
        super(key: key);

  State<ForgotPasswordAuthorizationView> createState() =>
      _ForgotPasswordAuthorizationViewState();
}

class _ForgotPasswordAuthorizationViewState
    extends State<ForgotPasswordAuthorizationView> {
  bool isloading = false, isSuccess = false;
  String confirmationCode = '';
  String newPassword = '';
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
                              margin: EdgeInsets.only(top: 0),
                              child: Center(
                                child: Text(
                                  "New Password",
                                  style: TextStyle(
                                      color: headerColor,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 50.0),
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
                                    onChanged: (value) {
                                      confirmationCode = value;
                                    },
                                    validator: (value) {
                                      if (value?.length == 0) {
                                        return 'Required';
                                      }
                                      return null;
                                    },
                                    style: TextStyle(color: Colors.grey[800]),
                                    decoration: InputDecoration(
                                      suffixIcon: GestureDetector(
                                          onTap: () {},
                                          child: Icon(Icons.edit,
                                              color: Colors.grey[700],
                                              size: 25)),
                                      fillColor: buttonsColor,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 3,
                                          color: Colors.grey,
                                        ), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                      hintStyle: TextStyle(color: buttonsColor),
                                      labelText: 'Confirmation Code',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      errorStyle: TextStyle(
                                          color: headerColor, fontSize: 13),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    toolbarOptions: ToolbarOptions(
                                        copy: false, cut: false, paste: false),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    onChanged: (value) {
                                      newPassword = value;
                                    },
                                    validator: (value) {
                                      if (value?.length == 0) {
                                        return 'Required';
                                      } else {
                                        return this.isValidPassword(value!);
                                      }
                                    },
                                    style: TextStyle(color: Colors.grey[800]),
                                    decoration: InputDecoration(
                                      suffixIcon: GestureDetector(
                                          onTap: () {},
                                          child: Icon(Icons.password_rounded,
                                              color: Colors.grey[700],
                                              size: 25)),
                                      fillColor: buttonsColor,
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 3,
                                          color: Colors.grey,
                                        ), //<-- SEE HERE
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                      ),
                                      hintStyle: TextStyle(color: buttonsColor),
                                      labelText: 'New Password',
                                      labelStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      errorStyle: TextStyle(
                                          color: headerColor, fontSize: 13),
                                    ),
                                  ),
                                )
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
                                FocusScopeNode currentFocus =
                                    FocusScope.of(context);
                                if (!currentFocus.hasPrimaryFocus) {
                                  currentFocus.unfocus();
                                }
                                if (confirmationCode.length > 0 &&
                                    newPassword.length > 0) {
                                  setState(() {
                                    isloading = true;
                                  });
                                  final result =
                                      await forgotPasswordConfirmation(
                                          this.widget.email,
                                          confirmationCode,
                                          newPassword);
                                  setState(() {
                                    if (result!.data!) {
                                      isSuccess = true;
                                    }
                                    isloading = false;
                                  });
                                  Navigator.pop(context);
                                  Navigator.pop(context);
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
                                                new AlwaysStoppedAnimation<
                                                    Color>(Colors.white),
                                          ),
                                        )
                                      : isSuccess
                                          ? Icon(
                                              Icons.done_outline_rounded,
                                              color: Colors.white,
                                              size: 30,
                                            )
                                          : Text(
                                              "Apply",
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

  String? isValidPassword(String value) {
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Should contain at least one upper case.';
    } else if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Should contain at least one lower case.';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Should contain at least one digit.';
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Should contain at least one Special character.';
    } else if (value.length <= 8) {
      return 'Must be at least 9 characters in length.';
    } else {
      return null;
    }
  }
}
