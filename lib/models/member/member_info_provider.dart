import 'package:flutter/material.dart';

class MemberInfoProvider extends ChangeNotifier {
  int? memberSeq;
  String? nickName;
  String? device;
  String? deviceToken;
  String? status;
  DateTime? regDt;


  int? get getMemberSeq => memberSeq;
  String? get getNickName => nickName;
  String? get getDevice => device;
  String? get getDeviceToken => deviceToken;
  String? get getStatus => status;
  DateTime? get getRegDt => regDt;

  set setMemberSeq(int? value) {
    memberSeq = value;
    notifyListeners();
  }

  set setNickName(String? value) {
    nickName = value;
    notifyListeners();
  }

  set setDevice(String? value) {
    device = value;
    notifyListeners();
  }

  set setDeviceToken(String? value) {
    deviceToken = value;
    notifyListeners();
  }

  set setStatus(String? value) {
    status = value;
    notifyListeners();
  }

  set setRegDt(DateTime? value) {
    regDt = value;
    notifyListeners();
  }
}



