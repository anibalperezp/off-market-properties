import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/api_response.service.dart';

import '../../models/notifications/notification.model.dart';
import '../services/prod/common.service.dart';

class FacadeCommonService extends BaseFacade {
  CommonService? _commonService;
  FacadeCommonService() {
    _commonService = new CommonService();
  }

  /// ACCOUNT ------------------------------------------------------------------

  deleteAccount(List<String> reasons) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    APIResponse result = await deleteAccountService(reasons);
    if (result.requiredRefreshToken == true) {
      result = await deleteAccountService(reasons);
    }

    await FirebaseCrashlytics.instance.log('Error - Delete Account - Service');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  /// NOTIFICATIONS ------------------------------------------------------------

  getTotalNotifications() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: -1, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _commonService!.pendingViewNotification();
    if (result.requiredRefreshToken == true) {
      result = await _commonService!.pendingViewNotification();
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get Total Notifications - Service');

    ResponseService response = ResponseService(
        data: result.data != null ? result.data : 0,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  updateNotification(String sCategory, String uNotificationId) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result =
        await _commonService!.updateNotification(sCategory, uNotificationId);
    if (result.requiredRefreshToken) {
      result =
          await _commonService!.updateNotification(sCategory, uNotificationId);
    }
    await FirebaseCrashlytics.instance
        .log('Error - Update Notification - Service. Id: $uNotificationId');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  getNotifications(int range) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: List<NotificationModel>.empty(growable: true),
          hasConnection: false,
          message: '',
          bSuccess: false);
    }
    List<NotificationModel> notifications =
        List<NotificationModel>.empty(growable: true);
    var result = await _commonService!.getNotifications(range);
    if (result.requiredRefreshToken) {
      result = await _commonService!.getNotifications(range);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get Notifications - Service.');

    ResponseService response = ResponseService(
        data: result.data != null ? result.data : notifications,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');
    return response;
  }

  /// NOTIFICATIONS ------------------------------------------------------------
}
