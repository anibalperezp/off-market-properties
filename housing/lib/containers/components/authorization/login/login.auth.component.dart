import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import '../../../../repository/store/auth_view/login/login_bloc.dart';
import 'animation.login.component.dart';
import 'login-form.dart';

class LoginView extends StatelessWidget {
  final String? email;
  LoginView({Key? key, String? email})
      : email = email!,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              LoginAnimation(
                1.6,
                Container(
                  margin: EdgeInsets.only(bottom: 40),
                  child: Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                          color: headerColor,
                          fontSize: 40,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              BlocProvider(
                create: (context) {
                  return LoginBloc(
                    authenticationRepository:
                        RepositoryProvider.of<AuthenticationRepository>(
                            context),
                  );
                },
                child: LoginForm(emailParam: email),
              )
            ],
          ),
        ),
      ),
    );
  }
}
