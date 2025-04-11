import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import '../../../../repository/store/auth_view/phone_verification/phone_verification_bloc.dart';
import '../../../../repository/store/auth_view/phone_verification/phone_verification_event.dart';
import '../../../../repository/store/auth_view/phone_verification/phone_verification_state.dart';

class VerificationPhonePartial extends StatefulWidget {
  final String email;
  final String phone;

  VerificationPhonePartial({Key? key, String? email, String? phone})
      : email = email!,
        phone = phone!,
        super(key: key);

  @override
  State<VerificationPhonePartial> createState() =>
      _VerificationPhonePartialState();
}

class _VerificationPhonePartialState extends State<VerificationPhonePartial> {
  bool _isResendAgain = false;
  bool _isVerified = false;
  bool _isLoading = false;
  String _code = '';
  int _start = 5;
  int _currentIndex = 0;
  BuildContext? dialogContext;

  verify(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final registered = await confirmUserOTP(this.widget.email, _code);
    if (registered!.data!.length > 0) {
      setState(() {
        _isLoading = false;
        _isVerified = true;
      });
      context.read<PhoneVerificationBloc>().add(PhoneVerificationSubmitted());
    } else {
      setState(() {
        _code = '';
        _isLoading = false;
      });
      showDialogAlert(context);
    }
  }

  Future<void> resend() async {
    setState(() {
      _isResendAgain = true;
    });

    await resendUserOTP(this.widget.email);
    setState(() {
      _isVerified = false;
      _isResendAgain = false;
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_start < 2) {
          setState(() {
            _isResendAgain = false;
            _start = 5;
          });
          timer.cancel();
        } else {
          setState(() {
            _start = _start - 1;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      _currentIndex++;
      if (_currentIndex == 5) _currentIndex = 0;
    });
    return BlocListener<PhoneVerificationBloc, PhoneVerificationState>(
      listener: (context, state) {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeInDown(
              duration: Duration(milliseconds: 500),
              child: Text(
                "Verification",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: headerColor),
              )),
          SizedBox(
            height: 30,
          ),
          FadeInDown(
            delay: Duration(milliseconds: 500),
            duration: Duration(milliseconds: 500),
            child: Text(
              "Please enter the 6 digit code sent to  \n " + this.widget.phone,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: baseColor, height: 1.5),
            ),
          ),
          SizedBox(
            height: 30,
          ),

          // Verification Code Input
          FadeInDown(
            delay: Duration(milliseconds: 600),
            duration: Duration(milliseconds: 500),
            child: VerificationCode(
              length: 6,
              textStyle: TextStyle(fontSize: 20, color: baseColor),
              underlineColor: Colors.grey[700],
              keyboardType: TextInputType.number,
              underlineUnfocusedColor: Colors.grey[600],
              clearAll: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                      fontSize: 14.0,
                      decoration: TextDecoration.underline,
                      color: headerColor),
                ),
              ),
              onEditing: (value) {},
              onCompleted: (value) async {
                setState(() {
                  _code = value;
                });
                if (_code.length == 6) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  await verify(context);
                }
              },
            ),
          ),

          SizedBox(
            height: 20,
          ),
          FadeInDown(
            delay: Duration(milliseconds: 700),
            duration: Duration(milliseconds: 500),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code?",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
                TextButton(
                    onPressed: () {
                      if (_isResendAgain) return;
                      resend();
                    },
                    child: Text(
                      _isResendAgain
                          ? "Try again in " + _start.toString()
                          : "Resend",
                      style: TextStyle(color: headerColor),
                    ))
              ],
            ),
          ),
          SizedBox(
            height: 35,
          ),
          FadeInDown(
            delay: Duration(milliseconds: 800),
            duration: Duration(milliseconds: 500),
            child: GestureDetector(
              onTap: () async {
                FocusScopeNode currentFocus = FocusScope.of(context);
                if (!currentFocus.hasPrimaryFocus) {
                  currentFocus.unfocus();
                }
                if (_code.length == 6) {
                  await verify(context);
                }
              },
              child: Column(
                children: [
                  _isLoading
                      ? Container(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            backgroundColor: headerColor,
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : _isVerified
                          ? Icon(
                              Icons.check_circle,
                              color: headerColor,
                              size: 32,
                            )
                          : Text(
                              "",
                              style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                  Visibility(
                      visible: _isVerified,
                      child: SizedBox(
                        height: 15,
                      )),
                  Visibility(
                    child: Text(
                      "Sending Email Validation...",
                      style: TextStyle(color: buttonsColor, fontSize: 13),
                    ),
                    visible: _isVerified,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  showDialogAlert(BuildContext context) {
    Widget continueButton = TextButton(
      child: Text("Ok",
          style: TextStyle(
              color: headerColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Please try again...'),
      content: Text(
          'Incorrect Verification Code. Please enter a valid code or click Resend.'),
      actions: [
        continueButton,
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return alert;
        });
  }
}
