import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class ChatUser {
  String? sChatId,
      sUserProfilePicture,
      sUserInvitationCode,
      sLastMessageContent,
      sLystingId,
      sLystingProfilePicture,
      sLystingName, // Address to Show
      sMessageCategory,
      sChatMessageType,
      sMessageStatus,
      sMessageSubCategory;
  bool bIsSender, bIsFavorite, bIsReported, bIsReportedByMe;
  int sLastMessageCreatedTime;

  ChatUser(
      {required this.sChatId,
      required this.sUserProfilePicture,
      required this.sLastMessageCreatedTime,
      required this.sUserInvitationCode,
      required this.sLastMessageContent,
      required this.sLystingId,
      required this.sLystingProfilePicture,
      required this.sLystingName,
      required this.sMessageCategory,
      required this.sMessageSubCategory,
      required this.sChatMessageType,
      required this.sMessageStatus,
      required this.bIsSender,
      required this.bIsFavorite,
      required this.bIsReported,
      required this.bIsReportedByMe});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    var chatUser;
    try {
      String menssageContent = json['sLastMessageContent'] ?? '';
      String decodeMessage = '';
      if (menssageContent.isNotEmpty) {
        List<int> bytes = menssageContent.codeUnits;
        decodeMessage = utf8.decode(bytes);
      }

      chatUser = ChatUser(
          sChatId: json['sChatId'] ?? '',
          sUserProfilePicture: json['sUserProfilePicture'] ?? '',
          sLastMessageCreatedTime: json['sLastMessageCreatedTime'] ?? 0,
          sUserInvitationCode: json['sUserInvitationCode'] ?? '',
          sLastMessageContent: decodeMessage,
          sLystingId: json['sLystingId'] ?? '',
          sLystingProfilePicture: json['sLystingProfilePicture'] ?? '',
          sLystingName: json['sLystingName'] ?? '',
          sMessageCategory: json['sMessageCategory'] ?? '',
          sChatMessageType: json['sChatMessageType'] ?? '',
          sMessageSubCategory: json['sMessageSubCategory'] ?? '',
          sMessageStatus: json['sMessageStatus'] ?? '',
          bIsSender: json['bIsSender'] ?? false,
          bIsFavorite: json['bIsFavorite'] ?? false,
          bIsReported: json['bIsReported'] ?? false,
          bIsReportedByMe: json['bIsReportedByMe'] ?? false);
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return chatUser;
  }
}
