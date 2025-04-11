import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication_repository.dart';
import 'intro_event.dart';
import 'intro_state.dart';

class IntroBloc extends Bloc<IntroEvent, IntroState> {
  IntroBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const IntroState()) {
    on<IntroSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    IntroSubmitted event,
    Emitter<IntroState> emit,
  ) {
    try {
      _authenticationRepository.logOut();
    } catch (_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    }
  }
}
