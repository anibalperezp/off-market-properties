import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/forgot_password/forgot_password.component.dart';
import 'package:zipcular/repository/store/auth_view/login/login_bloc.dart';
import 'package:zipcular/repository/store/auth_view/login/login_event.dart';
import 'package:zipcular/repository/store/auth_view/login/login_state.dart';
import 'animation.login.component.dart';

class LoginForm extends StatefulWidget {
  final String emailParam;
  LoginForm({Key? key, String? emailParam})
      : emailParam = emailParam!,
        super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  BuildContext? dialogContext;
  bool visiblePassword = false;
  String email = '';
  TextEditingController _emailController = TextEditingController(text: '');

  @override
  void initState() {
    this.email = widget.emailParam;
    _emailController = TextEditingController(text: this.email);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // context
    //     .read<LoginBloc>()
    //     .add(LoginUsernameChanged(this._emailController.text));
    return BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            showDialogAlert(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: <Widget>[
              LoginAnimation(
                  1.8,
                  Container(
                      padding: EdgeInsets.all(5),
                      child: BlocBuilder<LoginBloc, LoginState>(
                          buildWhen: (previous, current) =>
                              previous.username != current.username,
                          builder: (context, state) {
                            return Container(
                              padding: EdgeInsets.all(8.0),
                              child: TextFormField(
                                autocorrect: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller: _emailController,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                key: const Key(
                                    'loginForm_usernameInput_textField'),
                                onChanged: (username) {
                                  context
                                      .read<LoginBloc>()
                                      .add(LoginUsernameChanged(username));
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Required';
                                  }
                                  return null;
                                },
                                onEditingComplete: () {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                },
                                decoration: InputDecoration(
                                  fillColor: buttonsColor,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 3,
                                      color: Colors.grey[400]!,
                                    ), //<-- SEE HERE
                                    borderRadius: BorderRadius.circular(50.0),
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
                            );
                          }))),
              SizedBox(
                height: 10,
              ),
              //*/*/-*/-*/-*/-*/-*/-*/-*/-*/
              LoginAnimation(
                1.8,
                Container(
                  padding: EdgeInsets.all(5),
                  child: BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) =>
                          previous.password != current.password,
                      builder: (context, state) {
                        return Container(
                          padding: EdgeInsets.all(8.0),
                          child: TextFormField(
                            autocorrect: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: TextStyle(color: buttonsColor),
                            key: const Key('loginForm_passwordInput_textField'),
                            onChanged: (password) => context
                                .read<LoginBloc>()
                                .add(LoginPasswordChanged(password)),
                            onEditingComplete: () {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);

                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            obscureText: this.visiblePassword ? false : true,
                            decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        this.visiblePassword =
                                            !this.visiblePassword;
                                      });
                                    },
                                    child: Icon(
                                        this.visiblePassword
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Colors.grey[700])),
                                labelStyle: TextStyle(
                                  color: Colors.grey[600],
                                ),
                                fillColor: buttonsColor,
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 3,
                                    color: Colors.grey[400]!,
                                  ), //<-- SEE HERE
                                  borderRadius: BorderRadius.circular(50.0),
                                ),
                                hintStyle: TextStyle(color: buttonsColor),
                                errorStyle: TextStyle(
                                    color: headerColor, fontSize: 13)),
                          ),
                        );
                      }),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              //*/*/-*/-*/-*/-*/-*/-*/-*/-*/
              LoginAnimation(
                2,
                BlocBuilder<LoginBloc, LoginState>(
                  buildWhen: (previous, current) =>
                      previous.status != current.status,
                  builder: (context, state) {
                    return state.status.isSuccess
                        ? Column(
                            children: [
                              Container(
                                height: 35,
                                width: 35,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      headerColor),
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Loading Information...',
                                style: TextStyle(
                                    color: Colors.grey[700], fontSize: 15),
                              )
                            ],
                          )
                        : state.status.isInProgress
                            ? Container(
                                height: 35,
                                width: 35,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      headerColor),
                                ),
                              )
                            : GestureDetector(
                                onTap: () async {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);

                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  await AnalitysService().sendAnalyticsEvent(
                                      'login_button_click', {
                                    'device':
                                        Platform.isAndroid ? 'android' : 'ios',
                                    'email': _emailController.text
                                  });

                                  context
                                      .read<LoginBloc>()
                                      .add(const LoginSubmitted());
                                },
                                child: Container(
                                  key: const Key('loginForm_continue'),
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: headerColor,
                                    borderRadius: BorderRadius.circular(50),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Color.fromRGBO(65, 64, 66, 1),
                                          blurRadius: 1.0,
                                          offset: Offset(0, 1))
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Login",
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                  ),
                                ),
                              );
                  },
                ),
              ),
              SizedBox(
                height: 50,
              ),
              LoginAnimation(
                  1.5,
                  GestureDetector(
                      onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ForgotPasswordView(),
                            ),
                          ),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 19.0,
                          color: headerColor,
                        ),
                      ))),
              SizedBox(
                height: 20,
              ),
              LoginAnimation(
                  1.5,
                  GestureDetector(
                      onTap: () => {Navigator.pop(context)},
                      child: Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 20.0,
                          color: headerColor,
                        ),
                      ))),
            ],
          ),
        ));
  }

  showDialogAlert(BuildContext context) {
    Widget continueButton = TextButton(
      child: Text("Ok",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text('Please try again...'),
      content: Text(
          'The email and password you entered did not match our records. Please double-check or use Forgot Password.'),
      actions: [
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }
}
