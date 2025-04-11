class NotificationModel {
  String? sCategory;
  String? uNotificationId;
  String? sCreationDate;
  String? sSubCategory;
  String? sBody;
  bool? bIsSeenIt;
  int? nSortDate;

  NotificationModel(
      {this.sCategory,
      this.uNotificationId,
      this.sCreationDate,
      this.sSubCategory,
      this.sBody,
      this.bIsSeenIt,
      this.nSortDate});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
        sCategory: json['sCategory'] ?? '',
        uNotificationId: json['uNotificationId'].toString() ?? '',
        sCreationDate: json['sCreationDate'] ?? '',
        sSubCategory: json['sSubCategory'] ?? '',
        sBody: json['sBody'] ?? '',
        bIsSeenIt: json['bIsSeenIt'] ?? false,
        nSortDate: json['nSortDate'] ?? 0);
  }
}
