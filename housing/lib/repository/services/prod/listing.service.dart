import 'dart:convert';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/commons/main.constants.global.dart';
import 'package:zipcular/models/chat/chat_validation.model.dart';
import 'package:zipcular/models/referal/customer.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/listing/response_get_all.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'package:http/http.dart' as http;
import 'package:zipcular/repository/services/prod/user_repository.dart';
import '../../../models/listing/draft.dart';
import '../../../models/listing/response_get_all_drafts.dart';
import '../../../models/listing/response_validation.dart';
import '../../../models/listing/search/listing_comp_info.dart';
import '../auth/auth.service.dart';
import '../api_response.service.dart';

class ListingServices {
  UserRepository _userRepository = new UserRepository();

//////////////////LISTINGS////////////////////////////////////

  Future<APIResponse<ResponseValidation>> createlysting(Listing listing) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, LISTING_CREATE);

    List<Map<String, dynamic>> comps = List.empty(growable: true);
    if (listing.sCompsInfo.length > 0) {
      for (ListingCompInfo item in listing.sCompsInfo) {
        Map<String, dynamic> result = ListingCompInfo.toJson(item);
        comps.add(result);
      }
    }
    Map<String, dynamic> args = {
      "uLystingId": listing.uLystingId.toString(),
      "sLatitud": listing.sLatitud.toString(),
      "sLongitud": listing.sLongitud.toString(),
      "sSalesPitch": listing.sTitle.toString(),
      "nFirstPrice": listing.nFirstPrice.toString(),
      "nCurrentPrice": listing.nCurrentPrice.toString(),
      "sPropertyAddress": listing.sPropertyAddress.toString(),
      "bKeepAddressPrivate": listing.bKeepAddressPrivate.toString(),
      "sPropertyDescription": listing.sPropertyDescription.toString(),
      "sPropertyType": listing.sPropertyType.toString(),
      "sCoolingType": listing.sCoolingType.toString(),
      "nBedrooms": listing.nBedrooms.toString(),
      "nBathrooms": listing.nBathrooms.toString(),
      "nHalfBaths": listing.nHalfBaths.toString(),
      "sApartmentNumber": listing.sApartmentNumber.toString(),
      "nCoveredParking": listing.nCoveredParking.toString(),
      "sHeatingType": listing.sHeatingType.toString(),
      "sParkingType": listing.sParkingType.toString(),
      "sVacancyType": listing.sVacancyType.toString(),
      "sEarnestMoneyTerms": listing.sEarnestMoneyTerms.toString(),
      "nYearBuilt": listing.nYearBuilt.toString(),
      "sLotSize": listing.nLotSize.toString(),
      "nEarnestMoney": listing.nEarnestMoney.toString(),
      "sAdditionalDealTerms": listing.sAdditionalDealTerms.toString(),
      "nSqft": listing.nSqft.toString(),
      "sLotLegalDescription": listing.sLotLegalDescription.toString(),
      "nNumberofUnits": listing.nNumberofUnits.toString(),
      "sShowingDateTime": listing.sShowingDateTime.toString(),
      "sZipCode": listing.sZipCode.toString(),
      "sUnitArea": listing.sUnitArea.toString(),
      "sTypeOfSell": listing.sTypeOfSell,
      "sAmenities": listing.sAmenities,
      "sPropertyCondition":
          listing.sPropertyType != 'Lot' ? listing.sPropertyCondition : 'None',
      "nMonthlyHoaFee": listing.nMonthlyHoaFee.toString(),
      "sResourcesUrl": [],
      "bComparableAvailable": listing.bComparableAvailable.toString(),
      "nEstARV": listing.nEstARV.toString(),
      "sContactName": listing.sContactName,
      "sContactPhoneNumber": listing.sContactNumber,
      "sContactEmail": listing.sContactEmail,
      "sCompsInfo": comps,
      "sIsOwner": listing.sIsOwner.toString(),
      "bBoostOnPlatforms": listing.bBoostOnPlatforms.toString(),
      "bNetworkBlast": listing.bNetworkBlast.toString(),
      "sTags": listing.sTags,
      "sLystingCategory": listing.sLystingCategory
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        ResponseValidation response = ResponseValidation.fromJson(jsonData);
        return APIResponse<ResponseValidation>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseValidation>(requiredRefreshToken: true);
      } else {
        throw Exception('Create Lysting service failed');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseValidation>(error: true);
    });
  }

  Future<APIResponse<ResponseValidation>> updateLysting(
      Listing listing, bool bImageAdded) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, LISTING_UPDATE);

    List<Map<String, dynamic>> comps = List.empty(growable: true);
    if (listing.sCompsInfo.length > 0) {
      for (ListingCompInfo item in listing.sCompsInfo) {
        Map<String, dynamic> result = ListingCompInfo.toJson(item);
        comps.add(result);
      }
    }
    Map<String, dynamic> args = {
      "bImageAdded": bImageAdded.toString(),
      "sSearch": listing.sSearch,
      "sLogicStatus": listing.sLogicStatus,
      "sLatitud": listing.sLatitud.toString(),
      "sLongitud": listing.sLongitud.toString(),
      "sSalesPitch": listing.sTitle.toString(),
      "nCurrentPrice": listing.nFirstPrice.toString(),
      "sPropertyAddress": listing.sPropertyAddress.toString(),
      "bKeepAddressPrivate": listing.bKeepAddressPrivate.toString(),
      "sPropertyDescription": listing.sPropertyDescription.toString(),
      "sPropertyType": listing.sPropertyType.toString(),
      "sCoolingType": listing.sCoolingType.toString(),
      "nBedrooms": listing.nBedrooms.toString(),
      "nBathrooms": listing.nBathrooms.toString(),
      "nHalfBaths": listing.nHalfBaths.toString(),
      "sApartmentNumber": listing.sApartmentNumber.toString(),
      "nCoveredParking": listing.nCoveredParking.toString(),
      "sHeatingType": listing.sHeatingType.toString(),
      "sParkingType": listing.sParkingType.toString(),
      "sVacancyType": listing.sVacancyType.toString(),
      "sEarnestMoneyTerms": listing.sEarnestMoneyTerms.toString(),
      "nYearBuilt": listing.nYearBuilt.toString(),
      "sLotSize": listing.nLotSize.toString(),
      "nEarnestMoney": listing.nEarnestMoney.toString(),
      "sAdditionalDealTerms": listing.sAdditionalDealTerms.toString(),
      "nSqft": listing.nSqft.toString(),
      "sLotLegalDescription": listing.sLotLegalDescription.toString(),
      "nNumberofUnits": listing.nNumberofUnits.toString(),
      "sShowingDateTime": listing.sShowingDateTime.toString(),
      "sZipCode": listing.sZipCode.toString(),
      "sUnitArea": listing.sUnitArea.toString(),
      "sTypeOfSell": listing.sTypeOfSell,
      "sAmenities": listing.sAmenities,
      "sPropertyCondition":
          listing.sPropertyType != 'Lot' ? listing.sPropertyCondition : 'None',
      "nMonthlyHoaFee": listing.nMonthlyHoaFee.toString(),
      "sResourcesUrl": listing.sResourcesUrl,
      "bComparableAvailable": listing.bComparableAvailable.toString(),
      "nEstARV": listing.nEstARV.toString(),
      "sContactName": listing.sContactName,
      "sContactPhoneNumber": listing.sContactNumber,
      "sContactEmail": listing.sContactEmail,
      "sCompsInfo": comps,
      "sIsOwner": listing.sIsOwner.toString(),
      "bBoostOnPlatforms": listing.bBoostOnPlatforms.toString(),
      "bNetworkBlast": listing.bNetworkBlast.toString(),
      "sTags": listing.sTags,
      "sLystingCategory": listing.sLystingCategory!.isEmpty
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        ResponseValidation response = ResponseValidation.fromJson(jsonData);
        return APIResponse<ResponseValidation>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseValidation>(requiredRefreshToken: true);
      } else {
        throw Exception('Update Lysting service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseValidation>(error: true);
    });
  }

  Future<APIResponse<bool>> submitMedia(String uLystingId, var urls) async {
    var url = Uri.https(baseUrl, LISTING_SUBMIT_MEDIA);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {"sHeader": uLystingId, "contentUrl": urls};
    return http
        .post(url,
            body: json.encode(args),
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
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Submit Media service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }

  Future<APIResponse<bool>> savePreviewShare(
      String sSearch, String sSocialShareLink) async {
    var url = Uri.https(baseUrl, LISTING_PREVIEW_SOCIAL_SHARE);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {
      "sSocialShareLink": sSocialShareLink,
      "sSearch": sSearch
    };
    return http
        .post(url,
            body: json.encode(args),
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
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Submit Media service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }

  Future<APIResponse<bool>> approveListing(String uLystingId) async {
    var url = Uri.https(baseUrl, LISTING_POST);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {"lystingId": uLystingId};
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        UserRepository userRepo = new UserRepository();
        await userRepo.writeToken('loadMyListings', 'true');
        return APIResponse<bool>(data: true, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Approve Listing service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }

  Future<APIResponse<ResponseGetAll>> getlystings(SearchRequest request) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, LISTING_GET_ALL);
    bool isMap = !request.isMap!;
    Map<String, dynamic> args = {
      "bIsMap": isMap.toString(),
      "sConcatenation": request.sConcatenation.toString(),
      "bIsDescendingOrder": request.bIsDescendingOrder.toString(),
      "sSortAttribute": request.sSortAttribute.toString(),
      "nRangeFirstNumber": request.nRangeFirstNumber.toString(),
      "nRangeLastNumber": request.nRangeLastNumber.toString(),
      "sWestLng": request.sWestLng.toString(),
      "sSouthLat": request.sSouthLat.toString(),
      "sEastLng": request.sEastLng.toString(),
      "sNorthLat": request.sNorthLat.toString(),
      "sZoom": request.nZoom.toString()
    };
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        ResponseGetAll response = new ResponseGetAll(count: 0);
        final jsonData = json.decode(data.body);

        final items = jsonData['Items'];

        response.list =
            items.map((dynamic item) => Listing.fromJson(item)).toList();
        response.count = jsonData['count'];
        return APIResponse<ResponseGetAll>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseGetAll>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Lystings service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseGetAll>(error: true);
    });
  }

  Future<APIResponse<ResponseValidation>> validateListing(
      String sZipCode,
      String sPropertyAddress,
      String sApartmentNumber,
      String sPropertyType) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, LISTING_VALIDATE);
    Map<String, dynamic> args = {
      "sZipCode": sZipCode.toString(),
      "sPropertyAddress": sPropertyAddress,
      "sApartmentNumber": sApartmentNumber,
      "sPropertyType": sPropertyType
    };
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);

        ResponseValidation response = ResponseValidation.fromJson(jsonData);
        return APIResponse<ResponseValidation>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseValidation>(requiredRefreshToken: true);
      } else {
        throw Exception('Validate Listing service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseValidation>(error: true);
    });
  }

  Future<APIResponse<bool>> updateSocialShare(
      String sSearch, String sSocialShareLink) async {
    var url = Uri.https(baseUrl, LISTING_SOCIAL_SHARE_UPDATE);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {
      "sSearch": sSearch,
      "sSocialShareLink": sSocialShareLink
    };
    return http
        .post(url,
            body: json.encode(args),
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
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Social Share service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }
//////////////////LISTINGS////////////////////////////////////
  ///
  ///
  ///
  ///
//////////////////DRAFT///////////////////////////////////////

  Future<APIResponse<Listing>> getDraft(
      String sZipCode,
      String sPropertyAddress,
      String sApartmentNumber,
      String sPropertyType) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, DRAFT_GET);
    Map<String, dynamic> args = {
      "sZipCode": sZipCode.toString(),
      "sPropertyAddress": sPropertyAddress,
      "sApartmentNumber": sApartmentNumber,
      "sPropertyType": sPropertyType
    };
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        final item = jsonData['Item'];

        Listing response = Listing.fromJsonDraft(item);
        return APIResponse<Listing>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<Listing>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Draft service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<Listing>(error: true);
    });
  }

  Future<APIResponse<ResponseValidation>> createDraft(Listing listing) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, DRAFT_CREATE);
    List<Map<String, dynamic>> comps = List.empty(growable: true);
    if (listing.sCompsInfo.length > 0) {
      for (ListingCompInfo item in listing.sCompsInfo) {
        Map<String, dynamic> result = ListingCompInfo.toJson(item);
        comps.add(result);
      }
    }

    Map<String, dynamic> args = {
      "uLystingId": listing.uLystingId.toString(),
      "sLatitud": listing.sLatitud.toString(),
      "sLongitud": listing.sLongitud.toString(),
      "sSalesPitch": listing.sTitle.toString(),
      "nFirstPrice": listing.nFirstPrice.toString(),
      "nCurrentPrice": listing.nCurrentPrice.toString(),
      "sPropertyAddress": listing.sPropertyAddress.toString(),
      "bKeepAddressPrivate": listing.bKeepAddressPrivate.toString(),
      "sPropertyDescription": listing.sPropertyDescription.toString(),
      "sPropertyType": listing.sPropertyType.toString(),
      "sCoolingType": listing.sCoolingType.toString(),
      "nBedrooms": listing.nBedrooms.toString(),
      "nBathrooms": listing.nBathrooms.toString(),
      "nHalfBaths": listing.nHalfBaths.toString(),
      "sApartmentNumber": listing.sApartmentNumber.toString(),
      "nCoveredParking": listing.nCoveredParking.toString(),
      "sHeatingType": listing.sHeatingType.toString(),
      "sParkingType": listing.sParkingType.toString(),
      "sVacancyType": listing.sVacancyType.toString(),
      "sEarnestMoneyTerms": listing.sEarnestMoneyTerms.toString(),
      "nYearBuilt": listing.nYearBuilt.toString(),
      "sLotSize": listing.nLotSize.toString(),
      "nEarnestMoney": listing.nEarnestMoney.toString(),
      "sAdditionalDealTerms": listing.sAdditionalDealTerms.toString(),
      "nSqft": listing.nSqft.toString(),
      "sLotLegalDescription": listing.sLotLegalDescription.toString(),
      "nNumberofUnits": listing.nNumberofUnits.toString(),
      "sShowingDateTime": listing.sShowingDateTime.toString(),
      "sZipCode": listing.sZipCode.toString(),
      "sUnitArea": listing.sUnitArea.toString(),
      "sTypeOfSell": listing.sTypeOfSell,
      "sAmenities": listing.sAmenities,
      "sPropertyCondition": listing.sPropertyCondition,
      "nMonthlyHoaFee": listing.nMonthlyHoaFee.toString(),
      "sResourcesUrl": [],
      "bComparableAvailable": listing.bComparableAvailable.toString(),
      "nEstARV": listing.nEstARV.toString(),
      "sContactName": listing.sContactName,
      "sContactPhoneNumber": listing.sContactNumber,
      "sContactEmail": listing.sContactEmail,
      "sCompsInfo": comps,
      "sIsOwner": listing.sIsOwner.toString(),
      "bBoostOnPlatforms": listing.bBoostOnPlatforms.toString(),
      "bNetworkBlast": listing.bNetworkBlast.toString()
    };
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        ResponseValidation response = ResponseValidation.fromJson(jsonData);
        await _userRepository.writeToken('loadMyDrafts', 'true');
        return APIResponse<ResponseValidation>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseValidation>(requiredRefreshToken: true);
      } else {
        throw Exception('Create Draft service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseValidation>(error: true);
    });
  }

  Future<APIResponse<ResponseGetAllDrafts>> getDrafts() async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, DRAFT_GET_ALL);
    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        ResponseGetAllDrafts response =
            new ResponseGetAllDrafts(nDraftTotal: 0);
        final jsonData = json.decode(data.body);
        final items = jsonData['Items'];
        response.list =
            items.map((dynamic item) => Draft.fromJson(item)).toList();
        response.nDraftTotal = jsonData['nDraftTotal'] ?? 0;

        return APIResponse<ResponseGetAllDrafts>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseGetAllDrafts>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Drafts Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseGetAllDrafts>(error: true);
    });
  }

