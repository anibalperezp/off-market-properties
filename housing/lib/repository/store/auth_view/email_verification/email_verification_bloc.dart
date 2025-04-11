import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/prod/user_repository.dart';
import '../../authentication_repository.dart';
import 'email_verification_event.dart';
import 'email_verification_state.dart';

class EmailVerificationBloc
    extends Bloc<EmailVerificationEvent, EmailVerificationState> {
  EmailVerificationBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const EmailVerificationState()) {
    on<EmailVerificationSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubmitted(
    EmailVerificationSubmitted event,
    Emitter<EmailVerificationState> emit,
  ) async {
    try {
      UserRepository userRepository = new UserRepository();
      String status = await userRepository.readKey('sAUTH_Status');
      if (status.isNotEmpty) {
        switch (status) {
          case 'userinf_val':
            _authenticationRepository.userUpdate();
            break;
        }
      }
    } catch (_) {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    }
  }
}
