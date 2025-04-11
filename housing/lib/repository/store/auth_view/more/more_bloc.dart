import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../authentication_repository.dart';
import 'more_event.dart';
import 'more_state.dart';

class MoreBloc extends Bloc<MoreEvent, MoreState> {
  MoreBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const MoreState()) {
    on<MoreSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    MoreSubmitted event,
    Emitter<MoreState> emit,
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
