import 'package:equatable/equatable.dart';

class IntroEvent extends Equatable {
  const IntroEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class IntroSubmitted extends IntroEvent {
  const IntroSubmitted();
}
