import 'package:equatable/equatable.dart';

class ListingEvent extends Equatable {
  const ListingEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class ListingSubmitted extends ListingEvent {
  const ListingSubmitted();
}
