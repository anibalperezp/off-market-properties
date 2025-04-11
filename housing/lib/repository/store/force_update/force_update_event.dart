import 'package:equatable/equatable.dart';

class ForceUpdateEvent extends Equatable {
  const ForceUpdateEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class ForceUpdateSubmitted extends ForceUpdateEvent {
  const ForceUpdateSubmitted();
}
