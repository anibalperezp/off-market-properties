import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import '../../../services/auth/auth.service.dart';
import '../../../services/prod/user_repository.dart';
import '../../authentication_repository.dart';
import 'phone_verification_event.dart';
import 'phone_verification_state.dart';

class PhoneVerificationBloc
    extends Bloc<PhoneVerificationEvent, PhoneVerificationState> {
  PhoneVerificationBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const PhoneVerificationState()) {
    on<PhoneVerificationSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubmitted(
    PhoneVerificationSubmitted event,
    Emitter<PhoneVerificationState> emit,
  ) async {
    try {
      UserRepository userRepository = new UserRepository();
      String status = await userRepository.readKey('sAUTH_Status');
      if (status.isNotEmpty) {
        switch (status) {
          case AUTH_USER_INFO:
            _authenticationRepository.userUpdate();
            break;
          case AUTH_PHONE:
            _authenticationRepository.phoneVerification();
            break;
          case AUTH_EMAIL:
            String email = await userRepository.readKey('email');
            String password = await userRepository.readKey('password');

            final response = await signInWithCredentials(
                username: email, password: password);
            if (response.data != null) {
              _authenticationRepository.emailVerification();
            }
            break;
        }
      }
    } catch (_) {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    }
  }
}
