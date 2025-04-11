class ListingCompInfo {
  String? nCompPrice;
  String? sCompAddress;
  String? sCompLink;

  ListingCompInfo(
      {required this.nCompPrice,
      required this.sCompAddress,
      required this.sCompLink});

  ListingCompInfo.fromJson(Map<String, dynamic> json) {
    nCompPrice =
        json['nCompPrice'] != null ? json['nCompPrice'].toString() : '0';
    sCompAddress = json['sCompAddress'];
    sCompLink = json['sCompLink'];
  }

  static Map<String, dynamic> toJson(ListingCompInfo listingCompInfo) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['nCompPrice'] = listingCompInfo.nCompPrice;
    data['sCompAddress'] = listingCompInfo.sCompAddress;
    data['sCompLink'] = listingCompInfo.sCompLink;
    return data;
  }
}
