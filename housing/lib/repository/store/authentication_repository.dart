import 'dart:async';
import 'package:zipcular/commons/analytics.service.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';

enum AuthenticationStatus {
  intro,
  unknown,
  authenticated,
  email_verification,
  phone_verification,
  user_update,
  unauthenticated,
  maintainance_mode,
  quick_access_user,
  quick_access_listing,
  noConnection,
  force_update,
  guess,
}

class AuthenticationRepository {
  final _controller = StreamController<AuthenticationStatus>();

  Stream<AuthenticationStatus> get status async* {
    yield AuthenticationStatus.unauthenticated;
    yield* _controller.stream;
  }

  Future<void> logIn({
    required String username,
    required String password,
  }) async {
    var status =
        await signInWithCredentials(username: username, password: password);
    if (status.data!.length > 0) {
      switch (status.data) {
        case AUTH_SUCCESS:
          _controller.add(AuthenticationStatus.authenticated);
          break;

        case AUTH_EMAIL:
          _controller.add(AuthenticationStatus.email_verification);
          await AnalitysService()
              .setCurrentScreen('signup_verify_email', 'EmailVerification');
          break;

        case AUTH_RESEND_EMAIL_CODE:
          _controller.add(AuthenticationStatus.email_verification);
          break;

        case AUTH_PHONE:
          _controller.add(AuthenticationStatus.phone_verification);
          await AnalitysService()
              .setCurrentScreen('signup_verify_phone', 'PhoneVerification');
          break;

        case AUTH_USER_INFO:
          _controller.add(AuthenticationStatus.user_update);
          await AnalitysService()
              .setCurrentScreen('signup_user_info', 'UserRegustragionView');
          break;

        case AUTH_MAINTAINANCE_MODE:
          _controller.add(AuthenticationStatus.maintainance_mode);
          await AnalitysService()
              .setCurrentScreen('maintainance_viwe', 'MaintainanceView');
          break;

        case QUICK_ACCESS_USER:
          _controller.add(AuthenticationStatus.quick_access_user);
          await AnalitysService()
              .setCurrentScreen('quick_access_user', 'QuickAccessUserView');
          break;

        case QUICK_ACCESS_LISTING:
          _controller.add(AuthenticationStatus.quick_access_listing);
          await AnalitysService().setCurrentScreen(
              'quick_access_listing', 'QuickAccessListingView');
          break;

        case NO_CONNECTION:
          _controller.add(AuthenticationStatus.noConnection);
          await AnalitysService()
              .setCurrentScreen('no_connection', 'NoConnectionView');
          break;

        case FORCE_UPDATE:
          _controller.add(AuthenticationStatus.force_update);
          await AnalitysService()
              .setCurrentScreen('force_update', 'ForceUpdateView');
          break;
      }
    } else {
      throw Exception(status.errorMessage);
    }
  }

  void intro() {
    _controller.add(AuthenticationStatus.intro);
  }

  void guess() {
    _controller.add(AuthenticationStatus.guess);
  }

  void emailVerification() {
    _controller.add(AuthenticationStatus.email_verification);
  }

  void phoneVerification() {
    _controller.add(AuthenticationStatus.phone_verification);
  }

  void userUpdate() {
    _controller.add(AuthenticationStatus.user_update);
  }

  void logOut() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void unAuthView() {
    _controller.add(AuthenticationStatus.unauthenticated);
  }

  void maintainanceMode() {
    _controller.add(AuthenticationStatus.maintainance_mode);
  }

  void quickAccessListing() {
    _controller.add(AuthenticationStatus.quick_access_listing);
  }

  void quickAccessUser() {
    _controller.add(AuthenticationStatus.quick_access_user);
  }

  void noConnection() {
    _controller.add(AuthenticationStatus.noConnection);
  }

  void forceUpdate() {
    _controller.add(AuthenticationStatus.force_update);
  }

  void authenticated() {
    _controller.add(AuthenticationStatus.authenticated);
  }

  void dispose() => _controller.close();
}
