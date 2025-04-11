import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/auth_view/profile/profile_event.dart';
import 'package:zipcular/repository/store/auth_view/profile/profile_state.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const ProfileState()) {
    on<ProfileSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubmitted(
    ProfileSubmitted event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      _authenticationRepository.authenticated();
    } catch (_) {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    }
  }
}
