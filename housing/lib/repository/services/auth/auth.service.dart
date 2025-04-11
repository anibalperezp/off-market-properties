import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/repository/services/api_response.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import 'package:http/http.dart' as http;

Future<APIResponse<String>> registerCustomer(
    String email, String password, String phoneNumber, String referal) {
  var url = Uri.https(baseUrl, REGISTER);
  Map<String, dynamic> args = {
    "email": email,
    "password": password,
    "phone_number": phoneNumber,
    "sReferal": referal
  };
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      final status = body['sAUTH_Status'];
      UserRepository userRepository = new UserRepository();
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      return APIResponse<String>(data: status);
    } else {
      return APIResponse<String>(data: '');
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

Future<APIResponse<String>> signInWithCredentials({
  String? username,
  String? password,
}) async {
  UserRepository userRepository = new UserRepository();
  var url = Uri.https(baseUrl, LOGIN);
  final version = await getAppVersion();
  Map<String, dynamic> args = {
    "email": username,
    "password": password,
    "version": version
  };
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((response) async {
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final status = jsonData['sAUTH_Status'];
      final authResult = jsonData['Response'];
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      await userRepository.writeToken(
          'access_token', authResult['AccessToken']);
      await userRepository.writeToken('email', username!);
      await userRepository.writeToken('password', password!);

      return APIResponse<String>(data: status);
    } else if (response.statusCode == 202) {
      final jsonData = json.decode(response.body);
      String status = '';
      if (status != 'user_not_created') {
        status = jsonData['sAUTH_Status'];
        await userRepository.deleteToken('sAUTH_Status');
        await userRepository.writeToken('sAUTH_Status', status);
      } else {
        final _storage = FlutterSecureStorage();
        await _storage.deleteAll();
      }
      return APIResponse<String>(data: status, error: true);
    } else {
      return APIResponse<String>(data: '', error: true);
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

// VERIFY USER
// DEVICE - PHONE NUMBER
// *NO TOKEN*

Future<APIResponse<String>?> confirmUserOTP(
  String email,
  String confirmationNumber,
) async {
  UserRepository userRepository = new UserRepository();
  var url = Uri.https(baseUrl, CONFIRM_USER_OTP);
  Map<String, dynamic> args = {
    "email": email,
    "confirmationCode": confirmationNumber
  };
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      final status = body['sAUTH_Status'];
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      return APIResponse<String>(data: status);
    } else if (data.statusCode == 203) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      var status = body['sAUTH_Status'];
      if (status == AUTH_LOGIN) {
        await userRepository.deleteToken('sAUTH_Status');
        await userRepository.writeToken('sAUTH_Status', status);
      } else {
        status = '';
      }
      return APIResponse<String>(data: status);
    } else {
      return APIResponse<String>(data: '');
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

Future<APIResponse<String>?> resendUserOTP(String email) async {
  UserRepository userRepository = new UserRepository();
  var url = Uri.https(baseUrl, RESEND_USER_OTP);
  Map<String, dynamic> args = {"email": email};
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      final status = body['sAUTH_Status'];
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      return APIResponse<String>(data: status);
    } else if (data.statusCode == 203) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      var status = body['sAUTH_Status'];
      if (status == AUTH_LOGIN) {
        await userRepository.deleteToken('sAUTH_Status');
        await userRepository.writeToken('sAUTH_Status', status);
      } else {
        status = '';
      }
      return APIResponse<String>(data: status);
    } else {
      return APIResponse<String>(data: '');
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}
// *NO TOKEN*
// DEVICE - PHONE NUMBER - END

//EMAIL
Future<APIResponse<String>?> confirmEmailOTP(
  String confirmationNumber,
) async {
  UserRepository userRepository = new UserRepository();
  final accessToken = await userRepository.readKey('access_token');
  var url = Uri.https(baseUrl, CONFIRM_EMAIL_OTP);
  Map<String, dynamic> args = {"VerificationCode": confirmationNumber};
  return http
      .post(url,
          body: json.encode(args),
          headers: {
            "Content-Type": "application/json",
            "Authorization": accessToken,
          },
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      final status = body['sAUTH_Status'];
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      return APIResponse<String>(data: status);
    } else if (data.statusCode != 200) {
      return APIResponse<String>(data: '');
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

Future<APIResponse<String>?> resendEmailOTP() async {
  UserRepository userRepository = new UserRepository();
  String accessToken = await userRepository.readKey('access_token');

  var url = Uri.https(baseUrl, RESEND_EMAIL_OTP);
  return http
      .post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": accessToken
          },
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      final body = json.decode(utf8.decode(data.bodyBytes));
      final status = body['sAUTH_Status'];
      await userRepository.deleteToken('sAUTH_Status');
      await userRepository.writeToken('sAUTH_Status', status);
      return APIResponse<String>(data: status);
    } else if (data.statusCode != 200) {
      return APIResponse<String>(data: '');
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

//EMAIL END
//VERIFY USER

//FORGOT PASSWORD
Future<APIResponse<bool>?> forgotPassword(String email) {
  var url = Uri.https(baseUrl, FORGOT_PASS);
  Map<String, dynamic> args = {"email": email};
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      return APIResponse<bool>(data: true);
    } else if (data.statusCode != 200) {
      return APIResponse<bool>(data: false);
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

Future<APIResponse<bool>?> forgotPasswordConfirmation(
    String email, String validationCode, String password) {
  var url = Uri.https(baseUrl, FORGOT_PASS_CONFIRMATION);
  Map<String, dynamic> args = {
    "email": email,
    "password": password,
    "confirmationCode": validationCode
  };
  return http
      .post(url,
          body: json.encode(args),
          headers: {"Content-Type": "application/json"},
          encoding: Encoding.getByName("utf-8"))
      .then((data) async {
    if (data.statusCode == 200) {
      return APIResponse<bool>(data: true);
    } else if (data.statusCode != 200) {
      return APIResponse<bool>(data: false);
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}
//FORGOT PASSWORD

//Push Notification APN
Future<APIResponse<bool>> sendDeviceToken(
    {String? token, String? accessToken}) async {
  var url = Uri.https(baseUrl, GETAPNR);
  Map<String, dynamic> args = {
    "sAPNR": token,
  };
  return http
      .post(url,
          body: json.encode(args),
          headers: {
            "Content-Type": "application/json",
            "Authorization": accessToken!
          },
          encoding: Encoding.getByName("utf-8"))
      .then((response) async {
    if (response.statusCode == 200) {
      return APIResponse<bool>(data: true);
    } else {
      return APIResponse<bool>(data: false);
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}

getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // String appName = packageInfo.appName;
  // String packageName = packageInfo.packageName;
  // String buildNumber = packageInfo.buildNumber;
  //Test result
  String version = packageInfo.version;
  // String encryptedText = AdHelper.getCallBack(version);
  return version;
}

Future<APIResponse<bool>> deleteAccountService(List<String> reasons) async {
  var url = Uri.https(baseUrl, DELETE_ACCOUNT);
  Map<String, dynamic> args = {"sDeleteReasons": reasons};
  UserRepository _userRepository = new UserRepository();
  final accessToken = await _userRepository.readKey('access_token');
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
      return APIResponse<bool>(data: false, requiredRefreshToken: false);
    }
  }).catchError((_) {
    Future.delayed(Duration.zero, () async {
      await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
    });
  });
}
