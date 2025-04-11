import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/api_response.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    AuthenticationRepository? authenticationRepository,
    UserRepository? userRepository,
  })  : _authenticationRepository = authenticationRepository!,
        _userRepository = userRepository!,
        super(AuthenticationState.unknown()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<AuthenticationLogoutRequested>(_onAuthenticationLogoutRequested);
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(AuthenticationStatusChanged(status)),
    );
  }

  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  void _onAuthenticationStatusChanged(
    AuthenticationStatusChanged event,
    Emitter<AuthenticationState> emit,
  ) async {
    // Get local storage data
    // await _userRepository.writeToken('intro', 'TRUE'); // remove after demo
    // final intro = await _userRepository.readKey('intro');
    // final userSub = await _userRepository.readKey('user_name');
    final listingBranch = await _userRepository.readKey('from_branch_listing');
    final referalBranch = await _userRepository.readKey('from_branch_referal');

    String accessToken = "";
    String authStatus = "";
    final email = await _userRepository.readKey('email');
    final password = await _userRepository.readKey('password');

    //Verify user loged in
    if (email.isNotEmpty && password.isNotEmpty) {
      APIResponse<String> login =
          await signInWithCredentials(username: email, password: password);
      if (login.data!.isEmpty) {
        await _userRepository.deleteAll();
        return emit(AuthenticationState.unauthenticated());
      } else {
        String? token = await FirebaseMessaging.instance.getToken();
        accessToken = await _userRepository.readKey('access_token');
        authStatus = login.data!;
        await sendDeviceToken(token: token!, accessToken: accessToken);
      }
    }

    //Get user from storage
    bool connection = true; //response.item2;

    if (connection == false) {
      return emit(AuthenticationState.noConnection());
    }
    if (authStatus == FORCE_UPDATE) {
      return emit(AuthenticationState.forceUpdate());
    }

    if (authStatus == AUTH_SUCCESS) {
      if (listingBranch.isNotEmpty) {
        return emit(AuthenticationState.quickAccessListing());
      } else if (referalBranch.isNotEmpty) {
        return emit(AuthenticationState.quickAccessUser());
      } else {
        return emit(AuthenticationState.authenticated());
      }
    } else {
      switch (event.status) {
        case AuthenticationStatus.authenticated:
          late AuthenticationState state;
          if (authStatus == AUTH_SUCCESS) {
            state = AuthenticationState.authenticated();
          } else {
            state = AuthenticationState.unauthenticated();
          }
          return emit(state);
        case AuthenticationStatus.unauthenticated:
          AuthenticationState state;

          // if (intro.isEmpty) {
          //   await AnalitysService()
          //       .setCurrentScreen('intro_screen', 'IntroSliderScreen');
          //   state = AuthenticationState.intro();
          // }
          // if (userSub == "guess") {
          //   state = AuthenticationState.guess();
          // }

          if ((authStatus == AUTH_EMAIL ||
                  authStatus == AUTH_RESEND_EMAIL_CODE) &&
              (email.length > 0 &&
                  password.length > 0 &&
                  accessToken.length > 0)) {
            state = AuthenticationState.emailVerification();
          } else if (authStatus == AUTH_USER_INFO) {
            state = AuthenticationState.userUpdate();
          } else if (authStatus == AUTH_USER_NOT_CREATED) {
            state = AuthenticationState.unauthenticated();
          } else {
            state = AuthenticationState.unauthenticated();
          }
          return emit(state);

        case AuthenticationStatus.intro:
          return emit(AuthenticationState.intro());

        case AuthenticationStatus.guess:
          return emit(AuthenticationState.guess());

        case AuthenticationStatus.email_verification:
          return emit(AuthenticationState.emailVerification());

        case AuthenticationStatus.user_update:
          return emit(AuthenticationState.userUpdate());

        default:
          return emit(AuthenticationState.unknown());
      }
    }
  }

  void _onAuthenticationLogoutRequested(
    AuthenticationLogoutRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    _authenticationRepository.logOut();
  }
}
