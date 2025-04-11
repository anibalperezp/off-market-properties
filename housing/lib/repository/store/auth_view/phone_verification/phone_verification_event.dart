import 'package:equatable/equatable.dart';

class PhoneVerificationEvent extends Equatable {
  const PhoneVerificationEvent();

  @override
  List<Object> get props => List.empty(growable: true);
}

class PhoneVerificationSubmitted extends PhoneVerificationEvent {
  const PhoneVerificationSubmitted();
}
