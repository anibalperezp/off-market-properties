import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/repository/store/auth_view/more/more_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'more_partial.component.dart';

class More extends StatefulWidget {
  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  UserRepository _userRepository = new UserRepository();

  String userSub = '';

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await AnalitysService().setCurrentScreen('more_screen', 'More');
      userSub = await _userRepository.readKey('user_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return MoreBloc(
          authenticationRepository:
              RepositoryProvider.of<AuthenticationRepository>(context),
        );
      },
      child: MorePartial(userSub: userSub),
    );
  }
}
