import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ChatMessageType { text, audio, image, video, file }

enum MessageStatus { not_sent, pn_sent, sms_sent, not_view, viewed }

class ChatMessage {
  final String message, sChatId, sMessageId;
  final ChatMessageType messageType;
  final MessageStatus messageStatus;
  final bool isSender;
  final int sLastMessageCreatedTime;

  ChatMessage({
    required this.sChatId,
    required this.sMessageId,
    required this.message,
    required this.messageType,
    required this.messageStatus,
    required this.isSender,
    required this.sLastMessageCreatedTime,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    var chatMessage;
    try {
      var messageType = ChatMessageType.text;
      switch (json['sChatMessageType'] ?? 'text') {
        case 'text':
          messageType = ChatMessageType.text;
        case 'audio':
          messageType = ChatMessageType.audio;
        case 'image':
          messageType = ChatMessageType.image;
        case 'video':
          messageType = ChatMessageType.video;
        case 'file':
          messageType = ChatMessageType.file;
      }

      var messageStatus = MessageStatus.not_sent;
      switch (json['sMessageStatus'] ?? 'not_sent') {
        case 'not_sent':
          messageStatus = MessageStatus.not_sent;
        case 'not_view':
          messageStatus = MessageStatus.not_view;
        case 'viewed':
          messageStatus = MessageStatus.viewed;
      }

      String menssageContent = json['sMessageContent'] ?? '';
      String decodeMessage = '';
      if (menssageContent.isNotEmpty) {
        List<int> bytes = menssageContent.codeUnits;
        decodeMessage = utf8.decode(bytes);
      }

      chatMessage = ChatMessage(
        sChatId: json['sChatId'] ?? '',
        sMessageId: json['sMessageId'] ?? '',
        sLastMessageCreatedTime: json['sMessageCreatedTime'] ?? 0,
        message: decodeMessage,
        messageType: messageType,
        messageStatus: messageStatus,
        isSender: json['bIsSender'] ?? false,
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return chatMessage;
  }
}
