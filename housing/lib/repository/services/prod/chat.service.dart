import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/chat/chat.model.dart';
import 'package:zipcular/models/chat/chat_message.model.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../auth/auth.service.dart';
import '../api_response.service.dart';
import 'package:http/http.dart' as http;

class ChatService {
  UserRepository _userRepository = new UserRepository();

  Future<APIResponse<List<dynamic>>> historyChat() async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CHAT_HIST);
    return http
        .get(url, headers: {"Authorization": accessToken}).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final items = jsonData['chat'];
        var response = [];
        if (items != null) {
          response =
              items.map((dynamic item) => ChatUser.fromJson(item)).toList();
        }
        return APIResponse<List<dynamic>>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<List<dynamic>>(requiredRefreshToken: true);
      } else {
        throw Exception('History Chat service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<List<dynamic>>> messagesChat(
      String sInvitationCode, String sLystingId) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CHAT_MESSAGES,
        {'sInvitationCode': sInvitationCode, 'sLystingId': sLystingId});
    return http
        .get(url, headers: {"Authorization": accessToken}).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final items = jsonData['chat'];
        var response =
            items.map((dynamic item) => ChatMessage.fromJson(item)).toList();
        return APIResponse<List<dynamic>>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<List<dynamic>>(requiredRefreshToken: true);
      } else {
        throw Exception('Messages Chat service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> deleteChat(String sChatId) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, DELETE_CHAT, {"sChatId": sChatId});
    return http
        .delete(url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Delete  User Chat service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> deleteMessageChat(String sMessageId) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, DELETE_CHAT);
    Map<String, dynamic> args = {
      "sMessageId": sMessageId,
    };
    return http
        .delete(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Delete Message service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> updateChat(String sChatId, bool bIsFavorite,
      bool bIsReported, String reportDescription) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CHAT_UPDATE);
    Map<String, dynamic> args = {
      "sChatId": sChatId,
      "bIsFavorite": bIsFavorite.toString(),
      "sReport": reportDescription,
      "bIsReported": bIsReported.toString()
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Update Favorite Chat service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> sendEmail(String sBody, String sInvitationCode,
      String sSearch, String sEmail) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, GET_EMAIL);
    Map<String, dynamic> args = {
      "sBody": sBody,
      "sInvitationCode": sInvitationCode,
      "sSearch": sSearch
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        return APIResponse<bool>(data: true, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
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
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Update Favorite Chat service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }
}
