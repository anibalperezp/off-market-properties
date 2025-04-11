import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/user/user.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/user.service.dart';

class UserFacade extends BaseFacade {
  UserService? _userRepoService;
  UserFacade() {
    _userRepoService = new UserService();
  }

  searchMarketArea(String query, String region) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.searchMarketArea(query, region);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.searchMarketArea(query, region);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - Search Market Area - Service. Query: $query');
    }

    ResponseService response = ResponseService(
        data: result.data != null ? result.data : [],
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  updateUser(User user, String email, String latitud, String longitud,
      String zipcode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!
        .updateUser(user, email, latitud, longitud, zipcode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!
          .updateUser(user, email, latitud, longitud, zipcode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - Update Customer - Service. Id: ${user.sFirstName}');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  saveReview() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.saveReview();

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.saveReview();
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance.log('Error - Save Review - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  getUserService() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.getUserService();

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.getUserService();
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - Get User Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  updateProfile(String sLanguageSpeak, String sBranchCode,
      List<String> sReferalAnswers) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!
        .updateProfile(sLanguageSpeak, sBranchCode, sReferalAnswers);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!
          .updateProfile(sLanguageSpeak, sBranchCode, sReferalAnswers);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance.log('Error - Update Profile');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  //x---------------------------------------------------------------x
  //User Network
  //x---------------------------------------------------------------x

  connections() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.connections();

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.connections();
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance.log('Error - Update Profile');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  newRequests() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.newRequests();

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.newRequests();
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance.log('Error - Update Profile');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  blocks() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.blocks();

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.blocks();
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance.log('Error - Update Profile');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  UserConnectionCancel(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserConnectionCancel(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserConnectionCancel(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - Get User Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  UserBlockConnection(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserBlockConnection(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserBlockConnection(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - User Block Connection Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  UserUnBlockConnection(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserUnBlockConnection(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserUnBlockConnection(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - User UnBlock Connection Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  // x---------------------------------------------------------------x
  // User REQUEST
  // x---------------------------------------------------------------x

  UserRequestSend(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserRequestSend(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserRequestSend(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - User Request Send Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  UserRequestCancel(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserRequestCancel(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserRequestCancel(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - User Request Cancel Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  UserRequestAccept(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _userRepoService!.UserRequestAccept(sInvitationCode);

    if (result.requiredRefreshToken == true) {
      result = await _userRepoService!.UserRequestAccept(sInvitationCode);
    }

    if (result.error == true) {
      await FirebaseCrashlytics.instance
          .log('Error - User Request Accept Service - Service');
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }
}
