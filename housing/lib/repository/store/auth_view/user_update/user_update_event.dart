import 'package:equatable/equatable.dart';

class UserUpdateEvent extends Equatable {
  const UserUpdateEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class UserUpdateSubmitted extends UserUpdateEvent {
  const UserUpdateSubmitted();
}
