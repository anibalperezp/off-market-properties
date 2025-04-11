import 'package:flutter/widgets.dart';
import 'package:zipcular/models/user/user.dart';
import 'package:zipcular/repository/facade/user.facade.dart';

class UserProvider extends ChangeNotifier {
  User user = User(
      sCustomerType: '',
      sAccountStatus: '',
      sFirstName: '',
      sLastName: '',
      sEmail: '',
      sPhoneNumber: '',
      sProfilePicture: '',
      sSuscriptionType: '',
      sMarketArea: '',
      sCreatedDate: '',
      sMarketAreaToShow: '',
      sInvitationCode: '',
      sLanguageSpeak: '',
      sBranchCode: '',
      vfacebook: '',
      bReferralAvailable: false,
      nConnections: 0,
      nRequests: 0,
      bUpdateApp: false,
      bIsIsland: false,
      bReviewed: false,
      sSystemTags: []);

  Future<void> fetchUserFromDatabase() async {
    final result = await UserFacade().getUserService();
    if (result.bSuccess!) {
      user = result.data.item1 as User;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(String sLanguageSpeak, String sBranchCode,
      List<String> sReferalAnswers) async {
    bool result = false;
    final response = await UserFacade()
        .updateProfile(sLanguageSpeak, sBranchCode, sReferalAnswers);
    if (response.bSuccess!) {
      user.sLanguageSpeak = sLanguageSpeak;
      user.sBranchCode = sBranchCode;
      result = response.data as bool;
      notifyListeners();
    }
    return result;
  }

  Future<bool> updateUser(User user, String email, String latitud,
      String longitud, String zipcode) async {
    bool result = false;
    final response =
        await UserFacade().updateUser(user, email, latitud, longitud, zipcode);
    if (response.bSuccess!) {
      user = user;
      notifyListeners();
    }
    return result;
  }

  updateUserProfilePicture(String sProfilePicture) {
    user.sProfilePicture = sProfilePicture;
    notifyListeners();
  }

  saveReview() async {
    final response = await UserFacade().saveReview();
    if (response.bSuccess!) {
      user.bReviewed = true;
      notifyListeners();
    }
  }

  empty() {
    user = User(
        sCustomerType: '',
        sAccountStatus: '',
        sFirstName: '',
        sLastName: '',
        sEmail: '',
        sPhoneNumber: '',
        sProfilePicture: '',
        sSuscriptionType: '',
        sMarketArea: '',
        sCreatedDate: '',
        sMarketAreaToShow: '',
        sInvitationCode: '',
        sLanguageSpeak: '',
        sBranchCode: '',
        vfacebook: '',
        bReferralAvailable: false,
        nConnections: 0,
        nRequests: 0,
        bUpdateApp: false,
        bIsIsland: false,
        bReviewed: false,
        sSystemTags: []);
    return user;
  }

  updateImageProfile(String sProfilePicture) {
    user.sProfilePicture = sProfilePicture;
    notifyListeners();
  }

  updateLanguage(String languages) {
    user.sLanguageSpeak = languages;
    notifyListeners();
  }
}
