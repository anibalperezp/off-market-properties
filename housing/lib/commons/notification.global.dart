import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:zipcular/models/notifications/push_notification.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

showNotification(PushNotification? _notificationInfo) {
  if (_notificationInfo != null) {
    try {
      showSimpleNotification(
        Text(_notificationInfo.title),
        leading: Container(
          width: 50.0,
          height: 50.0,
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 45.3,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/ic_launcher.png',
                    height: 45,
                    width: 45,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        subtitle: Text(_notificationInfo.body),
        background: headerColor.withOpacity(0.5),
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      final mess = e;
    }
  }
}

notificationsGlobalCount(String counter) async {
  UserRepository _userRepository = UserRepository();
  if (counter.isEmpty) {
    counter = '0';
  }
  await _userRepository.writeToken('notifications_total', counter);

  final notificationsTotal = int.parse(counter);
  if (notificationsTotal > 0) {
    await FlutterAppBadger.updateBadgeCount(notificationsTotal);
  } else {
    await FlutterAppBadger.removeBadge();
  }
}

Future<void> firebaseMessagingBackground(RemoteMessage message) async {
  final mess = message;
  try {
    if (message != null) {
      getNotification(message);
      Future.delayed(Duration.zero, () async {
        UserRepository _userRepository = UserRepository();
        String counter = await _userRepository.readKey('notifications_total');
        final notificationsTotal = int.parse(counter) + 1;
        await notificationsGlobalCount(notificationsTotal.toString());
      });
      print("Handling a background message: ${message.messageId}");
    }
  } catch (e) {
    print(e);
  }
}

getNotification(RemoteMessage message) {
  PushNotification notification = PushNotification(
      title: message.data['pinpoint.notification.title'],
      body: message.data['pinpoint.notification.body'],
      dataTitle: message.data['pinpoint.notification.title'],
      dataBody: message.data['pinpoint.notification.body']);
  showNotification(notification);
}
