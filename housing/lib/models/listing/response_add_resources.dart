class ResponseAddResources {
  String url, queryParameters;

  ResponseAddResources({required this.url, required this.queryParameters});

  factory ResponseAddResources.fromJson(Map<String, dynamic> map) {
    return ResponseAddResources(
        url: map['url'] ?? '', queryParameters: map['queryParameters'] ?? '');
  }
}
