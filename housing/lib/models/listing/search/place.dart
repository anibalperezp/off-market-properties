import 'package:flutter/material.dart';

class Place {
  final String? sConcatenationContent;
  final String? sCustomerView;
  final String? sCustomerViewLevel2;
  final String? sSearchType;
  final double? nZoomLevel;
  final double? latitude;
  final double? longitude;
  const Place({
    @required this.sConcatenationContent,
    this.sCustomerView,
    this.sCustomerViewLevel2,
    this.latitude,
    this.sSearchType,
    this.longitude,
    this.nZoomLevel,
  })  : assert(sConcatenationContent != null),
        assert(nZoomLevel != null);

  factory Place.fromJson(Map<String, dynamic> map) {
    return Place(
        sConcatenationContent: map['sConcatenation'] ?? '',
        sCustomerView: map['sCustomerView'] ?? '',
        sCustomerViewLevel2: map['sCustomerViewLevel2'],
        nZoomLevel: double.tryParse(map['nZoomLevel'].toString()) ?? 6.0,
        latitude: double.tryParse(map['sApproximateLatitude'].toString()) ?? 0,
        longitude:
            double.tryParse(map['sApproximateLongitude'].toString()) ?? 0,
        sSearchType: map['sSearchType'] ?? '');
  }

  String get level2Address {
    return sCustomerViewLevel2!;
  }

  @override
  String toString() =>
      'Place(name: $sCustomerView, state: test, country: test)';

  @override
  // ignore: hash_and_equals
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    return o is Place &&
        o.sCustomerView == sCustomerView &&
        o.sConcatenationContent == sConcatenationContent;
  }
}
