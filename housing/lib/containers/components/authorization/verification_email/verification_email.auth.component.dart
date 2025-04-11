import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/containers/components/authorization/verification_email/verification_email_partial.auth.component.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

import '../../../../repository/store/auth_view/email_verification/email_verification_bloc.dart';

class VerificatoinEmail extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => VerificatoinEmail());
  }

  @override
  _VerificatoinEmailState createState() => _VerificatoinEmailState();
}

class _VerificatoinEmailState extends State<VerificatoinEmail> {
  UserRepository userRepository = new UserRepository();
  var email;
  @override
  void initState() {
    super.initState();
  }

  final Future<String> _emailConfirm = Future<String>.delayed(
    const Duration(seconds: 0),
    () async {
      UserRepository userRepository = new UserRepository();
      String email = await userRepository.readKey('email');
      return email;
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: BlocProvider(
            create: (context) {
              return EmailVerificationBloc(
                authenticationRepository:
                    RepositoryProvider.of<AuthenticationRepository>(context),
              );
            },
            child: FutureBuilder<String>(
              future: _emailConfirm,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return snapshot.data != null
                    ? VerificationPartial(email: snapshot.data)
                    : Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
