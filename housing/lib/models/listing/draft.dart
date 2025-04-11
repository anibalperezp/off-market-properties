class Draft {
  String? sPropertyAddress;
  String? sPropertyType;
  String? sCreationDraftDate;
  String? uLystingId;
  String? sZipCode;
  String? sLogicStatus;

  Draft(
      {this.sPropertyAddress,
      this.sPropertyType,
      this.sCreationDraftDate,
      this.uLystingId,
      this.sZipCode,
      this.sLogicStatus});

  factory Draft.fromJson(Map<String, dynamic> json) {
    return Draft(
        sPropertyAddress: json['sPropertyAddress'],
        sPropertyType: json['sPropertyType'],
        sCreationDraftDate: json['sCreationDraftDate'],
        uLystingId: json['uLystingId'],
        sZipCode: json['sZipCode'],
        sLogicStatus: json['sLogicStatus']);
  }
}
