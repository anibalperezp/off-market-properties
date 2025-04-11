import 'package:equatable/equatable.dart';

class MoreEvent extends Equatable {
  const MoreEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class MoreSubmitted extends MoreEvent {
  const MoreSubmitted();
}
