import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:zipcular/repository/services/prod/google.service.dart';
import 'package:timeago/timeago.dart' as timeago;

/// LOCALIZATION
///
forceGetCurrentLocation() async {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissions;
  var locationData;
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }
  _permissions = await location.hasPermission();
  while (_permissions == PermissionStatus.denied) {
    _permissions = await location.requestPermission();
  }
  if (_permissions == PermissionStatus.granted) {
    locationData = await location.getLocation();
    return locationData;
  }
}

getCurrentLocation() async {
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  var locationData;
  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }
  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }
  locationData = await location.getLocation();
  return locationData;
}

requestLocation(bool enable) async {
  if (enable) {
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return true;
      }
    }
  }
  return false;
}

isEnableLocation() async {
  Location location = new Location();
  bool _serviceEnabled = await location.serviceEnabled();
  return _serviceEnabled;
}

regionData() async {
  final pin = await getCurrentLocation();
  GoogleServs core = GoogleServs();
  if (pin != null) {
    final result = await core.getRgion(pin.latitude, pin.longitude);
    return result;
  }
  return null;
}

/// LOCALIZATION

/// TIME
/// Get time by location
///
getTimeByLocation(int timeSpam) {
  String fromNow = '';
  DateTime mTime = DateTime.fromMicrosecondsSinceEpoch(timeSpam * 1000);
  final now = new DateTime.now();
  final difference = now.difference(mTime);
  if (difference.inDays > 30) {
    final f = new DateFormat('MM/dd/yy');
    fromNow = f.format(mTime);
  } else if (difference.inDays > 0) {
    fromNow = timeago.format(now.subtract(Duration(
      days: difference.inDays,
    )));
  } else if (difference.inHours > 0) {
    final f = new DateFormat('hh:mm a');
    fromNow = f.format(mTime);
  } else if (difference.inMinutes > 0) {
    final f = new DateFormat('hh:mm a');
    fromNow = f.format(mTime);
  } else if (difference.inSeconds > 0) {
    fromNow =
        timeago.format(now.subtract(Duration(seconds: difference.inSeconds)));
  }
  return fromNow;
}
