import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class FilterModel {
  int nPriceMin,
      nPriceMax,
      nYearBuiltMin,
      nYearBuiltMax,
      nSqftMin,
      nSqftMax,
      nPricePerSqftMin,
      nPricePerSqftMax,
      nBedroomsMax,
      nBathroomsMax,
      nLotSizeMin,
      nLotSizeMax,
      nTotalPhotosMin,
      nTotalPhotosMax,
      nDaysOnZipCularMin,
      nDaysOnZipCularMax,
      nCountFilter;
  var nBedrooms,
      nBathrooms,
      sLystingStatus,
      sPropertyType,
      sTypeOfSell,
      sTags,
      sLystingCategory,
      sPropertyCondition;

  FilterModel(
      {required this.nPriceMin,
      required this.nPriceMax,
      required this.nYearBuiltMin,
      required this.nYearBuiltMax,
      required this.nSqftMin,
      required this.nSqftMax,
      required this.nPricePerSqftMin,
      required this.nPricePerSqftMax,
      required this.nBedrooms,
      required this.nBedroomsMax,
      required this.nBathrooms,
      required this.nBathroomsMax,
      required this.sLystingStatus,
      required this.sPropertyType,
      required this.sTypeOfSell,
      required this.sTags,
      required this.sLystingCategory,
      required this.sPropertyCondition,
      required this.nLotSizeMin,
      required this.nLotSizeMax,
      required this.nTotalPhotosMin,
      required this.nTotalPhotosMax,
      required this.nDaysOnZipCularMin,
      required this.nDaysOnZipCularMax,
      required this.nCountFilter});

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    FilterModel? filter;
    try {
      filter = new FilterModel(
          nPriceMin: json['nPriceMin'] as int,
          nPriceMax: json['nPriceMax'] as int,
          nYearBuiltMin: json['nYearBuiltMin'] as int,
          nYearBuiltMax: json['nYearBuiltMax'] as int,
          nSqftMin: json['nSqftMin'] as int,
          nSqftMax: json['nSqftMax'] as int,
          nPricePerSqftMin: json['nPricePerSqftMin'] as int,
          nPricePerSqftMax: json['nPricePerSqftMax'] as int,
          nBedrooms: json['nBedrooms'],
          nBedroomsMax: json['nBedroomsMax'] as int,
          nBathrooms: json['nBathrooms'],
          nBathroomsMax: json['nBathroomsMax'] as int,
          sLystingStatus: json['sLystingStatus'],
          sPropertyType: json['sPropertyType'],
          sTypeOfSell: json['sTypeOfSell'],
          sTags: json['sTags'],
          sLystingCategory: json['sLystingCategory'],
          sPropertyCondition: json['sPropertyCondition'],
          nLotSizeMin: json['nLotSizeMin'] as int,
          nLotSizeMax: json['nLotSizeMax'],
          nTotalPhotosMin: json['nTotalPhotosMin'] as int,
          nTotalPhotosMax: json['nTotalPhotosMax'] as int,
          nDaysOnZipCularMin: json['nDaysOnZipCularMin'] as int,
          nDaysOnZipCularMax: json['nDaysOnZipCularMax'] as int,
          nCountFilter: json['nCountFilter'] as int);
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return filter!;
  }
}
