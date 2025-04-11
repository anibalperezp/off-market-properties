import 'package:equatable/equatable.dart';

class MainAuthEvent extends Equatable {
  const MainAuthEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class MainAuthSubmitted extends MainAuthEvent {
  const MainAuthSubmitted();
}
