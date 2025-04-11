import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/listing/response_add_resources.dart';
import 'package:http/http.dart' as http;
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../api_response.service.dart';

class UploadMediaService {
  UserRepository _userRepository = new UserRepository();

// Listings Images
  Future<APIResponse<ResponseAddResources>> presignPhotoListing(
      String urlObj) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, GET_PRESIGNED_URL);
    return http
        .post(url,
            body: json.encode(
                {"urlName": urlObj, "extention": 'webp', "action": "upload"}),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        final body = json.decode(utf8.decode(data.bodyBytes));
        final response = ResponseAddResources(
            queryParameters: body['queryParameters'], url: body['url']);
        return APIResponse<ResponseAddResources>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final authResponse =
            await signInWithCredentials(username: email, password: password);
        if (authResponse.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseAddResources>(requiredRefreshToken: true);
      } else {
        throw Exception('Update Resource Media service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<String> uploadImage(
      String urlBase, ResponseAddResources query, Uint8List data) async {
    Dio dio = new Dio();
    String url = urlBase + query.url + query.queryParameters;
    var response = await dio.put(
      url,
      data: Stream.fromIterable(data.map((e) => [e])), //data,
      options: Options(
        contentType: "image/webp",
        headers: {
          Headers.contentLengthHeader: data.length,
        },
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Upload Image service failed.');
    }
    return response.data;
  }

  // Customer Profile Image
  Future<APIResponse<ResponseAddResources>> presignPhotoProfile() async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, USER_PRESIGNED_PHOTO_PROFILE);
    return http
        .post(url,
            body: json.encode({
              "contentType": 'images/webp',
              "extention": 'webp',
              "action": "upload"
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        final body = json.decode(utf8.decode(data.bodyBytes));
        final response = ResponseAddResources(
            queryParameters: body['queryParameters'], url: body['url']);
        return APIResponse<ResponseAddResources>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final authResponse =
            await signInWithCredentials(username: email, password: password);
        if (authResponse.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseAddResources>(requiredRefreshToken: true);
      } else {
        throw Exception('Presign Photo Profile.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  Future<APIResponse<bool>> customerUpdatePhoto(String sProfilePicture) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, USER_UPDATE_PHOTO);
    return http
        .post(url,
            body: json.encode({"sProfilePicture": sProfilePicture}),
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
        final authResponse =
            await signInWithCredentials(username: email, password: password);
        if (authResponse.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Presign Photo Profile.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
    });
  }

  //Compress Image
  Future<Uint8List> compressList(Uint8List list) async {
    final result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 480,
      minWidth: 800,
      quality: 85,
      autoCorrectionAngle: true,
      format: CompressFormat.webp,
    );
    return result;
  }
}
