import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/containers/components/authorization/intro/slider.intro.dart';
import 'package:zipcular/containers/components/authorization/maintain/maintain_mode.component.dart';
import 'package:zipcular/containers/components/authorization/user_information/user_information.register.dart';
import 'package:zipcular/containers/components/authorization/verification_email/verification_email.auth.component.dart';
import 'package:zipcular/containers/components/authorization/verification_phone/verification_phone.auth.component.dart';
import 'package:zipcular/main/force-update/force-update.component.dart';
import 'package:zipcular/main/no-connection/no-connection.component.dart';
import 'package:zipcular/main/home.dart';
import 'package:zipcular/main/listing.branch.dart';
import 'package:zipcular/main/login.dart';
import 'package:zipcular/main/profile.branch.dart';
import 'package:zipcular/repository/store/auth_view/authentication/authentication_bloc.dart';
import 'package:zipcular/repository/store/auth_view/authentication/authentication_state.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'package:zipcular/repository/store/splash/splash_page.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState!;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
        child: MaterialApp(
      navigatorObservers: <NavigatorObserver>[
        AnalitysService().observerAnalytics()
      ],
      theme: ThemeData(fontFamily: 'Roboto'),
      navigatorKey: _navigatorKey,
      builder: (context, child) {
        return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            switch (state.status) {
              case AuthenticationStatus.noConnection:
                _navigator.pushAndRemoveUntil<void>(
                  NoConnection.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.force_update:
                _navigator.pushAndRemoveUntil<void>(
                  ForceUpdate.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.intro:
                _navigator.pushAndRemoveUntil<void>(
                  IntroSlider.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.authenticated:
                _navigator.pushAndRemoveUntil<void>(
                  Home.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.unauthenticated:
                _navigator.pushAndRemoveUntil<void>(
                  MainView.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.guess:
                _navigator.pushAndRemoveUntil<void>(
                  Home.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.user_update:
                _navigator.pushAndRemoveUntil<void>(
                  UserInformation.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.email_verification:
                _navigator.pushAndRemoveUntil<void>(
                  VerificatoinEmail.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.phone_verification:
                _navigator.pushAndRemoveUntil<void>(
                  VerificationPhone.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.maintainance_mode:
                _navigator.pushAndRemoveUntil<void>(
                  MaintenanceMode.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.quick_access_user:
                _navigator.pushAndRemoveUntil<void>(
                  ProfileBranch.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.quick_access_listing:
                _navigator.pushAndRemoveUntil<void>(
                  ListingBranch.route(),
                  (route) => false,
                );
                break;

              case AuthenticationStatus.unknown:
                _navigator.pushAndRemoveUntil<void>(
                  MainView.route(),
                  (route) => false,
                );
                break;
            }
          },
          child: child,
        );
      },
      onGenerateRoute: (_) => SplashPage.route(),
    ));
  }
}