/////////////////////DRAFT END//////////////////////////////////////////
  ///
  ///
  ///
  ///
/////////////////////Single Listing////////////////////////////////////

  Future<APIResponse<Listing>> getlysting(
      String sSearch, String sLogicStatus, bool myListing) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CUSTOMER_LISTING);

    Map<String, dynamic> args = {
      "sSearch": sSearch,
      "sLogicStatus": sLogicStatus,
      "bMyListing": myListing.toString()
    };
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        Listing response = Listing.fromJsonDraft(jsonData);
        return APIResponse<Listing>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<Listing>(requiredRefreshToken: true);
      } else {
        throw Exception('Get Listing Info Service Failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<Listing>(error: true);
    });
  }

  Future<APIResponse<String>> allowAction(
      String sSearch, String parameter) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, ALLOW_CALL_EMAIL);

    Map<String, dynamic> args = {"sSearch": sSearch, "parameter": parameter};
    return http.post(
      url,
      body: json.encode(args),
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        final jsonData = json.decode(data.body);
        String response = jsonData['Item']['parameter'];
        return APIResponse<String>(data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<String>(requiredRefreshToken: true);
      } else {
        throw Exception('Allow Call Or Email service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<String>(error: true);
    });
  }

////////////////////////Single Listing///////////////////////////////////////
  ///
  ///
  ///
