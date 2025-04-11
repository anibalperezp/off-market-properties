import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../authentication_repository.dart';
import 'user_update_event.dart';
import 'user_update_state.dart';

class UserUpdateBloc extends Bloc<UserUpdateEvent, UserUpdateState> {
  UserUpdateBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const UserUpdateState()) {
    on<UserUpdateSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubmitted(
    UserUpdateSubmitted event,
    Emitter<UserUpdateState> emit,
  ) async {
    try {
      UserRepository userRepository = new UserRepository();
      final email = await userRepository.readKey('email');
      final password = await userRepository.readKey('password');
      final accessToken = await userRepository.readKey('access_token');
      if (accessToken.length > 0) {
        await _authenticationRepository.logIn(
          username: email,
          password: password,
        );
      }
    } catch (_) {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    }
  }
}
