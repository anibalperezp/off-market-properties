import 'package:equatable/equatable.dart';

class EmailVerificationEvent extends Equatable {
  const EmailVerificationEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class EmailVerificationSubmitted extends EmailVerificationEvent {
  const EmailVerificationSubmitted();
}
