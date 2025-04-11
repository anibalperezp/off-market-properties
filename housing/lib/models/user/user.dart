import 'package:equatable/equatable.dart';

class User extends Equatable {
  User(
      {required this.sCustomerType,
      required this.sAccountStatus,
      required this.sFirstName,
      required this.sLastName,
      required this.sEmail,
      required this.sPhoneNumber,
      required this.sProfilePicture,
      required this.sSuscriptionType,
      required this.sMarketArea,
      required this.sCreatedDate,
      required this.sMarketAreaToShow,
      required this.sInvitationCode,
      required this.sBranchCode,
      required this.sLanguageSpeak,
      required this.vfacebook,
      required this.bReferralAvailable,
      required this.nConnections,
      required this.nRequests,
      required this.bUpdateApp,
      required this.bIsIsland,
      required this.sSystemTags,
      required this.bReviewed});

  String sCustomerType,
      sAccountStatus,
      sFirstName,
      sLastName,
      sEmail,
      sProfilePicture,
      sPhoneNumber,
      sSuscriptionType,
      sMarketArea,
      sCreatedDate,
      sMarketAreaToShow,
      sInvitationCode,
      sBranchCode,
      sLanguageSpeak,
      vfacebook;
  bool bReferralAvailable, bUpdateApp, bIsIsland, bReviewed;
  int nConnections, nRequests;
  var sSystemTags;

  List<Object?> get props => [
        sCustomerType,
        sAccountStatus,
        sFirstName,
        sLastName,
        sEmail,
        sPhoneNumber,
        sProfilePicture,
        sSuscriptionType,
        sMarketArea,
        sCreatedDate,
        sMarketAreaToShow,
        sInvitationCode,
        sBranchCode,
        sLanguageSpeak,
        vfacebook,
        bReferralAvailable,
        nConnections,
        nRequests,
        vfacebook,
        bUpdateApp,
        bIsIsland,
        sSystemTags,
        bReviewed
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    final user = User(
        sCustomerType: json['sCustomerType'] ?? '',
        sAccountStatus: json['sAccountStatus'] ?? '',
        sFirstName: json['sFirstName'] ?? '',
        sLastName: json['sLastName'] ?? '',
        sEmail: json['sEmail'] ?? '',
        sPhoneNumber: json['sPhoneNumber'] ?? '',
        sProfilePicture: json['sProfilePicture'] ?? '',
        sSuscriptionType: json['sSuscriptionType'] ?? '',
        sMarketArea: json['sMarketArea'] ?? '',
        sCreatedDate: json['sCreatedDate'] ?? '',
        sMarketAreaToShow: json['sMarketAreaToShow'] ?? '',
        sInvitationCode: json['sInvitationCode'] ?? '',
        sLanguageSpeak: json['sLanguageSpeak'] ?? '',
        sBranchCode: json['sBranchCode'] ?? '',
        vfacebook: json['sVersionFacebook'] ?? '',
        bReferralAvailable: json['bReferralAvailable'] ?? false,
        bIsIsland: json['bIsIsland'] ?? false,
        bUpdateApp: json['bUpdateApp'] ?? false,
        nConnections: json['nConnections'] ?? 0,
        nRequests: json['nRequests'] ?? 0,
        sSystemTags: json['sSystemTags'] ?? [],
        bReviewed: json['bReviewed'] ?? false);
    return user;
  }
}
