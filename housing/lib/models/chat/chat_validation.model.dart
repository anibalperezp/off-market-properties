import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ChatValidation {
  String? Status, sHeader, sDescription;
  bool? bContinue;

  ChatValidation(
      {required this.Status,
      required this.sHeader,
      required this.sDescription,
      required this.bContinue});

  factory ChatValidation.fromJson(Map<String, dynamic> json) {
    var chatUser;
    try {
      chatUser = ChatValidation(
        Status: json['Status'] ?? '',
        sHeader: json['sHeader'] ?? '',
        sDescription: json['sDescription'] ?? '',
        bContinue: json['bContinue'] ?? '',
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return chatUser;
  }
}