////////////////////////Customer Listing////////////////////////////////////

  Future<APIResponse<ResponseGetAll>> getMyListings() async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CUSTOMER_LISTINGS);
    return http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": accessToken
      },
    ).then((data) async {
      if (data.statusCode == 200) {
        ResponseGetAll response = new ResponseGetAll(count: 0);
        final jsonData = json.decode(data.body);
        final items = jsonData['Items'];
        response.list =
            items.map((dynamic item) => Listing.fromJsonDraft(item)).toList();
        response.nTotalForSale = jsonData['nTotalForSale'] ?? 0;
        response.nTotalPending = jsonData['nTotalPending'] ?? 0;
        response.nTotalSold = jsonData['nTotalSold'] ?? 0;
        response.nTotalActionReq = jsonData['nTotalActionReq'] ?? 0;
        response.nTotalOnReview = jsonData['nTotalOnReview'] ?? 0;
        response.nTotalDenied = jsonData['nTotalDenied'] ?? 0;

        return APIResponse<ResponseGetAll>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ResponseGetAll>(requiredRefreshToken: true);
      } else {
        throw Exception('Get My Listings service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ResponseGetAll>(error: true);
    });
  }

  Future<APIResponse<bool>> deleteListing(
      String sSearch, String sLogicStatus) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CUSTOMER_LISTING_DELETE);
    Map<String, dynamic> args = {
      "sSearch": sSearch,
      "sLogicStatus": sLogicStatus
    };
    return http
        .post(url,
            body: json.encode(args),
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
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Delete Listing service failed');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }

  Future<APIResponse<bool>> changeStatusListing(String sSearch,
      String sLogicStatus, bool bKeepAddressPrivate, String sTypeOfSell) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CUSTOMER_LISTING_CHANGE_STATUS);
    Map<String, dynamic> args = {
      "sSearch": sSearch,
      "sLystingStatus": sLogicStatus,
      "bKeepAddressPrivate": bKeepAddressPrivate.toString(),
      "sTypeOfSell": sTypeOfSell
    };
    return http
        .post(url,
            body: json.encode(args),
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
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<bool>(requiredRefreshToken: true);
      } else {
        throw Exception('Change Status Listing service failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<bool>(error: true);
    });
  }

