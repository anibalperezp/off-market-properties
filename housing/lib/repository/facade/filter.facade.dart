import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/filter/filter.model.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/filter.service.dart';

class FilterFacade extends BaseFacade {
  FilterService? _commonService;
  FilterFacade() {
    _commonService = new FilterService();
  }

  applyFilter(
      FilterModel filter,
      bool bIsMap,
      String sConcatenation,
      String sWestLng,
      String sSouthLat,
      String sEastLng,
      String sNorthLat,
      String sZoom) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _commonService!.applyFilter(filter, bIsMap,
        sConcatenation, sWestLng, sSouthLat, sEastLng, sNorthLat, sZoom);
    if (result.requiredRefreshToken) {
      result = await _commonService!.applyFilter(filter, bIsMap, sConcatenation,
          sWestLng, sSouthLat, sEastLng, sNorthLat, sZoom);
    }

    await FirebaseCrashlytics.instance.log('Error - Apply Filter - Service');

    return new ResponseService(
        data: result.data != null ? result.data : null,
        hasConnection: true,
        message: '',
        bSuccess: result.data != null);
  }

  getDefaultFilter() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    var result = await _commonService!.getDefaultFilter();
    if (result.requiredRefreshToken) {
      result = await _commonService!.getDefaultFilter();
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get Default Filter - Service');

    return new ResponseService(
        data: result.data != null ? result.data : null,
        hasConnection: true,
        message: '',
        bSuccess: result.data != null);
  }
}
