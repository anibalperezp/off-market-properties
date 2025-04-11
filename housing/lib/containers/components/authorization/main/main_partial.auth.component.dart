import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

import '../../../../repository/store/auth_view/main_auth/main_auth_bloc.dart';
//import '../../../../store/auth_view/main_auth/main_auth_event.dart';
import '../../../../repository/store/auth_view/main_auth/main_auth_state.dart';

class MainPartial extends StatelessWidget {
  final UserRepository userRepository;
  MainPartial({Key? key, UserRepository? userRepository})
      : userRepository = userRepository!,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<MainAuthBloc, MainAuthState>(
        listener: (context, state) {}, child: Container()
        // GestureDetector(
        //     onTap: () async {
        //       await userRepository.writeToken('user_name', 'guess');
        //       context.read<MainAuthBloc>().add(MainAuthSubmitted());
        //     },
        //     child: Text(
        //       "Continue as Guess",
        //       style: TextStyle(
        //         fontSize: 22.0,
        //         fontWeight: FontWeight.bold,
        //         color: Color.fromRGBO(37, 106, 253, 1),
        //       ),
        //     )
        //     )
        );
  }
}
