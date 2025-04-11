class ResponseGetAll {
  var list;
  late int count;
  late int nTotalForSale;
  late int nTotalPending;
  late int nTotalSold;
  late int nTotalActionReq;
  late int nTotalOnReview;
  late int nTotalDenied;

  ResponseGetAll({this.list, required this.count});
}
