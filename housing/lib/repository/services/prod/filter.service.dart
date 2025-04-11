import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/models/filter/filter.model.dart';
import 'package:http/http.dart' as http;
import '../../../commons/main.constants.global.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../auth/auth.service.dart';
import '../api_response.service.dart';

class FilterService {
  UserRepository _userRepository = new UserRepository();

  Future<APIResponse<Tuple2<String, String>>> applyFilter(
      FilterModel filter,
      bool bIsMap,
      String sConcatenation,
      String sWestLng,
      String sSouthLat,
      String sEastLng,
      String sNorthLat,
      String sZoom) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, FILTER_APPLY);
    return http
        .post(url,
            body: json.encode({
              "nPriceMin": filter.nPriceMin.toString(),
              "nPriceMax": filter.nPriceMax.toString(),
              "nBedrooms": filter.nBedrooms,
              "nBedroomsMax": filter.nBedroomsMax.toString(),
              "nBathrooms": filter.nBathrooms,
              "nBathroomsMax": filter.nBathroomsMax.toString(),
              "nYearBuiltMin": filter.nYearBuiltMin.toString(),
              "nYearBuiltMax": filter.nYearBuiltMax.toString(),
              "nSqftMin": filter.nSqftMin.toString(),
              "nSqftMax": filter.nSqftMax.toString(),
              "nLotSizeMin": filter.nLotSizeMin.toString(),
              "nLotSizeMax": filter.nLotSizeMax.toString(),
              "nPricePerSqftMin": filter.nPricePerSqftMin.toString(),
              "nPricePerSqftMax": filter.nPricePerSqftMax.toString(),
              "sLystingStatus": filter.sLystingStatus,
              "sPropertyType": filter.sPropertyType,
              "sTypeOfSell": filter.sTypeOfSell,
              "sPropertyCondition": filter.sPropertyCondition,
              "nTotalPhotosMin": filter.nTotalPhotosMin.toString(),
              "nTotalPhotosMax": filter.nTotalPhotosMax.toString(),
              "bIsMap": bIsMap.toString(),
              "sConcatenation": sConcatenation,
              "sWestLng": sWestLng,
              "sSouthLat": sSouthLat,
              "sEastLng": sEastLng,
              "sNorthLat": sNorthLat,
              "sZoom": sZoom,
              "nDaysOnZipCularMin": filter.nDaysOnZipCularMin.toString(),
              "nDaysOnZipCularMax": filter.nDaysOnZipCularMax.toString(),
              "sTags": filter.sTags,
              "sLystingCategory": filter.sLystingCategory,
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final nTotalFilteredLystings =
            jsonData['nTotalFilteredLystings'].toString();
        final nCounterFilter = jsonData['countFilter'].toString();
        final tuple =
            Tuple2<String, String>(nTotalFilteredLystings, nCounterFilter);
        return APIResponse<Tuple2<String, String>>(
            data: tuple, requiredRefreshToken: false);
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
        return APIResponse<Tuple2<String, String>>(requiredRefreshToken: true);
      } else {
        throw Exception('Apply filter service failed');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<FilterModel>> getDefaultFilter() async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, FILTER_DEFAULT);
    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        FilterModel response = FilterModel.fromJson(jsonData['Item']);

        return APIResponse<FilterModel>(
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
        return APIResponse<FilterModel>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Default Filter service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }
}
