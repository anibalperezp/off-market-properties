import 'dart:convert';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../commons/main.constants.global.dart';
import 'package:http/http.dart' as http;
import '../../../models/notifications/notification.model.dart';
import '../auth/auth.service.dart';
import '../api_response.service.dart';

class CommonService {
  UserRepository _userRepository = new UserRepository();

  Future<APIResponse<bool>> postReview(int stars, String comment) async {
    var url = Uri.https(baseUrl, CUSTOMER_REVIEW);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {
      "nNumberOfStarts": stars.toString(),
      "sReview": comment
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
        throw Exception('Get Favorites Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(data: false);
    });
  }

  /// Notifications
  ///
  /// Get notifications
  ///
  Future<APIResponse<List<NotificationModel>>> getNotifications(
      int range) async {
    var url =
        Uri.https(baseUrl, CUSTOMER_NOTIFICATIONS, {"range": range.toString()});
    final accessToken = await _userRepository.readKey('access_token');

    return http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    }).then((data) async {
      if (data.statusCode == 200) {
        try {
          final jsonData = json.decode(data.body);
          final items = jsonData['Items'];
          final notifications = items
              .map((dynamic item) => NotificationModel.fromJson(item))
              .toList();
          return APIResponse<List<NotificationModel>>(
              data: notifications.cast<NotificationModel>(),
              requiredRefreshToken: false);
        } catch (e) {
          Future.delayed(Duration.zero, () async {
            await FirebaseCrashlytics.instance
                .recordError(e, StackTrace.current);
          });
          return APIResponse<List<NotificationModel>>(data: null);
        }
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
        return APIResponse<List<NotificationModel>>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Notifications Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      APIResponse<List<NotificationModel>>(data: null);
    });
  }

  /// Update Notifications
  Future<APIResponse<bool>> updateNotification(
      String sCategory, String uNotificationId) async {
    var url = Uri.https(baseUrl, CUSTOMER_NOTIFICATIONS_UPDATE);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {
      "sCategory": sCategory,
      "uNotificationId": uNotificationId
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
        throw Exception('Update Notifications Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(data: false);
    });
  }

  /// Pending View Notifications
  Future<APIResponse<int>> pendingViewNotification() async {
    var url = Uri.https(baseUrl, CUSTOMER_NOTIFICATIONS_PENDING_VIEW);
    final accessToken = await _userRepository.readKey('access_token');
    return http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    }).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        int nTotalNotification = jsonData['nTotalPending'] ?? 0;
        return APIResponse<int>(
            data: nTotalNotification, requiredRefreshToken: false);
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
        return APIResponse<int>(requiredRefreshToken: true);
      } else {
        throw Exception('Pending View Notifications Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<int>(data: null);
    });
  }
}
