import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/saves.service.dart';

class SavesFacade extends BaseFacade {
  SavesService? savesService;

  SavesFacade() {
    savesService = new SavesService();
  }

  getFavorites() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await savesService!.getFavorites();
    if (result.requiredRefreshToken == true) {
      result = await savesService!.getFavorites();
    }

    await FirebaseCrashlytics.instance.log('Error - Get Favorites - Service');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  addFavoriteLising(Listing listing) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await savesService!.addFavoriteLising(listing);
    if (result.requiredRefreshToken == true) {
      result = await savesService!.addFavoriteLising(listing);
    }

    await FirebaseCrashlytics.instance.log(
        'Error - Add Favorite Listing - Service. Listing: ${listing.sSearch}');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  deleteFavoriteLising(Listing listing) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await savesService!.deleteFavoriteLising(listing);
    if (result.requiredRefreshToken == true) {
      result = await savesService!.deleteFavoriteLising(listing);
    }

    await FirebaseCrashlytics.instance.log(
        'Error - Delete Favorite Listing - Service. Listing: ${listing.sSearch}');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }
}
