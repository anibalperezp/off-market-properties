import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zipcular/models/map/cluster.model.dart';

class Place with ClusterItem {
  final String? name;
  final LatLng? latLng;

  Place({this.name, this.latLng});

  @override
  LatLng get location => latLng!;
}
