import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/auth_view/intro/intro_bloc.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/containers/components/authorization/intro/slider_partial.intro.dart';

class IntroSlider extends StatefulWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => IntroSlider());
  }

  @override
  State<IntroSlider> createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return IntroBloc(
          authenticationRepository:
              RepositoryProvider.of<AuthenticationRepository>(context),
        );
      },
      child: SliderPartialIntro(),
    );
  }
}
