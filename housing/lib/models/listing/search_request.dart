class SearchRequest {
  bool? isMap, bIsDescendingOrder;
  String? sConcatenation, sSortAttribute;
  int? nRangeFirstNumber, nRangeLastNumber;
  double? sWestLng, sSouthLat, sEastLng, sNorthLat, nZoom;

  SearchRequest(
      {this.isMap,
      this.sConcatenation,
      this.bIsDescendingOrder,
      this.sSortAttribute,
      this.nRangeFirstNumber,
      this.nRangeLastNumber,
      this.sWestLng,
      this.sSouthLat,
      this.sEastLng,
      this.sNorthLat,
      this.nZoom});
}
