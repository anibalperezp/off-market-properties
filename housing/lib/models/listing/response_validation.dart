class ResponseValidation {
  String? sStatus;
  String? sHeader;
  String? sDescription;
  bool? bContinue;

  ResponseValidation(
      {required this.sStatus,
      required this.sHeader,
      required this.sDescription,
      required this.bContinue});

  ResponseValidation.fromJson(Map<String, dynamic> json) {
    sStatus = json['sStatus'];
    sHeader = json['sHeader'];
    sDescription = json['sDescription'];
    bContinue = json['bContinue'].toString().toLowerCase() == 'true';
  }
}
