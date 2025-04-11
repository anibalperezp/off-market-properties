import 'package:flutter/material.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/login/login.auth.component.dart';
import 'package:zipcular/containers/components/authorization/verification_email/verification_email.auth.component.dart';
import 'package:zipcular/containers/components/authorization/verification_phone/verification_phone.auth.component.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../login/animation.login.component.dart';

class SignUpView extends StatefulWidget {
  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  BuildContext? dialogContext;
  bool isLoading = false;
  String email = '';
  String emailConfirmed = '';
  String password = '';
  String phoneNumber = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailConfirmedController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(
      mask: '+1 (###) ###-####', filter: {"#": RegExp(r'[0-9]')});
  final _formKey = GlobalKey<FormState>();
  bool visiblePassword = false;
  bool verificationPhone = false;
  UserRepository userRepository = new UserRepository();

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailConfirmedController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Positioned(
                      child: LoginAnimation(
                          1.6,
                          Container(
                            margin: EdgeInsets.only(bottom: 50),
                            child: Center(
                              child: Text(
                                "Create Account",
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
                LoginAnimation(
                  1.8,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      toolbarOptions:
                          ToolbarOptions(copy: false, cut: false, paste: false),
                      controller: _emailController,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
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
                      style: TextStyle(color: Colors.grey[700]),
                      decoration: InputDecoration(
                        fillColor: buttonsColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.grey,
                          ), //<-- SEE HERE
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        hintStyle: TextStyle(color: buttonsColor),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        errorStyle: TextStyle(color: headerColor, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/
                LoginAnimation(
                  1.8,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        toolbarOptions: ToolbarOptions(
                            copy: false, cut: false, paste: false),
                        controller: _emailConfirmedController,
                        onChanged: (value) {
                          setState(() {
                            emailConfirmed = value;
                          });
                        },
                        onFieldSubmitted: (value) {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        validator: (value) {
                          if (value?.length == 0) {
                            return 'Required';
                          } else if (email != value) {
                            return "Email doesn't match";
                          } else {
                            return this.isValidEmail(value!)
                                ? null
                                : "Invalid Email";
                          }
                        },
                        style: TextStyle(color: Colors.grey[700]),
                        decoration: InputDecoration(
                          fillColor: buttonsColor,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.grey,
                            ), //<-- SEE HERE
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          hintStyle: TextStyle(color: buttonsColor),
                          labelText: 'Confirm Email',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          errorStyle:
                              TextStyle(color: headerColor, fontSize: 13),
                        )),
                  ),
                ),
                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/
                LoginAnimation(
                  1.8,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: TextFormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        toolbarOptions: ToolbarOptions(
                            copy: false, cut: false, paste: false),
                        controller: _passwordController,
                        obscureText: visiblePassword ? false : true,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        onFieldSubmitted: (value) {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        validator: (value) {
                          if (password.length == 0) {
                            return 'Required';
                          } else {
                            return this.isValidPassword(password);
                          }
                        },
                        style: TextStyle(color: Colors.grey[700]),
                        decoration: InputDecoration(
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  this.visiblePassword = !this.visiblePassword;
                                });
                              },
                              child: Icon(
                                  visiblePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[700])),
                          fillColor: buttonsColor,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 3,
                              color: Colors.grey,
                            ), //<-- SEE HERE
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          hintStyle: TextStyle(color: buttonsColor),
                          labelText: 'Password',
                          labelStyle: TextStyle(
                            color: Colors.grey[600],
                          ),
                          errorStyle:
                              TextStyle(color: headerColor, fontSize: 13),
                        )),
                  ),
                ),
                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/
                LoginAnimation(
                  1.8,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: TextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      toolbarOptions:
                          ToolbarOptions(copy: false, cut: false, paste: false),
                      controller: _phoneNumberController,
                      obscureText: false,
                      inputFormatters: [maskFormatter],
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                      onFieldSubmitted: (value) {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                      },
                      validator: (value) {
                        if (phoneNumber.length == 0) {
                          return 'Required';
                        } else if (value!.length < 17) {
                          return 'Must be at least 10 numbers.';
                        } else {
                          return null;
                        }
                      },
                      style: TextStyle(color: Colors.grey[700]),
                      decoration: InputDecoration(
                        fillColor: buttonsColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 3,
                            color: Colors.grey,
                          ), //<-- SEE HERE
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        hintStyle: TextStyle(color: buttonsColor),
                        labelText: 'Phone Number',
                        labelStyle: TextStyle(
                          color: Colors.grey[600],
                        ),
                        errorStyle: TextStyle(color: headerColor, fontSize: 13),
                      ),
                    ),
                  ),
                ),
                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/

                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/
                LoginAnimation(
                  1.8,
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Transform.scale(
                            scale: 1.3,
                            child: Checkbox(
                              value: this.verificationPhone,
                              checkColor: Colors.white,
                              activeColor: headerColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(5.0),
                                ),
                              ),
                              onChanged: (value) async {
                                setState(() {
                                  FocusScopeNode currentFocus =
                                      FocusScope.of(context);
                                  if (!currentFocus.hasPrimaryFocus) {
                                    currentFocus.unfocus();
                                  }
                                  this.verificationPhone = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "I consent to receive SMS verification codes",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                              SizedBox(
                                height: 2,
                              ),
                              Text(
                                "from Zeamless to verify my phone number.",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // -*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/-*/

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      LoginAnimation(
                        2,
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState != null &&
                                _formKey.currentState!.validate()) {
                              setState(() {
                                this.isLoading = true;
                              });
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              String result = await registerUser();
                              if (result.contains(AUTH_LOGIN)) {
                                await userRepository.writeToken('email', email);
                                showDialogAlert(
                                  context,
                                  'Registered User!',
                                  'The email or phone number you entered is associated with an existing user. Go to Login View.',
                                  LoginView(email: email),
                                );
                              } else if (result.contains(AUTH_PHONE) ||
                                  result.contains(CONFIRM_THROUGH_EMAIL) ||
                                  result.contains(CONFIRM_THROUGH_PHONE)) {
                                await userRepository.writeToken('email', email);
                                await userRepository.writeToken(
                                    'phone', phoneNumber);
                                await userRepository.writeToken(
                                    'password', password);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VerificationPhone(),
                                  ),
                                );
                              } else if (result.contains(AUTH_EMAIL)) {
                                await userRepository.writeToken('email', email);
                                await userRepository.writeToken(
                                    'phone', phoneNumber);
                                await userRepository.writeToken(
                                    'password', password);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VerificatoinEmail(),
                                  ),
                                );
                              }
                            }
                          },
                          child: this.isLoading
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      headerColor))
                              : Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _formKey.currentState != null &&
                                            _formKey.currentState!.validate() &&
                                            this.verificationPhone == true
                                        ? headerColor
                                        : Colors.grey[500],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                        ),
                      ),
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
                            style:
                                TextStyle(fontSize: 20.0, color: headerColor),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  registerUser() async {
    final fromBranchReferal =
        await userRepository.readKey('from_branch_referal');
    await userRepository.deleteToken('from_branch_referal');
    String? result = '';
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final registered = await registerCustomer(
        email, password, "+" + phoneNumber, fromBranchReferal);

    if (registered.data!.length == 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
              content: Text('Registration Failure',
                  style: TextStyle(color: Colors.red))),
        );
    } else {
      result = registered.data;
    }
    setState(() {
      this.isLoading = false;
    });
    return result;
  }

  bool isValidEmail(String value) {
    bool result = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(value);
    return result;
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

  showDialogAlert(
      BuildContext context, String title, String description, Widget widget) {
    Widget cancelButton = TextButton(
      child: Text("Continue",
          style: TextStyle(
              color: buttonsColor, fontSize: 15, fontWeight: FontWeight.bold)),
      onPressed: () async {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => widget,
          ),
        );
      },
    );
    Widget continueButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        cancelButton,
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
