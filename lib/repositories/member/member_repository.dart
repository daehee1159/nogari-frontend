import 'dart:io';
import 'dart:convert';

import 'package:nogari/models/member/block.dart';
import 'package:nogari/models/member/notification_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/member/level.dart';
import '../../models/member/member_info.dart';
import '../../models/member/point_history.dart';

abstract class MemberRepository {
  // 로그인 체크 (앱에 처음 접속했을 때 이미 가입한 회원인지 판단)
  Future<bool> loginCheck();
  Future<int> getMemberSeqByEmail(String email);
  // 회원가입 여부 체크
  Future<String> getMemberStatus(String email, String device, String? identifier);
  // email or nickName 중복 체크
  Future<bool> isDuplicate(String type, String value);
  // 회원가입
  // 성공 return int (memberSeq)
  // 실패 return false
  Future<dynamic> memberRegistration(String nickName, String device);
  // device token
  Future<String> getDeviceToken();
  // device token update
  Future<bool> changeDeviceToken(String email);
  // get member info
  Future<MemberInfo> getMemberInfo(int memberSeq);
  Future<List<NotificationData>> getNotification();
  Future<Level> getLevelAndPoint(int memberSeq);
  Future<bool> updateNickName(String nickName);
  Future<List<PointHistory>> getPointHistoryToday();

  // Future<bool> setAttendance();
  Future<bool> setPoint(String type);

  Future<bool> withdrawalMember(String reasonMessage);

  Future<List<Block>> getBlockMember();
  Future<int> blockMember(int blockMemberSeq);
  Future<bool> deleteBlockMember(List<Block> blockList);

}
