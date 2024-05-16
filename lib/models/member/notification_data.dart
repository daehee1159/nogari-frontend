class NotificationData {
  late int notificationSeq;
  late String type;
  late String message;
  late int? boardSeq;
  late String regDt;
  late String? readDt;

  NotificationData({
    required this.notificationSeq,
    required this.type,
    required this.message,
    required this.boardSeq,
    required this.regDt,
    required this.readDt
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    notificationSeq = json['notificationSeq'];
    type = json['type'];
    message = json['message'];
    boardSeq = json['boardSeq'];
    regDt = json['regDt'];
    readDt = json['readDt'];
  }
}
