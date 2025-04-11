import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication_repository.dart';
import 'main_auth_event.dart';
import 'main_auth_state.dart';

class MainAuthBloc extends Bloc<MainAuthEvent, MainAuthState> {
  MainAuthBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const MainAuthState()) {
    on<MainAuthSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    MainAuthSubmitted event,
    Emitter<MainAuthState> emit,
  ) {
    try {
      _authenticationRepository.guess();
    } catch (_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    }
  }
}
