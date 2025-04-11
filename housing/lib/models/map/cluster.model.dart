import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zipcular/models/map/manager/cluster_manager.dart';
import 'package:zipcular/models/map/manager/geohash.model.dart';

mixin ClusterItem {
  LatLng get location;

  String? _geohash;
  String get geohash => _geohash ??=
      Geohash.encode(location, codeLength: ClusterManager.precision);
}
