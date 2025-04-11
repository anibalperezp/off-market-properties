import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/containers/components/authorization/verification_phone/verification_phone_partial.auth.component.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

import '../../../../repository/store/auth_view/phone_verification/phone_verification_bloc.dart';

class VerificationPhone extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => VerificationPhone());
  }

  @override
  _VerificatoinState createState() => _VerificatoinState();
}

class _VerificatoinState extends State<VerificationPhone> {
  UserRepository userRepository = new UserRepository();
  var email;
  var phone;

  @override
  void initState() {
    super.initState();
  }

  final Future<Tuple2<String, String>> _emailConfirm =
      Future<Tuple2<String, String>>.delayed(
    const Duration(seconds: 0),
    () async {
      UserRepository userRepository = new UserRepository();
      String sStatus = await userRepository.readKey('sAUTH_Status');
      String email = await userRepository.readKey('email');
      String phone = email;
      if (sStatus == AUTH_PHONE) {
        phone = await userRepository.readKey('phone');
      }
      final tuple = Tuple2<String, String>(email, phone);
      return tuple;
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
              return PhoneVerificationBloc(
                authenticationRepository:
                    RepositoryProvider.of<AuthenticationRepository>(context),
              );
            },
            child: FutureBuilder<Tuple2<String, String>>(
              future: _emailConfirm,
              builder: (BuildContext context,
                  AsyncSnapshot<Tuple2<String, String>> snapshot) {
                return snapshot.data == null
                    ? Container()
                    : VerificationPhonePartial(
                        email: snapshot.data!.item1,
                        phone: snapshot.data!.item2);
              },
            ),
          ),
        ),
      ),
    );
  }
}
