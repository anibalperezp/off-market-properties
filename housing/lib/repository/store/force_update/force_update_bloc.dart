import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/force_update/force_update_event.dart';
import '../authentication_repository.dart';
import 'force_update_state.dart';

class ForceUpdateBloc extends Bloc<ForceUpdateEvent, ForceUpdateState> {
  ForceUpdateBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const ForceUpdateState()) {
    on<ForceUpdateSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    ForceUpdateSubmitted event,
    Emitter<ForceUpdateState> emit,
  ) {
    try {
      _authenticationRepository.logOut();
    } catch (_) {}
  }
}
