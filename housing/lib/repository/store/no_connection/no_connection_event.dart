import 'package:equatable/equatable.dart';

class NoConnectionEvent extends Equatable {
  const NoConnectionEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class NoConnectionSubmitted extends NoConnectionEvent {
  const NoConnectionSubmitted();
}
