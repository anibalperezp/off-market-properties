import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/repository/store/auth_view/main_auth/main_auth_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/containers/components/authorization/login/login.auth.component.dart';
import 'package:zipcular/containers/components/authorization/registration/signup.auth.component.dart';
import 'package:zipcular/containers/components/authorization/verification_phone/verification_phone.auth.component.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:tuple/tuple.dart';
import 'animation.auth.component.dart';

class MainAuth extends StatefulWidget {
  @override
  _MainAuthState createState() => _MainAuthState();
}

class _MainAuthState extends State<MainAuth>
    with SingleTickerProviderStateMixin {
  final int delayedAmount = 500;
  UserRepository userRepository = new UserRepository();
  double? _scale;
  AnimationController? _controller;
  var email, phone, password, userName, authStatus, accessToken, gessWidget;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await AnalitysService().setCurrentScreen('first_screen', 'MainAuth');
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
  }

  final Future<Tuple2<String, String>> _calculation =
      Future<Tuple2<String, String>>.delayed(
    const Duration(milliseconds: 500),
    () async {
      UserRepository userRepository = new UserRepository();
      String userName = await userRepository.readKey('user_name');
      String authStatus = await userRepository.readKey('sAUTH_Status');
      final tuple = Tuple2<String, String>(userName, authStatus);
      return tuple;
    },
  );

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    _scale = 1 - _controller!.value;
    return Container(
      child: BlocProvider(
        create: (context) {
          return MainAuthBloc(
            authenticationRepository:
                RepositoryProvider.of<AuthenticationRepository>(context),
          );
        },
        child: FutureBuilder<Tuple2<String, String>>(
          future: _calculation, // a previously-obtained Future<String> or null
          builder: (BuildContext context,
              AsyncSnapshot<Tuple2<String, String>> snapshot) {
            return snapshot.data != null
                ? selectView(color, snapshot.data!.item1, snapshot.data!.item2)
                : Container();
          },
        ),
      ),
    );
  }

  Widget get _animatedButtonUI => GestureDetector(
      onTap: () async {
        await AnalitysService().setCurrentScreen('login_screen', 'LoginView');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LoginView(email: email ?? ''),
          ),
        );
      },
      child: Container(
        height: 60,
        width: 270,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: headerColor,
          boxShadow: [
            BoxShadow(
                color: Colors.grey[700]!, blurRadius: 3.0, offset: Offset(0, 1))
          ],
        ),
        child: Center(
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 21.0,
              color: Colors.white,
            ),
          ),
        ),
      ));

  void _onTapDown(TapDownDetails details) {
    _controller!.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller!.reverse();
  }

  loadMain(Color color, String userRole) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100.0,
              ),
              Image.asset(
                'assets/images/ic_launcher.png',
                height: 85,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: 20.0,
              ),
              MainAnimation(
                child: Text(
                  "Zeamless",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35.0,
                      color: Color.fromRGBO(65, 64, 66, 1)),
                ),
                delay: delayedAmount + 400,
              ),
              SizedBox(
                height: 20.0,
              ),
              MainAnimation(
                child: Column(children: [
                  Text(
                    'Creating Endless Opportunities.',
                    style: TextStyle(fontSize: 18.0, color: buttonsColor),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Join Us!',
                    style: TextStyle(fontSize: 19.0, color: buttonsColor),
                  ),
                ]),
                delay: delayedAmount + 700,
              ),
              SizedBox(
                height: 45.0,
              ),
              MainAnimation(
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  child: Transform.scale(
                    scale: _scale,
                    child: _animatedButtonUI,
                  ),
                ),
                delay: delayedAmount + 1000,
              ),
              SizedBox(
                height: 40.0,
              ),
              MainAnimation(
                child: GestureDetector(
                    onTap: () async {
                      await userRepository.readKey('from_branch_referal');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            if (authStatus == AUTH_PHONE ||
                                authStatus == AUTH_RESEND_PHONE) {
                              Future.delayed(Duration.zero, () async {
                                AnalitysService().setCurrentScreen(
                                    'signup_create_account_screen',
                                    'SignUpView');
                              });

                              return VerificationPhone();
                            } else {
                              Future.delayed(Duration.zero, () async {
                                AnalitysService().setCurrentScreen(
                                    'signup_create_account_screen',
                                    'SignUpView');
                              });
                              return SignUpView();
                            }
                          },
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: 270,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey[700]!,
                              blurRadius: 3.0,
                              offset: Offset(0, 1))
                        ],
                        color: headerColor,
                      ),
                      child: Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 21.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
                delay: delayedAmount + 1400,
              ),
              SizedBox(
                height: 160.0,
              ),
              MainAnimation(
                  delay: delayedAmount + 1800,
                  child:
                      // userRole == null || userRole == ''
                      //     ? MainPartial(userRepository: userRepository)
                      //     :
                      Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await AnalitysService().setCurrentScreen(
                              'main_screen', 'TermsOfUseView');
                          final Uri _url =
                              Uri.parse('https://zeamless.io/#/terms');
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            // can't launch url
                          }
                        },
                        child: Text(
                          'Terms Of Use',
                          style: TextStyle(
                              fontSize: 13.0,
                              color: headerColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      GestureDetector(
                        onTap: () async {
                          await AnalitysService().setCurrentScreen(
                              'main_screen', 'PrivacyPolicyView');
                          final Uri _url =
                              Uri.parse('https://zeamless.io/#/privacy');
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url,
                                mode: LaunchMode.externalApplication);
                          } else {
                            // can't launch url
                          }
                        },
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                              fontSize: 13.0,
                              color: headerColor,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        )));
  }

  selectView(Color color, String userRole, String authStatus) {
    authStatus = authStatus == null ? '' : authStatus;
    switch (authStatus) {
      case AUTH_PHONE:
        if (email != '') {
          return VerificationPhone();
        } else if (email == '') {
          return loadMain(color, userRole);
        }
        break;
      case AUTH_RESEND_PHONE:
        if (email != '') {
          return VerificationPhone();
        } else if (email == '') {
          return loadMain(color, userRole);
        }
        break;
      case CONFIRM_THROUGH_PHONE:
        if (email != '') {
          return VerificationPhone();
        } else if (email == '') {
          return loadMain(color, userRole);
        }
        break;
      case CONFIRM_THROUGH_EMAIL:
        if (email != '' && password != '' && accessToken == '') {
          return VerificationPhone();
        } else if (email == '' && password == '') {
          return loadMain(color, userRole);
        }
        break;
      case AUTH_EMAIL:
        if (email != '' && password != '' && accessToken == '') {
          return LoginView(email: email);
        } else if (email == '' && password == '') {
          return loadMain(color, userRole);
        }
        break;

      default:
        return loadMain(color, userRole);
    }
  }
}
