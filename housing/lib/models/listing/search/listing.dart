import 'dart:io';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/listing/search/listing_comp_info.dart';

class Listing {
  String? uLystingId,
      sTitle,
      sPropertyDescription,
      sPropertyAddress,
      sPropertyType,
      sCoolingType,
      sHeatingType,
      sParkingType,
      sVacancyType,
      sEarnestMoneyTerms,
      sAdditionalDealTerms,
      sLotLegalDescription,
      sZipCode,
      sContactName,
      sContactNumber,
      sContactEmail,
      sShowingDateTime,
      sLystingStatus,
      sLystingDate,
      sUnitArea,
      sApartmentNumber,
      sTypeOfSell,
      sFavoriteIV,
      sFavoriteContent,
      sPropertyCondition,
      sSearch,
      sIsInMLS,
      sIsOwner,
      sCreationDraftDate,
      nDaysOnZipcular,
      sLotSize,
      sLogicStatus,
      sNewMarker,
      sProfilePicture,
      sInvitationCode,
      sSocialShareLink,
      sLystingCategory;

  int? nSqft,
      nYearBuilt,
      nCoveredParking,
      nBedrooms,
      nBathrooms,
      nHalfBaths,
      nNumberofUnits,
      nEarnestMoney,
      nFirstPrice,
      nCurrentPrice,
      nPricePerArea,
      nDaysInTheMarket,
      nPricePerSqft,
      nMonthlyHoaFee,
      nTotalPhotos,
      clusterId,
      pointCount,
      nEstARV,
      nEstSpread,
      nPricePerSqftARV;

  double? nLotSize, sLatitud, sLongitud;
  Color? color;
  bool? bKeepAddressPrivate,
      bIsPrivated,
      bIsLystingPaid,
      bIsFavorite,
      isCluster,
      bComparableAvailable,
      bIsNew,
      propTypeChanged,
      bNetworkBlast,
      bBoostOnPlatforms,
      bHasZeamlessUser;
  List<File>? imagesAssets;
  List<String>? sAmenities, sTags;
  var sResourcesUrl, sCompsInfo, sResourcesAmenities;

  Listing(
      {this.uLystingId,
      this.sTitle,
      this.nFirstPrice,
      this.nCurrentPrice,
      this.sPropertyAddress,
      this.bKeepAddressPrivate,
      this.sPropertyDescription,
      this.sPropertyType,
      this.sCoolingType,
      this.nBedrooms,
      this.nBathrooms,
      this.nHalfBaths,
      this.nCoveredParking,
      this.sHeatingType,
      this.sParkingType,
      this.sVacancyType,
      this.sEarnestMoneyTerms,
      this.sAdditionalDealTerms,
      this.nYearBuilt,
      this.nLotSize,
      this.sUnitArea,
      this.nEarnestMoney,
      this.nSqft,
      this.sLotLegalDescription,
      this.nNumberofUnits,
      this.sShowingDateTime,
      this.sZipCode,
      this.sContactName,
      this.sContactNumber,
      this.sContactEmail,
      this.imagesAssets,
      this.sResourcesUrl,
      this.sAmenities,
      this.sTags,
      this.sLystingCategory,
      this.sResourcesAmenities,
      this.sLatitud,
      this.sLongitud,
      this.nPricePerArea,
      this.bIsLystingPaid,
      this.sLystingStatus,
      this.sLystingDate,
      this.sApartmentNumber,
      this.nDaysInTheMarket,
      this.sTypeOfSell,
      this.nPricePerSqft,
      this.sFavoriteIV,
      this.sFavoriteContent,
      this.bIsFavorite,
      this.sPropertyCondition,
      this.sIsInMLS,
      this.nMonthlyHoaFee,
      this.bIsPrivated,
      this.sSearch,
      this.nTotalPhotos,
      this.isCluster,
      this.clusterId,
      this.pointCount,
      this.nEstARV,
      this.sIsOwner,
      this.bComparableAvailable,
      this.sCompsInfo,
      this.sCreationDraftDate,
      this.nEstSpread,
      this.nPricePerSqftARV,
      this.nDaysOnZipcular,
      this.sLotSize,
      this.sLogicStatus,
      this.bIsNew,
      this.propTypeChanged,
      this.sNewMarker,
      this.sProfilePicture,
      this.sInvitationCode,
      this.sSocialShareLink,
      this.bNetworkBlast,
      this.bBoostOnPlatforms,
      this.bHasZeamlessUser});