////////////////////////Customer Listing////////////////////////////////////
  ///
  ///
  ///
////////////////////////Customer Profile///////////////////////////////////////
  ///
  ///
  Future<APIResponse<CustomerModel>> getCustomerProfile(
      String sInvitationCode) async {
    var url = Uri.https(baseUrl, LISTING_CUSTOMER_PROFILE);
    final accessToken = await _userRepository.readKey('access_token');
    Map<String, dynamic> args = {
      "sInvitationCode": sInvitationCode,
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        CustomerModel response = CustomerModel.fromJson(jsonData);
        return APIResponse<CustomerModel>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<CustomerModel>(requiredRefreshToken: true);
      } else {
        throw Exception('get Customer Profile failed.');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<CustomerModel>(error: true);
    });
  }

  Future<APIResponse<ChatValidation>> validateAccess(String sInvitationCode,
      String sLystingId, String sChannel, String sMessageCategory) async {
    final accessToken = await _userRepository.readKey('access_token');
    var url = Uri.https(baseUrl, CUSTOMER_VALIDATE);
    Map<String, dynamic> args = {
      "sInvitationCode": sInvitationCode,
      "sLystingId": sLystingId,
      "sChannel": sChannel,
      "sMessageCategory": sMessageCategory
    };
    return http
        .post(url,
            body: json.encode(args),
            headers: {
              "Content-Type": "application/json",
              "Authorization": accessToken
            },
            encoding: Encoding.getByName("utf-8"))
        .then((data) async {
      if (data.statusCode == 200) {
        var jsonData = json.decode(data.body);
        ChatValidation response = ChatValidation.fromJson(jsonData);
        return APIResponse<ChatValidation>(
            data: response, requiredRefreshToken: false);
      } else if (data.statusCode == 401 || data.statusCode == 403) {
        var email = await _userRepository.readKey('email');
        var password = await _userRepository.readKey('password');
        final response =
            await signInWithCredentials(username: email, password: password);
        if (response.error == true) {
          // Logout
          FirebaseCrashlytics.instance.recordError(
              'Sign In With Credentials service error: email $email',
              StackTrace.current);
        }
        return APIResponse<ChatValidation>(requiredRefreshToken: true);
      } else {
        throw Exception('Send Email service failed');
      }
    }).catchError((_) {
      Future.delayed(Duration.zero, () async {
        await FirebaseCrashlytics.instance.recordError(_, StackTrace.current);
      });
      return APIResponse<ChatValidation>(error: true);
    });
  }
}
