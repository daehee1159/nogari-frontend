import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nogari/models/member/member_info_dto.dart';
import 'package:nogari/models/member/point_history_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/global/global_variable.dart';
import '../models/member/block_dto.dart';
import '../models/member/member_dto.dart';
import '../models/member/notification_dto.dart';

class MemberService {
  // 로그인 체크 (앱에 처음 들어왔을 때 이미 가입한 회원인지 아닌지 확인)
  Future<bool> loginCheck() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool? result = pref.getBool(Glob.registration);
    String username = pref.getString(Glob.email).toString();

    if (result == null || result == false) {
      return false;
    } else {
      var url = Uri.parse(Glob.accessTokenUrl);

      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      final postData = jsonEncode({
        "username": username,
        "password": username,
      });

      http.Response response = await http.post(
          url,
          headers: headers,
          body: postData
      );

      Jwt jwt = Jwt.fromJson(jsonDecode(response.body));

      // accessToken set
      var accessToken = jwt.author.accessToken;
      pref.setString(Glob.accessToken, accessToken);

      // refreshToken set
      var refreshToken = jwt.author.refreshToken;
      pref.setString(Glob.refreshToken, refreshToken);

      return true;
    }
  }

  getMemberSeqByEmail(String email) async {
    var url = Uri.parse('${Glob.memberUrl}/email');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      "email" : email,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  // 회원 가입 여부 체크 (회원가입 진행시 사용됨)
  getMemberStatus(String email, String device, String? identifier) async {
    var url = Uri.parse('${Glob.memberUrl}/status');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      "email" : email,
      "device" : device,
      "identifier": identifier
    });

    http.Response response = await http.post(
      url,
      headers: headers,
      body: saveData
    );

    return jsonDecode(response.body);
  }

  // email or nickName 중복 체크
  // return bool
  isDuplicate(String type, String value) async {
    final Uri uri = Uri.parse('${Glob.memberUrl}/check?type=$type&value=$value');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  updateDeviceToken(int memberSeq) async {
    var url = Uri.parse('${Glob.memberUrl}/device');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      "memberSeq" : memberSeq,
      "device" : Platform.isIOS ? 'iOS' : 'Android',
    });

    http.Response response = await http.patch(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  Future<bool> setMemberSeq(int memberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt(Glob.memberSeq, memberSeq);
    if (pref.getInt(Glob.memberSeq) == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> setEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Glob.email, email);
    if (pref.getString(Glob.email) == null) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> setIdentifier(String identifier) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(Glob.identifier, identifier);
    if (pref.getString(Glob.identifier) == null) {
      return false;
    } else {
      return true;
    }
  }

  memberRegistration(String nickName, String device) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String email = pref.getString(Glob.email).toString();
    String? identifier;
    if (device == 'iOS') {
      identifier = pref.getString(Glob.identifier).toString();
    } else {
      identifier = null;
    }

    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

    String? tokenData = await FirebaseMessaging.instance.getToken();
    if (tokenData == null) {
      tokenData = null;
    }

    var url = Uri.parse(Glob.memberUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      "email" : email,
      "nickName" : nickName,
      "device" : device,
      "identifier": identifier,
      "deviceToken" : tokenData,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);

  }

  registrationPref(int memberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(Glob.registration, true);
    pref.setInt(Glob.memberSeq, memberSeq);

    // 가입 시 해당 device token 저장
    FirebaseMessaging.instance.getToken().then((value) {
      String? token = value;

      if (token == null) {
        // print("토큰 없음");
      }
      pref.setString("deviceToken", token!);
      pref.setBool("setDevice", true);
    });
  }

  getDeviceToken() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/check/token/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );

    return jsonDecode(response.body).toString();
  }

  changeDeviceToken(String email) async {
    String? tokenData = await FirebaseMessaging.instance.getToken();
    if (tokenData == null) {
      return false;
    }

    var url = Uri.parse('${Glob.memberUrl}/device');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'email' : email,
      'device': Platform.isIOS ? 'iOS' : 'Android',
      'deviceToken' : tokenData,
    });

    http.Response response = await http.patch(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  getMemberInfo(int memberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/info/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    Map<String, dynamic> responseData = jsonDecode(response.body);

    MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(responseData);

    return jsonDecode(response.body);
  }

  getNotification() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/notification/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );
    List<NotificationDto> fetchData =((json.decode(response.body) as List).map((e) => NotificationDto.fromJson(e)).toList());
    return fetchData;
  }

  getLevelAndPoint(int memberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/point/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );

    return jsonDecode(response.body);
  }

  updateNickName(String nickName) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/nickname');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      "memberSeq" : memberSeq,
      "nickName" : nickName,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  getPointHistoryToday() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/point/history/today/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );

    List<PointHistoryDto> fetchData =((json.decode(response.body) as List).map((e) => PointHistoryDto.fromJson(e)).toList());

    return fetchData;
  }

  setAttendance() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/point');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'memberSeq' : memberSeq,
      'pointHistory' : 'ATTENDANCE',
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  setPoint(String type) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/point');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'memberSeq' : memberSeq,
      'pointHistory' : type,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  withdrawalMember(String reasonMessage) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse(Glob.memberUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'memberSeq' : memberSeq,
      'reasonMessage' : reasonMessage,
    });

    http.Response response = await http.delete(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  getBlockMember() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());

    final Uri uri = Uri.parse('${Glob.memberUrl}/block/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<BlockDto> result =((json.decode(response.body) as List).map((e) => BlockDto.fromJson(e)).toList());

    return result;
  }

  blockMember(int blockMemberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var accessToken = pref.getString(Glob.accessToken);

    var url = Uri.parse('${Glob.memberUrl}/block');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'memberSeq' : memberSeq,
      'blockMemberSeq' : blockMemberSeq,
    });

    http.Response response = await http.post(
      url,
      headers: headers,
      body: saveData
    );

    return jsonDecode(response.body);
  }

  deleteBlockMember(List<BlockDto> blockDtoList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.memberUrl}/block');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> blockDtoListJson = BlockDto.listToJson(blockDtoList);

    final saveData = jsonEncode(blockDtoListJson);

    http.Response response = await http.delete(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }


  withdrawalMemberPref() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    try {
      pref.remove(Glob.email);
      pref.remove(Glob.memberSeq);
      pref.setBool(Glob.registration, false);

      return true;
    } catch(e) {
      return false;
    }
  }
}
