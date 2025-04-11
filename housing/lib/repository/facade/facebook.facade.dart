import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/media/facebook.service.dart';

class FacadeFacebookService extends BaseFacade {
  FacebookService? _facebookService;
  FacadeFacebookService() {
    _facebookService = new FacebookService();
  }

  /// AUTH ------------------------------------------------------------------

  loginFacebook() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _facebookService!.loginFacebook();
    ResponseService response = ResponseService(
        data: result,
        hasConnection: true,
        bSuccess: result != null,
        message: '');

    return response;
  }

  /// GROUPS ------------------------------------------------------------
  /// Get user groups
  getUserGroups(String token) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _facebookService!.getUserGroups(token);
    await FirebaseCrashlytics.instance.log('Error -Get User Gropus - Service');

    ResponseService response = ResponseService(
        data: result,
        hasConnection: true,
        bSuccess: result.length > 0,
        message: '');

    return response;
  }

  postInGroup(String token, String groupId, String message, String link,
      String image) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _facebookService!
        .postToFacebookGroup(token, groupId, message, link, image);
    await FirebaseCrashlytics.instance
        .log('Error - Post Facebook In Group - Service');

    ResponseService response = ResponseService(
        data: result, hasConnection: true, bSuccess: result, message: '');

    return response;
  }

  /// GROUPS ------------------------------------------------------------
}
