import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/main/no-connection/no-connection-partial.component.dart';
import 'package:zipcular/repository/store/no_connection/no_connection_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';

class NoConnection extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => NoConnection());
  }

  @override
  State<NoConnection> createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return NoConnectionBloc(
          authenticationRepository:
              RepositoryProvider.of<AuthenticationRepository>(context),
        );
      },
      child: NoConnectionPartial(),
    );
  }
}
