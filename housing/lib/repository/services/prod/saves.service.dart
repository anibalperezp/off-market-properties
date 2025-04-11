import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/listing/response_get_all.dart';
import 'package:http/http.dart' as http;
import '../../../commons/main.constants.global.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../auth/auth.service.dart';
import '../api_response.service.dart';

class SavesService {
  UserRepository _userRepository = new UserRepository();

  Future<APIResponse<ResponseGetAll>> getFavorites() async {
    var url = Uri.https(baseUrl, FAVORITE_GET_ALL);
    final accessToken = await _userRepository.readKey('access_token');
    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        ResponseGetAll response = new ResponseGetAll(count: 0);
        final jsonData = json.decode(data.body);
        final items = jsonData['Items'];
        response.list =
            items.map((dynamic item) => Listing.fromJson(item)).toList();
        response.count = jsonData['count'] ?? 0;

        return APIResponse<ResponseGetAll>(
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
        return APIResponse<ResponseGetAll>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Favorites Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> addFavoriteLising(Listing listing) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, FAVORITE_ADD);
    Map<String, dynamic> args = {"sSearch": listing.sSearch};
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
        throw Exception('Add Favorite Listing Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> deleteFavoriteLising(Listing listing) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, FAVORITE_DELETE);
    Map<String, dynamic> args = {"sSearch": listing.sSearch};
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
        throw Exception('Delete Favorite Listing Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }
}