  factory Listing.fromJson(Map<String, dynamic> json) {
    var listing;
    try {
      final items = json['properties']['sCompsInfo'] ?? null;
      final comps = items == null
          ? List.empty(growable: true)
          : items
              .map((dynamic item) => ListingCompInfo.fromJson(item))
              .toList();

      listing = Listing(
        //Geometry
        sLongitud: double.parse(json['geometry']['coordinates'][0].toString()),
        sLatitud: double.parse(json['geometry']['coordinates'][1].toString()),

        // Properties
        uLystingId: json['properties']['uLystingId'] ?? '',
        nYearBuilt: json['properties']['nYearBuilt'] != null
            ? json['properties']['nYearBuilt'] as int
            : 0,
        bIsLystingPaid: json['properties']['bIsLystingPaid'] ?? false,
        sLystingDate: json['properties']['sLystingDate'] ?? '',
        sLystingStatus: json['properties']['sLystingStatus'] ?? '',
        sPropertyAddress: json['properties']['sAddressToShow'] ?? '',
        nCurrentPrice: json['properties']['nCurrentPrice'] ?? 0,
        sPropertyType: json['properties']['sPropertyType'] ?? '',
        nBedrooms: json['properties']['nBedrooms'] ?? 0,
        nBathrooms: json['properties']['nBathrooms'] ?? 0,
        nHalfBaths: json['properties']['nHalfBaths'] ?? 0,
        sVacancyType: json['properties']['sVacancyType'] ?? '',
        sCoolingType: json['properties']['sCoolingType'] ?? '',
        sHeatingType: json['properties']['sHeatingType'] ?? '',
        sParkingType: json['properties']['sParkingType'] ?? '',
        sPropertyDescription: json['properties']['sPropertyDescription'] ?? '',
        sEarnestMoneyTerms: json['properties']['sEarnestMoneyTerms'] ?? '',
        sAdditionalDealTerms: json['properties']['sAdditionalDealTerms'] ?? '',
        sShowingDateTime: json['properties']['sShowingDateTime'] ?? '',
        nLotSize: json['properties']['nLotSize'] ?? 0,
        sLotSize: json['properties']['sLotSize'] ?? '',
        sResourcesUrl: json['properties']['sMainImages'] ?? [],
        nNumberofUnits: json['properties']['nNumberofUnits'] ?? 0,
        nSqft: json['properties']['nSqft'] ?? 0,
        nPricePerSqft: json['properties']['nPricePerSqft'] ?? 0,
        sTypeOfSell: json['properties']['sTypeOfSell'] ?? '',
        bIsFavorite: json['properties']['bIsFavorite'] ?? false,
        bHasZeamlessUser: json['properties']['bHasZeamlessUser'] ?? false,
        nFirstPrice: json['properties']['nFirstPrice'] ?? 0,
        sSearch: json['properties']['sSearch'] ?? '',
        bIsPrivated: json['properties']['bKeepAddressPrivate'] ?? false,
        sNewMarker: json['properties']['sNewMarker'] != null
            ? 'assets/images/markers/' +
                json['properties']['sNewMarker'] +
                '.png'
            : '',
        nTotalPhotos: json['properties']['nTotalPhotos'] ?? 0,
        sPropertyCondition: json['properties']['sPropertyCondition'] ?? '',
        isCluster: json['properties']['cluster'] ?? false,
        clusterId: json['properties']['cluster_id'] ?? 0,
        pointCount: json['properties']['point_count'] ?? 0,
        sContactName: json['properties']['sContactName'] ?? '',
        sContactNumber: json['properties']['sContactNumber'] ?? '',
        sContactEmail: json['properties']['sContactEmail'] ?? '',
        sSocialShareLink: json['properties']['sSocialShareLink'] ?? '',
        sLystingCategory: json['properties']['sLystingCategory'] ?? '',
        sLogicStatus: 'Live',
        sTags: json['properties']['sTags'] != null
            ? (json['properties']['sTags'] as List)
                    .map((item) => item as String)
                    .toList() ??
                null
            : null,
        sTitle: json['properties']['sSalesPitch'] ?? null,
        bIsNew: json['properties']['bIsNew'] ?? false,
        nEstARV: json['properties']['nEstARV'] ?? 0,
        sInvitationCode: json['properties']['sInvitationCode'] ?? '',
        sProfilePicture: json['properties']['sProfilePicture'] ?? '',
        bComparableAvailable: json['properties']['bComparableAvailable']
                    .toString()
                    .toLowerCase() ==
                'true' ??
            false,
        sCompsInfo: comps,
        bNetworkBlast:
            json['properties']['bNetworkBlast'].toString().toLowerCase() ==
                    'true' ??
                false,
        bBoostOnPlatforms:
            json['properties']['bBoostOnPlatforms'].toString().toLowerCase() ==
                    'true' ??
                false,
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return listing;
  }

  factory Listing.fromJsonDraft(Map<String, dynamic> json) {
    var listing;
    try {
      final items = json['sCompsInfo'] ?? null;
      final comps = items == null
          ? List.empty(growable: true)
          : items
              .map((dynamic item) => ListingCompInfo.fromJson(item))
              .toList();

      listing = Listing(
        uLystingId: json['uLystingId'] ?? '',
        //Geometry
        sLongitud: json['sLongitud'] != null
            ? double.parse(json['sLongitud'].toString())
            : 0.0,
        sLatitud: json['sLatitud'] != null
            ? double.parse(json['sLatitud'].toString())
            : 0.0,
        // Properties
        bIsNew: json['bIsNew'] ?? false,
        nCoveredParking: json['nCoveredParking'] ?? 0,
        sCoolingType: json['sCoolingType'] ?? '',
        sUnitArea: json['sUnitArea'] ?? '',
        sEarnestMoneyTerms: json['sEarnestMoneyTerms'] ?? '',
        nYearBuilt: json['nYearBuilt'] ?? 2022,
        sParkingType: json['sParkingType'] ?? '',
        sVacancyType: json['sVacancyType'] ?? '',
        bKeepAddressPrivate:
            json['bKeepAddressPrivate'].toString().toLowerCase() == 'true' ??
                false,
        sApartmentNumber: json['sApartmentNumber'] ?? '',
        sAmenities: json['sAmenities'] != null
            ? (json['sAmenities'] as List)
                    .map((item) => item as String)
                    .toList() ??
                null
            : null,
        sTags: json['sTags'] != null
            ? (json['sTags'] as List).map((item) => item as String).toList() ??
                null
            : null,
        bComparableAvailable:
            json['bComparableAvailable'].toString().toLowerCase() == 'true' ??
                false,
        sTitle: json['sSalesPitch'] ?? '',
        sPropertyAddress: json['sAddressToShow'] ?? json['sPropertyAddress'],
        nCurrentPrice: json['nCurrentPrice'] ?? 0,
        sHeatingType: json['sHeatingType'] ?? '',
        sContactNumber: json['sContactPhoneNumber'] ?? '',
        sResourcesUrl: json['sResourcesUrl'] != null
            ? json['sResourcesUrl']
            : json['sMainImages'],
        sTypeOfSell: json['sTypeOfSell'] ?? '',
        sPropertyType: json['sPropertyType'] ?? '',
        nHalfBaths: json['nHalfBaths'] ?? 0,
        sAdditionalDealTerms: json['sAdditionalDealTerms'] ?? '',
        nMonthlyHoaFee: json['nMonthlyHoaFee'] ?? 0,
        sShowingDateTime: json['sShowingDateTime'] ?? 'Not provided',
        nNumberofUnits: json['nNumberofUnits'] ?? 0,
        nEarnestMoney: json['nEarnestMoney'] ?? 0,
        sLotLegalDescription: json['sLotLegalDescription'] ?? '',
        sZipCode: json['sZipCode'] ?? '',
        sContactEmail: json['sContactEmail'] ?? '',
        sCreationDraftDate: json['sCreationDraftDate'] ?? '',
        nSqft: json['nSqft'] ?? 0,
        sPropertyDescription: json['sPropertyDescription'] ?? '',
        nBedrooms: json['nBedrooms'] ?? 0,
        nBathrooms: json['nBathrooms'] ?? 0,
        nFirstPrice: json['nFirstPrice'] ?? 0,
        nLotSize: json['nLotSize'] != null
            ? double.parse(json['nLotSize'].toString())
            : 0,
        sLotSize: json['sLotSize'] ?? '',
        nEstARV: json['nEstARV'] != null
            ? int.tryParse(json['nEstARV'].toString())
            : 0,
        sPropertyCondition: json['sPropertyCondition'] ?? '',
        sContactName: json['sContactName'] ?? '',
        sIsOwner: json['sIsOwner'] ?? '',
        nEstSpread: json['nEstSpread'] ?? 0,
        nPricePerSqft: json['nPricePerSqft'] ?? 0,
        sSearch: json['sSearch'] ?? '',
        sLystingDate: json['sLystingDate'] ?? '',
        sLystingStatus: json['sLystingStatus'] ?? '',
        nPricePerSqftARV: json['nPricePerSqftARV'] ?? 0,
        nDaysOnZipcular: json['nDaysOnZipcular'] ?? '',
        sInvitationCode: json['sInvitationCode'] ?? '',
        sSocialShareLink: json['sSocialShareLink'] ?? '',
        sCompsInfo: comps,
        sProfilePicture: json['sProfilePicture'] ?? '',
        bIsFavorite: json['bIsFavorite'] != null ? json['bIsFavorite'] : false,
        sLogicStatus: json['sLogicStatus'] ?? '',
        sLystingCategory: json['sLystingCategory'] ?? '',
        bNetworkBlast:
            json['bNetworkBlast'].toString().toLowerCase() == 'true' ?? false,
        bBoostOnPlatforms:
            json['bBoostOnPlatforms'].toString().toLowerCase() == 'true' ??
                false,
        bHasZeamlessUser:
            json['bHasZeamlessUser'].toString().toLowerCase() == 'true' ??
                false,
      );
    } catch (e) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
      });
    }
    return listing;
  }
}
