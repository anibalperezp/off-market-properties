import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:zipcular/models/common/response-service.model.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/models/listing/search_request.dart';
import 'package:zipcular/repository/facade/base.facade.dart';
import 'package:zipcular/repository/services/prod/listing.service.dart';

class ListingFacade extends BaseFacade {
  ListingServices? listingServices;

  ListingFacade() {
    listingServices = new ListingServices();
  }

  /// Listings

  createlysting(Listing listing) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    if (listing.sLystingCategory!.isEmpty) {
      listing.sLystingCategory = 'Off-Market';
    } else if (listing.sLystingCategory == 'Off market') {
      listing.sLystingCategory = 'Off-Market';
    } else if (listing.sLystingCategory == 'Listed in the MLS') {
      listing.sLystingCategory = 'On-Market';
    }

    var result = await listingServices!.createlysting(listing);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.createlysting(listing);
    }

    await FirebaseCrashlytics.instance.log('Error - Create Lysting - Service');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  updateLysting(Listing listing, bool bImageAdded) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }
    if (listing.sLystingCategory!.isEmpty) {
      listing.sLystingCategory = 'Off-Market';
    } else if (listing.sLystingCategory == 'Off market') {
      listing.sLystingCategory = 'Off-Market';
    } else if (listing.sLystingCategory == 'Listed in the MLS') {
      listing.sLystingCategory = 'On-Market';
    }

    var result = await listingServices!.updateLysting(listing, bImageAdded);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.updateLysting(listing, bImageAdded);
    }

    await FirebaseCrashlytics.instance.log('Error - Update Lysting - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  submitMedia(String uLystingId, var urls) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.submitMedia(uLystingId, urls);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.submitMedia(uLystingId, urls);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Submit Media - Service. Listing id: $uLystingId');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  savePreviewShare(String sSearch, String sSocialShareLink) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result =
        await listingServices!.savePreviewShare(sSearch, sSocialShareLink);
    if (result.requiredRefreshToken == true) {
      result =
          await listingServices!.savePreviewShare(sSearch, sSocialShareLink);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Save Review - Service. Listing id: $sSearch');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  approveListing(String uLystingId) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.approveListing(uLystingId);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.approveListing(uLystingId);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Approve Listing - Service. Listing id: $uLystingId');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  getlystings(SearchRequest request) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.getlystings(request);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.getlystings(request);
    }

    await FirebaseCrashlytics.instance.log('Error - Get Lystings - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  validateListing(String sZipCode, String sPropertyAddress,
      String sApartmentNumber, String sPropertyType) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.validateListing(
        sZipCode, sPropertyAddress, sApartmentNumber, sPropertyType);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.validateListing(
          sZipCode, sPropertyAddress, sApartmentNumber, sPropertyType);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Validate Listing - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  updateSocialShare(String sSearch, String sSocialShareLink) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result =
        await listingServices!.updateSocialShare(sSearch, sSocialShareLink);
    if (result.requiredRefreshToken == true) {
      result =
          await listingServices!.updateSocialShare(sSearch, sSocialShareLink);
    }

    await FirebaseCrashlytics.instance.log('Error - Get Draft - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  /// Drafts

  getDraft(String sZipCode, String sPropertyAddress, String sApartmentNumber,
      String sPropertyType) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!
        .getDraft(sZipCode, sPropertyAddress, sApartmentNumber, sPropertyType);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.getDraft(
          sZipCode, sPropertyAddress, sApartmentNumber, sPropertyType);
    }

    await FirebaseCrashlytics.instance.log('Error - Get Draft - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  createDraft(Listing listing) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.createDraft(listing);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.createDraft(listing);
    }

    await FirebaseCrashlytics.instance.log('Error - Create Draft - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  getDrafts() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.getDrafts();
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.getDrafts();
    }

    await FirebaseCrashlytics.instance.log('Error - Get Drafts - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  /// Single Listing

  getlysting(String sSearch, String sLogicStatus, bool myListing) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result =
        await listingServices!.getlysting(sSearch, sLogicStatus, myListing);
    if (result.requiredRefreshToken == true) {
      result =
          await listingServices!.getlysting(sSearch, sLogicStatus, myListing);
    }

    await FirebaseCrashlytics.instance.log('Error - Get Lysting - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  allowAction(String sSearch, String parameter) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.allowAction(sSearch, parameter);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.allowAction(sSearch, parameter);
    }

    await FirebaseCrashlytics.instance.log('Error - Allow Action - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  /// Customer Listings
  getMyListings() async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: null, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.getMyListings();
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.getMyListings();
    }

    await FirebaseCrashlytics.instance
        .log('Error - Get My Listings - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  deleteListing(String sSearch, String sLogicStatus) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.deleteListing(sSearch, sLogicStatus);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.deleteListing(sSearch, sLogicStatus);
    }

    await FirebaseCrashlytics.instance.log('Error - Delete Listing - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  changeStatusListing(String sSearch, String sLogicStatus,
      bool bKeepAddressPrivate, String sTypeOfSell) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.changeStatusListing(
        sSearch, sLogicStatus, bKeepAddressPrivate, sTypeOfSell);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.changeStatusListing(
          sSearch, sLogicStatus, bKeepAddressPrivate, sTypeOfSell);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Change Status Listing - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data,
        message: '');

    return response;
  }

  getCustomerProfile(String sInvitationCode) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.getCustomerProfile(sInvitationCode);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.getCustomerProfile(sInvitationCode);
    }

    await FirebaseCrashlytics.instance
        .log('Error - Change Status Listing - Service.');

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }

  validateAccess(String sInvitationCode, String sLystingId, String sChannel,
      String sMessageCategory) async {
    bool connection = await checkInternetConnectivity();
    if (!connection) {
      return new ResponseService(
          data: false, hasConnection: false, message: '', bSuccess: false);
    }

    var result = await listingServices!.validateAccess(
        sInvitationCode, sLystingId, sChannel, sMessageCategory);
    if (result.requiredRefreshToken == true) {
      result = await listingServices!.validateAccess(
          sInvitationCode, sLystingId, sChannel, sMessageCategory);
    }

    ResponseService response = ResponseService(
        data: result.data,
        hasConnection: true,
        bSuccess: result.data != null,
        message: '');

    return response;
  }
}
