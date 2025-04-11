class ResponseAddListing {
  String urlName, resourceIv, resourceContent;

  ResponseAddListing(
      {required this.urlName,
      required this.resourceIv,
      required this.resourceContent});

  factory ResponseAddListing.fromJson(Map<String, dynamic> map) {
    return ResponseAddListing(
        urlName: map['urlName'] ?? '',
        resourceIv: map['resourceIv'] ?? '',
        resourceContent: map['resourceContent'] ?? '');
  }
}
