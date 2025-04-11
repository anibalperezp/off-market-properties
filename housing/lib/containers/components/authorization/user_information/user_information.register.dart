import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/user.facade.dart';
import 'package:zipcular/repository/store/auth_view/user_update/user_update_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/containers/components/authorization/user_information/user_information.form.component.dart';
import 'package:zipcular/models/user/user.dart';
import 'package:tuple/tuple.dart';

class UserInformation extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => UserInformation());
  }

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  @override
  void initState() {
    super.initState();
  }

  final Future<Tuple2<User?, String>> _loadAsyncData =
      Future<Tuple2<User?, String>>.delayed(
    const Duration(milliseconds: 300),
    () async {
      ResponseService response = await UserFacade().getUserService();
      if (response.hasConnection!) {
      } else {
        return Tuple2(null, '');
      }
      return Tuple2(response.data.item1, response.data.item1.sEmail);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: BlocProvider(
            create: (context) {
              return UserUpdateBloc(
                authenticationRepository:
                    RepositoryProvider.of<AuthenticationRepository>(context),
              );
            },
            child: FutureBuilder<Tuple2<User?, String>>(
                future: _loadAsyncData,
                builder: (BuildContext context,
                    AsyncSnapshot<Tuple2<User?, String>> snapshot) {
                  return snapshot.data != null
                      ? Center(
                          child: UserInformationPartial(
                              email: snapshot.data!.item2,
                              user: snapshot.data!.item1))
                      : Container();
                })));
  }
}
