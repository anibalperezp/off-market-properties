import 'dart:convert';
import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:zipcular/models/chat/chat_message.model.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/chat.facade.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class ChatProvider extends ChangeNotifier {
  String chatId = '';
  UserRepository userRepository = new UserRepository();
  final List<ChatUser> conversations = [];
  final List<ChatUser> conversationsCache = [];
  final List<ChatMessage> messages = [];
  late WebSocketChannel channel;
  late Timer _refreshTimer;
  int notReadCounter = 0;
  bool isConnected = false;
  UserRepository _userRepository = UserRepository();

  /// Web Socket connection START
  /// https://pub.dev/packages/web_socket_channel
  Future<void> initWebSocketConnection() async {
    try {
      await connectToWebSocket();
      startRefreshTimer();
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  connectToWebSocket() async {
    String accessToken = await userRepository.readKey('access_token');
    try {
      channel = WebSocketChannel.connect(
        Uri.parse(
            'wss://4otmyyau13.execute-api.us-east-2.amazonaws.com/prod?authorization=' +
                accessToken),
      );
    } catch (e) {
      var email = await _userRepository.readKey('email');
      var password = await _userRepository.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      FirebaseCrashlytics.instance.log(
          "WebsocketChannel was unable to establish connection" + e.toString());
    }
    if (isConnected == false) {
      isConnected = true;
      notifyListeners();
      listenForIncomingMessages();
    }
  }

  Future<void> startRefreshTimer() async {
    const refreshInterval = Duration(minutes: 5); // Adjust as needed
    try {
      _refreshTimer = Timer.periodic(refreshInterval, (_) async {
        if (channel != null) {
          channel.sink.close();
        }
        await connectToWebSocket();
        startRefreshTimer();
      });
    } catch (e) {
      var email = await _userRepository.readKey('email');
      var password = await _userRepository.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
    }
  }

  void closeWebSocketConnection() {
    if (channel != null) {
      channel.sink.close();
      _refreshTimer.cancel();
    }
  }

  void listenForIncomingMessages() {
    try {
      channel.ready.then((_) {
        channel.stream.listen((event) {
          print('Event from Stream: $event');
          final jsonMessage = json.decode(event);
          if (this.chatId.isNotEmpty && jsonMessage['sChatId'] == this.chatId) {
            saveMessage(
                jsonMessage['sChatId'], jsonMessage['sMessageContent'], false);
            saveIncomingConversation(jsonMessage, 'viewed');
          } else {
            saveIncomingConversation(jsonMessage, 'not_view');
          }
        }, onError: (e) {
          print('Error from Stream: $e');
          // handle stream error
        }, cancelOnError: true);
      }).onError((error, stackTrace) {
        FirebaseCrashlytics.instance.log(
            "WebsocketChannel was unable to establish connection" +
                error.toString() +
                stackTrace.toString());
      });
    } catch (e) {
      final error = e.toString();
    }
  }

  /// Web Socket connection END
  /// https://pub.dev/packages/web_socket_channel
  /// Services and Utilities
  Future<void> sendMessage(
      String jsonMessage, String sMessageContent, ChatUser chat) async {
    print(chat.sChatId);
    if (channel != null && channel!.sink != null) {
      try {
        channel.sink.add(jsonMessage);
        // Save message
        saveMessage(chat.sChatId!, sMessageContent, true);
        // Save conversation
        chat.sLastMessageContent = sMessageContent;
        if (chat.sChatId!.isNotEmpty) {
          saveOutgoingConversation(chat);
        }
      } catch (e) {
        FirebaseCrashlytics.instance.log('Error sending message: $e');
      }
    }
  }

  /// Access Database Services
  ///
  Future<void> fetchConversationsFromDatabase() async {
    try {
      final fetchedConversations = await getChatHistory();
      conversations.clear();
      conversations.addAll(fetchedConversations);
      conversationsCache.clear();
      conversationsCache.addAll(fetchedConversations);

      notifyListeners();
    } catch (e) {
      print('Error fetching conversations: $e');
    }
  }

  Future<void> fetchMensagesFromDatabase(
      String sUserInvitationCode, String sLystingId) async {
    try {
      messages.clear();
      final fetchedMessages =
          await getMessagesChat(sUserInvitationCode, sLystingId);
      if (fetchedMessages.length > 0) {
        messages.addAll(fetchedMessages);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  updateChatId(String chatId) {
    this.chatId = chatId;

    viewConversation(chatId);
    notifyListeners();
  }

  Future<void> deleteConversation(String sChatId) async {
    await FacadeChat().deleteChat(sChatId);
    ChatUser found = conversations
        .firstWhere((conversation) => conversation.sChatId == sChatId);
    bool deleted = conversations.remove(found);
    notifyListeners();
    if (deleted) {
      updateCounter();
    }
  }

  Future<bool> updateConversation(
    String sChatId,
    bool isFavorite,
    bool bIsReported,
    bool bIsReportedByMe,
    String reportDescription,
  ) async {
    int index = conversations
        .indexWhere((conversation) => conversation.sChatId == sChatId);

    ChatUser conversation = conversations
        .firstWhere((conversation) => conversation.sChatId == sChatId);
    conversation.bIsFavorite = isFavorite;
    conversation.bIsReported = bIsReported;
    conversation.bIsReportedByMe = bIsReportedByMe;
    conversations[index] = conversation;

    await FacadeChat()
        .updateChat(sChatId, isFavorite, bIsReported, reportDescription);
    updateCounter();
    notifyListeners();

    return true;
  }

  filterConv(String selectedFilters) {
    conversations.clear();
    if (selectedFilters.contains('All')) {
      conversations.addAll(conversationsCache);
    } else {
      if (selectedFilters.contains('Marketplace')) {
        final list = conversationsCache
            .where((element) => element.sMessageCategory == 'listing')
            .toList();
        conversations.addAll(list);
      }
      if (selectedFilters.contains('Connections')) {
        final list = conversationsCache
            .where((element) => element.sMessageCategory == 'networking')
            .toList();
        conversations.addAll(list);
      }
    }
    notifyListeners();
  }

  sortConv(String selectedSort) {
    conversations.clear();
    if (selectedSort.contains('All')) {
      conversations.addAll(conversationsCache);
    } else if (selectedSort.contains('Unread')) {
      final list = conversationsCache
          .where((element) => element.sMessageStatus == 'not_view')
          .toList();
      conversations.addAll(list);
    }
    if (selectedSort.contains('Favorites')) {
      final list = conversationsCache
          .where((element) => element.bIsFavorite == true)
          .toList();
      conversations.addAll(list);
    }
    notifyListeners();
  }

  /// Facade Services
  ///
  getChatHistory() async {
    ResponseService response = await FacadeChat().historyChat();
    return response.data.cast<ChatUser>();
  }

  getMessagesChat(String sUserInvitationCode, String sLystingId) async {
    ResponseService response =
        await FacadeChat().messagesChat(sUserInvitationCode, sLystingId);
    if (response.bSuccess == true)
      return response.data.length > 0 ? response.data.cast<ChatMessage>() : [];
  }

  /// Utils
  ///
  saveMessage(String sChatId, String messageObj, bool isSender) {
    ChatMessage message = new ChatMessage(
        sMessageId: '',
        message: messageObj,
        messageType: ChatMessageType.text,
        isSender: isSender,
        messageStatus: MessageStatus.viewed,
        sChatId: sChatId,
        sLastMessageCreatedTime: DateTime.now().millisecondsSinceEpoch);
    messages.insert(0, message);
    notifyListeners();
  }

  saveIncomingConversation(dynamic json, String sMessageStatus) {
    if (conversations.any((element) => element.sChatId == json['sChatId'])) {
      conversations
          .removeWhere((element) => element.sChatId == json['sChatId']);
    }
    ChatUser conversation = new ChatUser(
      sChatId: json['sChatId'] ?? '',
      sLastMessageContent: json['sMessageContent'] ?? '',
      sUserProfilePicture: json['sUserProfilePicture'] ?? '',
      sLastMessageCreatedTime: DateTime.now().millisecondsSinceEpoch,
      sUserInvitationCode: json['sUserInvitationCode'] ?? '',
      sLystingId: json['sLystingId'] ?? '',
      sLystingProfilePicture: json['sLystingProfilePicture'] ?? '',
      sLystingName: json['sLystingName'] ?? '',
      sChatMessageType: json['sChatMessageType'] ?? '',
      sMessageCategory: json['sMessageCategory'],
      sMessageStatus: sMessageStatus ?? 'not_view',
      bIsSender: json['bIsSender'] ?? false,
      bIsFavorite: json['bIsFavorite'] ?? false,
      bIsReported: json['bIsReported'] ?? false,
      bIsReportedByMe: json['bIsReportedByMe'] ?? false,
      sMessageSubCategory: json['sMessageSubCategory'] ?? '',
    );
    conversations.insert(0, conversation);
    updateCounter();
    notifyListeners();
  }

  saveOutgoingConversation(ChatUser chat) {
    if (conversations.any((element) => element.sChatId == chat.sChatId)) {
      conversations.removeWhere((element) => element.sChatId == chat.sChatId);
    }
    ChatUser conversation = new ChatUser(
        sChatId: chat.sChatId,
        sLastMessageContent: chat.sLastMessageContent,
        sUserProfilePicture: chat.sUserProfilePicture,
        sLastMessageCreatedTime: DateTime.now().millisecondsSinceEpoch,
        sUserInvitationCode: chat.sUserInvitationCode,
        sLystingId: chat.sLystingId,
        sLystingProfilePicture: chat.sLystingProfilePicture,
        sLystingName: chat.sLystingName,
        sChatMessageType: 'text',
        sMessageCategory: chat.sMessageCategory,
        sMessageSubCategory: chat.sMessageSubCategory,
        sMessageStatus: 'viewed',
        bIsSender: true,
        bIsFavorite: chat.bIsFavorite,
        bIsReported: chat.bIsReported,
        bIsReportedByMe: chat.bIsReportedByMe);
    conversations.insert(0, conversation);

    notifyListeners();
  }

  updateCounter() {
    final result = conversations
        .where((element) => element.sMessageStatus == 'not_view')
        .length;
    this.notReadCounter = result;
    notifyListeners();
  }

  viewConversation(String sChatId) {
    if (sChatId.isNotEmpty) {
      int index = conversations
          .indexWhere((conversation) => conversation.sChatId == sChatId);
      ChatUser conversation = conversations
          .firstWhere((conversation) => conversation.sChatId == sChatId);
      if (conversation != null) {
        conversation.sMessageStatus = 'viewed';
        conversations[index] = conversation;
        updateCounter();
      }
    }
  }
}
