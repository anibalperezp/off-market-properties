import 'package:equatable/equatable.dart';

class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class ProfileSubmitted extends ProfileEvent {
  const ProfileSubmitted();
}
