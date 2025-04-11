import 'package:flutter/widgets.dart';
import 'package:zipcular/commons/notification.global.dart';
import 'package:zipcular/repository/facade/common.facade.dart';

class NotificationsProvider extends ChangeNotifier {
  final List<dynamic> notifications = [];
  int notReadCounter = 0;

  Future<void> fetchNotificationsFromDatabase() async {
    this.notifications.clear();
    final result = await FacadeCommonService().getNotifications(1);
    if (result.bSuccess!) {
      if (result.data.length > 0) {
        for (final element in result.data) {
          this.notifications.add(element);
        }
        this.notifications.sort((a, b) => b.nSortDate!.compareTo(a.nSortDate!));
      }
    }
    await countPendingNotifications();
    notifyListeners();
  }

  countPendingNotifications() async {
    if (notifications.length > 0) {
      this.notReadCounter = notifications
          .where((element) => element.bIsSeenIt == false)
          .toList()
          .length;
    } else {
      this.notReadCounter = 0;
    }
    await notificationsGlobalCount(notReadCounter.toString());
    notifyListeners();
  }

  Future<void> updateNotificationAsRead(
      String sCategory, String uNotificationId) async {
    final result = await FacadeCommonService()
        .updateNotification(sCategory, uNotificationId);
    if (result.bSuccess!) {
      this
          .notifications
          .firstWhere((element) => element.uNotificationId == uNotificationId)
          .bIsSeenIt = true;
      if (this.notReadCounter > 0) {
        this.notReadCounter = this.notReadCounter - 1;
      }
      notifyListeners();
      await notificationsGlobalCount(notReadCounter.toString());
    }
  }
}
