import 'dart:convert';

class MemberInfoDto {
  late int memberSeq;
  late String email;
  late String password;
  late String nickName;
  late String device;
  late String deviceToken;
  late String status;
  late String userRole;
  late DateTime regDt;

  MemberInfoDto.fromJson(Map<String, dynamic> json) {
    memberSeq = json['memberSeq'];
    email = json['email'];
    password = json['password'];
    nickName = json['nickName'];
    device = json['device'];
    deviceToken = json['deviceToken'];
    status = json['status'];
    userRole = json['userRole'];

    // 직접 regDt를 처리
    final date = json['regDt']['date'];
    final time = json['regDt']['time'];
    regDt = DateTime(
      date['year'],
      date['month'],
      date['day'],
      time['hour'],
      time['minute'],
      time['second'],
      time['nano'],
    );
  }
}
