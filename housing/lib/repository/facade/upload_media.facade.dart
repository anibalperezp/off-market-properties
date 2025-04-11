import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/upload_media.service.dart';

class UploadMediaFacade extends BaseFacade {
  UploadMediaService? _uploadMediaService;

  UploadMediaFacade() {
    _uploadMediaService = UploadMediaService();
  }

  /// Listings Images
  presignPhotoListing(String value) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _uploadMediaService!.presignPhotoListing(value);
    if (result.requiredRefreshToken == true) {
      result = await _uploadMediaService!.presignPhotoListing(value);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Presign Photo Listing - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  /// Customer Profile Image
  presignPhotoProfile() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await _uploadMediaService!.presignPhotoProfile();
    if (result.requiredRefreshToken == true) {
      result = await _uploadMediaService!.presignPhotoProfile();
    }

    await FirebaseCrashlytics.instance
        .log('Error - Presign Photo Profile - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  // Customer Profile Image
  customerUpdatePhoto(String sProfilePicture) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result =
        await _uploadMediaService!.customerUpdatePhoto(sProfilePicture);
    if (result.requiredRefreshToken == true) {
      result = await _uploadMediaService!.customerUpdatePhoto(sProfilePicture);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Customer Update Photo - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }
}
