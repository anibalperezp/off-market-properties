import 'dart:convert' as convert;
import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class GoogleServs {
  final _baseUrl = 'maps.googleapis.com';
  final _baseAddAPI = '/maps/api/place/autocomplete/json';

  Future<List> autocompletedAddress(String location) async {
    var result;
    var url = Uri.https(_baseUrl, _baseAddAPI, {
      'input': location,
      'key': 'AIzaSyACkAM_SwyJuWRXzCRUibl93NQZM-vPBHI',
      'sessiontoken': '1234567890',
      'components': 'country:us'
    });
    try {
      var response = await http.get(url);
      var json = convert.jsonDecode(response.body);
      var jsonResults = json['predictions'] as List;
      result = jsonResults;
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return result;
  }

  getZipcodeByLocation(double alt, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(alt, lon);
    if (placemarks.length > 0) {
      return placemarks[0].postalCode;
    }
  }

  getZipcodeByKey(String placeId) async {
    String mapApiKey = 'AIzaSyACkAM_SwyJuWRXzCRUibl93NQZM-vPBHI';
    String _host = 'https://maps.googleapis.com/maps/api/place/details/json';
    final url =
        '$_host?place_id=$placeId&fields=address_component&key=$mapApiKey&language=en';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      int i = 3;
      while (validaZipcode(
              data["result"]['address_components'][i]['short_name']) ==
          false) {
        i++;
      }
      return data["result"]['address_components'][i]['short_name'];
    } else {
      return null;
    }
  }

  getRgion(latitude, longitude) async {
    var placemarks = await placemarkFromCoordinates(latitude, longitude);
    return placemarks;
  }

  validaZipcode(String zipcode) {
    bool result = false;
    try {
      if (zipcode.length == 5) {
        final element = int.parse(zipcode);
        result = element is int;
      }
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return result;
  }
}
