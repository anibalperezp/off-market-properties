import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/no_connection/no_connection_event.dart';
import '../authentication_repository.dart';
import 'no_connection_state.dart';

class NoConnectionBloc extends Bloc<NoConnectionEvent, NoConnectionState> {
  NoConnectionBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const NoConnectionState()) {
    on<NoConnectionSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  void _onSubmitted(
    NoConnectionSubmitted event,
    Emitter<NoConnectionState> emit,
  ) {
    try {
      _authenticationRepository.logOut();
    } catch (_) {}
  }
}
