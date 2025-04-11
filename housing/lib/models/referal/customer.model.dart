import 'package:zipcular/models/listing/search/listing.dart';

class CustomerModel {
  String? sCustomerType,
      sFirstName,
      sLastName,
      sProfilePicture,
      sCreatedDate,
      sLanguageSpeak,
      sInvitationCode,
      sConnectedTime,
      sStatus;
  int? nProperties, nConnections;

  List<Listing>? sProperties;

  CustomerModel(
      {this.sCustomerType,
      this.sFirstName,
      this.sLastName,
      this.sProfilePicture,
      this.sCreatedDate,
      this.sProperties,
      this.nProperties,
      this.sLanguageSpeak,
      this.nConnections,
      this.sInvitationCode,
      this.sConnectedTime,
      this.sStatus});

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    var customer = CustomerModel.empty();

    try {
      final items = json['sProperties'] ?? null;
      final properties = List<Listing>.empty(growable: true);
      if (items != null) {
        for (var item in items) {
          properties.add(Listing.fromJsonDraft(item));
        }
      }

      customer = CustomerModel(
          sCustomerType: json['sCustomerInfo']['sCustomerType'] ?? '',
          sFirstName: json['sCustomerInfo']['sFirstName'] ?? '',
          sLastName: json['sCustomerInfo']['sLastName'] ?? '',
          sProfilePicture: json['sCustomerInfo']['sProfilePicture'] ?? '',
          sCreatedDate: json['sCustomerInfo']['sCreatedDate'] ?? '',
          sInvitationCode: json['sCustomerInfo']['sInvitationCode'] ?? '',
          nConnections: json['sCustomerInfo']['nConnections'] ?? 0,
          nProperties: properties.length,
          sLanguageSpeak: json['sCustomerInfo']['sLanguageSpeak'] ?? '',
          sStatus: json['sCustomerInfo']['sStatus'] ?? '',
          sProperties: properties,
          sConnectedTime: json['sCustomerInfo']['sConnectedTime'] ?? '');
    } catch (e) {
      print('Error parsing customer model: $e');
    }

    return customer;
  }

  factory CustomerModel.fromNetworkJson(Map<String, dynamic> json) {
    var customer = CustomerModel.empty();

    try {
      customer = CustomerModel(
        sCustomerType: json['sCustomerType'] ?? '',
        sFirstName: json['sFirstName'] ?? '',
        sLastName: json['sLastName'] ?? '',
        sProfilePicture: json['sProfilePicture'] ?? '',
        sCreatedDate: json['sCreatedDate'] ?? '',
        sInvitationCode: json['sInvitationCode'] ?? '',
        nConnections: json['nConnections'] ?? 0,
        nProperties: json['nProperties'] ?? 0,
        sLanguageSpeak: json['sLanguageSpeak'] ?? '',
        sConnectedTime: json['sConnectedTime'] ?? '',
        sStatus: json['sStatus'] ?? '',
        sProperties: List<Listing>.empty(growable: true),
      );
    } catch (e) {
      print('Error parsing customer model: $e');
    }

    return customer;
  }

  static CustomerModel empty() {
    return CustomerModel(
        nConnections: 0,
        nProperties: 0,
        sCustomerType: '',
        sFirstName: '',
        sLastName: '',
        sProfilePicture: '',
        sCreatedDate: '',
        sLanguageSpeak: '',
        sInvitationCode: '',
        sConnectedTime: '',
        sStatus: '',
        sProperties: List.empty(growable: true));
  }
}
