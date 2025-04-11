import 'package:equatable/equatable.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';

class AuthenticationState extends Equatable {
  const AuthenticationState._({this.status = AuthenticationStatus.unknown});

  const AuthenticationState.unknown() : this._();

  const AuthenticationState.authenticated()
      : this._(status: AuthenticationStatus.authenticated);

  const AuthenticationState.unauthenticated()
      : this._(status: AuthenticationStatus.unauthenticated);

  const AuthenticationState.intro()
      : this._(status: AuthenticationStatus.intro);

  const AuthenticationState.guess()
      : this._(status: AuthenticationStatus.guess);

  const AuthenticationState.emailVerification()
      : this._(status: AuthenticationStatus.email_verification);

  const AuthenticationState.phoneVerification()
      : this._(status: AuthenticationStatus.phone_verification);

  const AuthenticationState.userUpdate()
      : this._(status: AuthenticationStatus.user_update);

  const AuthenticationState.quickAccessUser()
      : this._(status: AuthenticationStatus.quick_access_user);

  const AuthenticationState.quickAccessListing()
      : this._(status: AuthenticationStatus.quick_access_listing);

  const AuthenticationState.noConnection()
      : this._(status: AuthenticationStatus.noConnection);

  const AuthenticationState.forceUpdate()
      : this._(status: AuthenticationStatus.force_update);

  final AuthenticationStatus status;

  @override
  List<Object> get props => [status];
}
