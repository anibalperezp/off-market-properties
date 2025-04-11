import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/chat.service.dart';

class FacadeChat extends BaseFacade {
  ChatService? _chatService;
  FacadeChat() {
    _chatService = new ChatService();
  }

  historyChat() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _chatService!.historyChat();
    if (result.requiredRefreshToken) {
      result = await _chatService!.historyChat();
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get History Chat - Service');

    return new ResponseService(
        data: result.data != null ? result.data : null,
        hasConnection: true,
        message: '',
        bSuccess: result.data != null);
  }

  messagesChat(String sInvitationCode, String sLystingId) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _chatService!.messagesChat(sInvitationCode, sLystingId);
    if (result.requiredRefreshToken) {
      result = await _chatService!.messagesChat(sInvitationCode, sLystingId);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get History Chat - Service');

    return new ResponseService(
        data: result.data != null ? result.data : null,
        hasConnection: true,
        message: '',
        bSuccess: result.data != null);
  }

  deleteChat(String sChatId) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _chatService!.deleteChat(sChatId);
    if (result.requiredRefreshToken) {
      result = await _chatService!.deleteChat(sChatId);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get History Chat - Service');

    return new ResponseService(
        data: result.data,
        hasConnection: true,
        message: '',
        bSuccess: result.data);
  }

  deleteMessageChat(String sMessageId) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _chatService!.deleteMessageChat(sMessageId);
    if (result.requiredRefreshToken) {
      result = await _chatService!.deleteMessageChat(sMessageId);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Delete Message from Chat - Service');

    return new ResponseService(
        data: result.data,
        hasConnection: true,
        message: '',
        bSuccess: result.data);
  }

  updateChat(String sChatId, bool bIsFavorite, bool bIsReported,
      String reportDescription) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _chatService!.updateChat(
      sChatId,
      bIsFavorite,
      bIsReported,
      reportDescription,
    );
    if (result.requiredRefreshToken) {
      result = await _chatService!
          .updateChat(sChatId, bIsFavorite, bIsReported, reportDescription);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Update Conversation Chat - Service');

    return new ResponseService(
        data: result.data,
        hasConnection: true,
        message: '',
        bSuccess: result.data);
  }

  sendEmail(String sBody, String sInvitationCode, String sSearch,
      String sEmail) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result =
        await _chatService!.sendEmail(sBody, sInvitationCode, sSearch, sEmail);
    if (result.requiredRefreshToken) {
      result = await _chatService!
          .sendEmail(sBody, sInvitationCode, sSearch, sEmail);
    }

    await FirebaseCrashlytics.instance.log('Error - Send Email - Service');

    return new ResponseService(
        data: result.data,
        hasConnection: true,
        message: '',
        bSuccess: result.data);
  }
}
