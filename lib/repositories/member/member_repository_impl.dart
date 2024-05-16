import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nogari/models/member/notification_data.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/global/global_variable.dart';
import '../../models/member/block.dart';
import '../../models/member/level.dart';
import '../../models/member/member.dart';
import '../../models/member/member_info.dart';
import '../../models/member/point_history.dart';

class MemberRepositoryImpl implements MemberRepository {
  @override
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

  @override
  Future<int> getMemberSeqByEmail(String email) async {
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

  @override
  Future<String> getMemberStatus(String email, String device, String? identifier) async {
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

  @override
  Future<bool> isDuplicate(String type, String value) async {
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

  @override
  Future<dynamic> memberRegistration(String nickName, String device) async {
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

  @override
  Future<String> getDeviceToken() async {
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

  @override
  Future<bool> changeDeviceToken(String email) async {
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

  @override
  Future<MemberInfo> getMemberInfo(int memberSeq) async {
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

    MemberInfo memberInfo = MemberInfo.fromJson(responseData);

    return memberInfo;
  }

  @override
  Future<List<NotificationData>> getNotification() async {
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
    List<NotificationData> fetchData =((json.decode(response.body) as List).map((e) => NotificationData.fromJson(e)).toList());
    return fetchData;
  }

  @override
  Future<Level> getLevelAndPoint(int memberSeq) async {
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

    Level level = Level.fromJson(jsonDecode(response.body));

    return level;
  }

  @override
  Future<bool> updateNickName(String nickName) async {
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

  @override
  Future<List<PointHistory>> getPointHistoryToday() async {
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

    List<PointHistory> fetchData =((json.decode(response.body) as List).map((e) => PointHistory.fromJson(e)).toList());

    return fetchData;
  }

  @override
  Future<bool> setPoint(String type) async {
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

  @override
  Future<bool> withdrawalMember(String reasonMessage) async {
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

  @override
  Future<List<Block>> getBlockMember() async {
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

    List<Block> result =((json.decode(response.body) as List).map((e) => Block.fromJson(e)).toList());

    return result;
  }

  @override
  Future<int> blockMember(int blockMemberSeq) async {
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

  @override
  Future<bool> deleteBlockMember(List<Block> blockList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.memberUrl}/block');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> blockDtoListJson = Block.listToJson(blockList);

    final saveData = jsonEncode(blockDtoListJson);

    http.Response response = await http.delete(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }
}
