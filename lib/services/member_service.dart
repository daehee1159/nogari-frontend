import 'dart:io';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/global/global_variable.dart';

class MemberService {
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
