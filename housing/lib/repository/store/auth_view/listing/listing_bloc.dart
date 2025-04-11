import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zipcular/repository/store/auth_view/Listing/Listing_event.dart';
import 'package:zipcular/repository/store/auth_view/Listing/Listing_state.dart';
import 'package:zipcular/repository/store/authentication_repository.dart';

class ListingBloc extends Bloc<ListingEvent, ListingState> {
  ListingBloc({
    AuthenticationRepository? authenticationRepository,
  })  : _authenticationRepository = authenticationRepository!,
        super(const ListingState()) {
    on<ListingSubmitted>(_onSubmitted);
  }

  final AuthenticationRepository _authenticationRepository;

  Future<void> _onSubmitted(
    ListingSubmitted event,
    Emitter<ListingState> emit,
  ) async {
    try {
      _authenticationRepository.authenticated();
    } catch (_) {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    }
  }
}
