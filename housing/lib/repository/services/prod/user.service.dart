import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:tuple/tuple.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/models/user/user.dart';
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/api_response.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../models/listing/search/place.dart';

class UserService {
  UserRepository _userRepoService = new UserRepository();

  Future<APIResponse<Tuple2<User, int>>> getUserService() async {
    var url = Uri.https(baseUrl, USER_GET);
    final accessToken = await _userRepoService.readKey('access_token');
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });

    User user;
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      user = User.fromJson(jsonData);
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<Tuple2<User, int>>(
          requiredRefreshToken: true, data: null);
    } else {
      return APIResponse<Tuple2<User, int>>(error: true, data: null);
    }
    return APIResponse(
        data: Tuple2(user, response.statusCode), requiredRefreshToken: false);
  }

  Future<APIResponse<bool>> updateUser(User user, String email, String latitud,
      String longitud, String zipcode) async {
    var url = Uri.https(baseUrl, USER_UPDATE);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {
      "sCustomerType": user.sCustomerType,
      "sMarketArea": user.sMarketArea,
      "sFirstName": user.sFirstName,
      "sLastName": user.sLastName,
      "sMarketAreaToShow": user.sMarketAreaToShow,
      "sLatitud": latitud,
      "sLongitud": longitud,
      "sZipCode": zipcode
    };
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update User service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<List<Place>>> searchMarketArea(
      String query, String region) async {
    var url = Uri.https(baseUrl, USER_SEARCH_MARKET, {
      "searchby": query,
      "state": region,
    });
    final accessToken = await _userRepoService.readKey('access_token');
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });
    List<Place> _suggestions = List.empty(growable: true);
    if (response.statusCode == 200) {
      final body = json.decode(utf8.decode(response.bodyBytes));
      final features = body['Items'] as List;
      _suggestions = features.map((e) => Place.fromJson(e)).toSet().toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<List<Place>>(requiredRefreshToken: true);
    } else {
      throw Exception('Search Market Area service failed.');
    }
    return APIResponse<List<Place>>(
        data: _suggestions, requiredRefreshToken: false);
  }

  //Customer Profile
  Future<APIResponse<bool>> updateProfile(String sLanguageSpeak,
      String sBranchCode, List<String> sReferalAnswers) async {
    var url = Uri.https(baseUrl, USER_CUSTOMER_PROFILE);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {
      "sLanguageSpeak": sLanguageSpeak,
      "sBranchCode": sBranchCode,
      "sReferralAnswers": sReferalAnswers
    };
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  //x---------------------------------------------------------------x
  //User Network
  //x---------------------------------------------------------------x
  Future<APIResponse<List>> connections() async {
    final url = Uri.https(baseUrl, USER_CONNECTIONS);
    final accessToken = await _userRepoService.readKey('access_token');
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });
    List list = List.empty(growable: true);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      list = body
          .map((dynamic item) => CustomerModel.fromNetworkJson(item))
          .toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<List>(requiredRefreshToken: true);
    } else {
      throw Exception('User Connections service failed.');
    }
    return APIResponse<List>(data: list, requiredRefreshToken: false);
  }

  Future<APIResponse<List>> newRequests() async {
    final url = Uri.https(baseUrl, USER_NEW_REQUESTS);
    final accessToken = await _userRepoService.readKey('access_token');
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });
    List list = List.empty(growable: true);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      list = body
          .map((dynamic item) => CustomerModel.fromNetworkJson(item))
          .toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<List>(requiredRefreshToken: true);
    } else {
      throw Exception('User Connections service failed.');
    }
    return APIResponse<List>(data: list, requiredRefreshToken: false);
  }

  Future<APIResponse<List>> blocks() async {
    final url = Uri.https(baseUrl, USER_BLOCKS);
    final accessToken = await _userRepoService.readKey('access_token');
    final response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });
    List list = List.empty(growable: true);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      list = body
          .map((dynamic item) => CustomerModel.fromNetworkJson(item))
          .toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<List>(requiredRefreshToken: true);
    } else {
      throw Exception('User Connections service failed.');
    }
    return APIResponse<List>(data: list, requiredRefreshToken: false);
  }

  Future<APIResponse<bool>> saveReview() async {
    var url = Uri.https(baseUrl, USER_SAVE_REVIEW);
    final accessToken = await _userRepoService.readKey('access_token');
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": accessToken
    });

    bool result = false;
    if (response.statusCode == 200) {
      result = true;
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      var email = await _userRepoService.readKey('email');
      var password = await _userRepoService.readKey('password');
      final response =
          await signInWithCredentials(username: email, password: password);
      if (response.error == true) {
        // Logout
        FirebaseCrashlytics.instance.recordError(
            'Sign In With Credentials service error: email $email',
            StackTrace.current);
      }
      return APIResponse<bool>(requiredRefreshToken: result, data: null);
    } else {
      return APIResponse<bool>(error: true, data: false);
    }
    return APIResponse(data: result, requiredRefreshToken: false);
  }

  //-*-*-*/-*/-*/-*/-*/-*-*-**--**-*-*-*-*-*-*-*-*-*-*--*

  Future<APIResponse<bool>> UserConnectionCancel(String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_CONNECTION_CANCEL);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> UserBlockConnection(String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_CONNECTION_BLOCK);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> UserUnBlockConnection(
      String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_CONNECTION_UNBLOCK);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }
  //x---------------------------------------------------------------x
  //User Network
  //x---------------------------------------------------------------x

  // x---------------------------------------------------------------x
  // User REQUEST
  // x---------------------------------------------------------------x

  Future<APIResponse<bool>> UserRequestSend(String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_REQUEST_SEND);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> UserRequestCancel(String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_REQUEST_CANCEL);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> UserRequestAccept(String sInvitationCode) async {
    var url = Uri.https(baseUrl, USER_REQUEST_ACCEPT);
    final accessToken = await _userRepoService.readKey('access_token');
    Map<String, dynamic> args = {"sInvitationCode": sInvitationCode};
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
        var email = await _userRepoService.readKey('email');
        var password = await _userRepoService.readKey('password');
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
        throw Exception('Update Profile service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }
  // x---------------------------------------------------------------x
  // User REQUEST
  // x---------------------------------------------------------------x
}
