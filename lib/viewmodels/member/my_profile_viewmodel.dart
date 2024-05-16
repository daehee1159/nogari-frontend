import 'package:flutter/material.dart';
import 'package:nogari/services/common_service.dart';

import '../../enums/rank.dart';

class MyProfileViewModel extends ChangeNotifier {
  final CommonService _commonService = CommonService();

  String? nickName;
  String get getNickName => nickName.toString();
  set setNickName(value) {
    nickName = value;
    notifyListeners();
  }

  String? email;
  String get getEmail => email.toString();
  set setEmail(value) {
    email = value;
    notifyListeners();
  }

  Rank? rank;
  Rank get getRank => rank!;
  set setRank(value) {
    // 여기서 들어오는 value 는 snake 이기 때문에 pascal로 변경해줘야함
    String snakeToPascal = _commonService.snakeToPascalCase(value);

    Rank result = getRankFromString(snakeToPascal);
    rank = result;
    notifyListeners();
  }

  String? deviceToken;
  String get getDeviceToken => deviceToken.toString();
  set setDeviceToken(value) {
    deviceToken = value;
    notifyListeners();
  }
}
