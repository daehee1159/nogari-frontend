import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:nogari/models/member/notification_dto.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationDto> notificationList = [];

  int? notificationSeq;

  String? type;
  String? message;
  int? point;

  //
  int? boardSeq;
  DateTime? regDt;
  DateTime? readDt;

  List<NotificationDto> get getNotificationList => notificationList;

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

  void addNotification(NotificationDto notificationDto) {
    notificationList.add(notificationDto);
    notifyListeners();
  }

  set setNotificationList(List<NotificationDto> list) {
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
