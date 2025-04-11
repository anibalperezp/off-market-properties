import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../../../commons/main.constants.global.dart';
import 'package:zipcular/models/listing/search/place.dart';
import 'package:http/http.dart' as http;
import 'package:zipcular/repository/services/auth/auth.service.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

import '../../../commons/common.localization.dart';

class Search extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Place> _suggestions = history;
  List<Place> get suggestions => _suggestions;

  String _query = '';
  String get query => _query;

  void onQueryChanged(String query) async {
    UserRepository _userRepository = new UserRepository();
    String accessToken = await _userRepository.readKey('access_token');
    if (query == _query) return;
    _query = query;
    _isLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _suggestions = history;
    } else if (query.length > 0) {
      final region = await regionData();

      var url = Uri.https(baseUrl, SEARCH_LISTINGS, {
        "searchby": query,
        "state": region != null ? region[0].administrativeArea : 'Texas',
      });
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      });
      if (response.statusCode == 401 || response.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final authResponse =
            await signInWithCredentials(username: email, password: password);
        if (authResponse.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        } else {
          accessToken = await _userRepository.readKey('access_token');
          url = Uri.https(baseUrl, SEARCH_LISTINGS, {
            "searchby": query,
            "state": region[0].administrativeArea,
          });
          response = await http.get(url, headers: {
            "Content-Type": "application/json",
            "Authorization": accessToken
          });
        }
      } else if (response.statusCode == 200) {
        final body = json.decode(utf8.decode(response.bodyBytes));
        final features = body['Items'] as List;
        _suggestions = features.map((e) => Place.fromJson(e)).toSet().toList();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _suggestions = history;
    notifyListeners();
  }
}

List<Place> history = List.empty(growable: true);
