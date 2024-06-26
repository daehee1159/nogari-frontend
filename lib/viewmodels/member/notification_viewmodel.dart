import 'package:flutter/material.dart';
import 'package:nogari/models/member/notification_data.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationData> notificationList = [];

  int? notificationSeq;

  String? type;
  String? message;
  int? point;

  //
  int? boardSeq;
  DateTime? regDt;
  DateTime? readDt;

  List<NotificationData> get getNotificationList => notificationList;

  int? get getNotificationSeq => notificationSeq;

  String? get getType => type;
  String? get getMessage => message;
  int? get getPoint => point;

  int? get getBoardSeq => boardSeq;
  DateTime? get getRegDt => regDt;
  DateTime? get getReadDt => readDt;

  void initNitification() {
    notificationList = [];
    notifyListeners();
  }

  void addNotification(NotificationData notificationData) {
    notificationList.add(notificationData);
    notifyListeners();
  }

  set setNotificationList(List<NotificationData> list) {
    notificationList = [];
    notificationList = list;
    // notifyListeners();
  }

  set setNotificationSeq(int? value) {
    notificationSeq = value;
    notifyListeners();
  }

  set setType(String? value) {
    type = value;
    notifyListeners();
  }

  set setMessage(String? value) {
    message = value;
    notifyListeners();
  }

  set setPoint(int? value) {
    point = value;
    notifyListeners();
  }

  set setBoardSeq(int? value) {
    boardSeq = value;
    notifyListeners();
  }

  set setRegDt(String? value) {
    regDt = DateTime.parse(value.toString());
    notifyListeners();
  }

  set setReadDt(String? value) {
    readDt = DateTime.parse(value.toString());
    notifyListeners();
  }

  void callNotify() {
    notifyListeners();
  }
}
