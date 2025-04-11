import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/main/force-update/force-update-partial.component.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/repository/store/force_update/force_update_bloc.dart';

class ForceUpdate extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => ForceUpdate());
  }

  @override
  State<ForceUpdate> createState() => _ForceUpdateState();
}

class _ForceUpdateState extends State<ForceUpdate> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return ForceUpdateBloc(
          authenticationRepository:
              RepositoryProvider.of<AuthenticationRepository>(context),
        );
      },
      child: ForceUpdatePartial(),
    );
  }
}
