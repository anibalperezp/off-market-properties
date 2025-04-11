import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:intl/intl.dart';
import 'package:zipcular/models/listing/search/listing.dart';
import 'package:zipcular/repository/facade/listing.facade.dart';
import 'package:zipcular/repository/services/prod/user_repository.dart';

class BranchConstants {
  static const BRANCH_REFERAL = 'referal';
  static const BRANCH_LISTING = 'sSearch';
}

getTypeOfSell(String typeOfSell) {
  switch (typeOfSell) {
    case 'Fixer Upper':
      return 'Flip Potential';
    case 'Tenant Occupied Rental':
      return 'Cash Flowing';
    case 'Short Term Rental':
      return 'Short Term Rentals';
    default:
      return typeOfSell;
  }
}

createSocialShare(Listing item) async {
  final oCcy = new NumberFormat("#,###", "en_US");
  final title = getTypeOfSell(item.sTypeOfSell!) + ' - ' + item.sPropertyType!;
  String description = '';
  String address = item.sPropertyAddress!;
  String price = "Asking: \$${oCcy.format(item.nFirstPrice)}";
  switch (item.sPropertyType!) {
    case 'Single Family':
      description = item.nBedrooms.toString() +
          ' Beds, ' +
          item.nBathrooms.toString() +
          ' Baths, ' +
          item.nSqft.toString() +
          ' sqft';
      break;
    case 'Apartment':
      description = item.nBedrooms.toString() +
          ' Beds, ' +
          item.nBathrooms.toString() +
          ' Baths, ' +
          item.nSqft.toString() +
          ' sqft';
      break;
    case 'Condo':
      description = item.nBedrooms.toString() +
          ' Beds, ' +
          item.nBathrooms.toString() +
          ' Baths, ' +
          item.nSqft.toString() +
          ' sqft';
      break;
    case 'Townhome':
      description = item.nBedrooms.toString() +
          ' Beds, ' +
          item.nBathrooms.toString() +
          ' Baths, ' +
          item.nSqft.toString() +
          ' sqft';
      break;
    case 'Lot':
      description = item.sLotSize!;
      break;
    case 'Multi-Unit Complex':
      description = item.nNumberofUnits.toString() +
          ' Units, ' +
          item.nSqft!.toString() +
          ' sqft';
      break;
  }
  UserRepository userRepository = UserRepository();
  final invitationCode = await userRepository.readKey('invitationCode');
  try {
    BranchContentMetaData metadata = BranchContentMetaData();
    metadata = BranchContentMetaData()
      ..addCustomMetadata('sSearch', item.sSearch!)
      ..addCustomMetadata('referal', invitationCode);

    // Setting image
    String image = item.sResourcesUrl[0];

    // Creating BranchUniversalObject to share
    BranchUniversalObject branchUniversalObject = BranchUniversalObject(
        canonicalIdentifier: item.sSearch!,
        title: 'Great deal at Zeamless App. ' + price + '. ' + title,
        contentDescription: title +
            '\n' +
            price +
            '. At ' +
            address +
            '\n' +
            description +
            '\n' +
            'Check it out!',
        imageUrl: image,
        keywords: ['zeamless', 'social_app', 'real_estate', 'deep_linking'],
        publiclyIndex: true,
        locallyIndex: true,
        contentMetadata: metadata);

    final BranchLinkProperties linkProperties = BranchLinkProperties(
        channel: 'App',
        feature: 'sharing_listing',
        campaign: 'promotion',
        stage: 'new_share');

    final BranchResponse response = await FlutterBranchSdk.getShortUrl(
      linkProperties: linkProperties,
      buo: branchUniversalObject,
    );

    FlutterBranchSdk.clearPartnerParameters();

    if (response.success) {
      await ListingFacade().savePreviewShare(item.sSearch!, response.result);
    }
    return response.result;
  } catch (e) {
    await FirebaseCrashlytics.instance.recordError(e, StackTrace.current);
  }
}
