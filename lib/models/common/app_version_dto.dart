class AppVersionDto {
  final int appVersionSeq;
  final String android;
  final String ios;
  final String regDt;

  AppVersionDto(
      {required this.appVersionSeq,
        required this.android,
        required this.ios,
        required this.regDt});

  factory AppVersionDto.fromJson(Map<String, dynamic> json) {
    return AppVersionDto(
      appVersionSeq: json['appVersionSeq'],
      android: json['android'],
      ios: json['ios'],
      regDt: json['regDt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['appVersionSeq'] = appVersionSeq;
    data['android'] = android;
    data['ios'] = ios;
    data['regDt'] = regDt;
    return data;
  }
}
