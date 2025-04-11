import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PinInformation {
  String? pinPath;
  String? avatarPath;
  LatLng? location;
  String? locationName;
  Color? labelColor;
  String? year;
  String? size;
  String? propertyCondition;
  String? isInMLS;
  String? beenSold;
  ValueChanged<int>? callback;

  PinInformation(
      {this.pinPath,
      this.avatarPath,
      this.location,
      this.locationName,
      this.labelColor,
      this.year,
      this.size,
      this.propertyCondition,
      this.isInMLS,
      this.beenSold,
      this.callback});
}
