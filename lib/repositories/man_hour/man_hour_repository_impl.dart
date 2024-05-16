import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour.dart';

class ManHourRepositoryImpl implements ManHourRepository {
  @override
  Future<bool> setManHour(List<ManHour> manHourList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse(Glob.manHourUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> manHourListJson = ManHour.listToJson(manHourList);

    final saveData = jsonEncode(manHourListJson);

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  @override
  Future<List<ManHour>> getManHourList() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);
    final Uri uri = Uri.parse('${Glob.manHourUrl}/$memberSeq');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<ManHour> fetchData =((json.decode(response.body) as List).map((e) => ManHour.fromJson(e)).toList());

    for (int i = 0; i < fetchData.length; i++) {
      if (fetchData[i].isHoliday == 'Y') {
        fetchData[i] = fetchData[i].copyWith(
            textStyle: const TextStyle(color: Colors.red, fontSize: 7, fontFamily: 'NotoSansKR-Regular'),
            backGroundColor: Colors.transparent
        );
      }
    }

    return fetchData;
  }

  @override
  Future<bool> updateManHour(ManHour manHour) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.manHourUrl}/update');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode(manHour.toJson());

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  @override
  Future<bool> deleteManHour(List<ManHour> manHourList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.manHourUrl}/delete');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };


    List<Map<String, dynamic>> manHourListJson = ManHour.listToJson(manHourList);

    final saveData = jsonEncode(manHourListJson);

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }
}
