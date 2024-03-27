import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nogari/models/man_hour/man_hour_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../models/global/global_variable.dart';
import '../models/man_hour/man_hour_column_chart.dart';

class ManHourService {
  /// 공수 캘린더 저장하기
  setManHour(List<ManHourDto> manHourDtoList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse(Glob.manHourUrl);

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> manHourListJson = ManHourDto.listToJson(manHourDtoList);

    final saveData = jsonEncode(manHourListJson);

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 공수 캘린더 불러오기
  getManHourList() async {
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

    List<ManHourDto> fetchData =((json.decode(response.body) as List).map((e) => ManHourDto.fromJson(e)).toList());

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

  /// 공수 캘린더 수정
  updateManHour(ManHourDto manHourDto) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.manHourUrl}/update');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode(manHourDto.toJson());

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  /// 공수 캘린더 삭제
  deleteManHour(List<ManHourDto> manHourDtoList) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    var memberSeq = pref.getInt(Glob.memberSeq);

    var url = Uri.parse('${Glob.manHourUrl}/delete');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };


    List<Map<String, dynamic>> manHourListJson = ManHourDto.listToJson(manHourDtoList);

    final saveData = jsonEncode(manHourListJson);

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }


  /// List<int> 에 담긴 월에 해당하는 숫자에 맞는 해당 월의 모든 일자 반환
  /// 이거 필요 없음
  List<DateTime> getDatesInMonth(int year, int month) {
    final startDate = DateTime(year, month + 1, 1); // 인덱스 1부터 시작하는 월로 조정
    final endDate = DateTime(year, month + 2, 0); // 다음 달의 0번째 날을 통해 이번 달의 마지막 날 가져오기

    final List<DateTime> datesInMonth = [];

    for (var i = startDate; i.isBefore(endDate) || i.isAtSameMomentAs(endDate); i = i.add(const Duration(days: 1))) {
      datesInMonth.add(i);
    }

    return datesInMonth;
  }

  /// 리스트에 있는 startDt.year 의 종류만 모아서 반환
  List<int> getYearsList(List<ManHourDto> manHourList) {
    Map<int, Set<int>> yearMap = {};

    manHourList.forEach((manHour) {
      int year = DateTime.parse(manHour.startDt.toString()).year;
      yearMap.putIfAbsent(year, () => Set<int>());
      yearMap[year]!.add(DateTime.parse(manHour.startDt.toString()).month); // 여기에서 month, day 등을 변경하여 필요한 종류에 따라 그룹화 가능
    });

    List<int> result = [];

    yearMap.forEach((year, months) {
      // 여기에서 필요한 처리를 수행하거나, 중복을 방지하고 결과 리스트에 추가할 수 있음
      result.add(year);
    });

    return result;
  }

  /// 차트 데이터를 위한 월별 데이터 변환
  List<ManHourColumnChart> convertToChartData(List<ManHourDto> manHourList) {
    Map<String, int> monthTotalMap = {};

    // 1월부터 12월까지 모든 월을 0으로 초기화
    for (int month = 1; month <= 12; month++) {
      String monthKey = '$month';
      monthTotalMap[monthKey] = 0;
    }

    // 월별 데이터 누적
    manHourList.forEach((manHour) {
      String monthKey = '${DateTime.parse(manHour.startDt).month}';
      monthTotalMap.update(
        monthKey,
            (value) => value + manHour.totalAmount.toInt(), // 적절한 프로퍼티로 변경
        ifAbsent: () => 0, // 적절한 프로퍼티로 변경
      );
    });

    // ManHourColumnChart 리스트로 변환
    List<ManHourColumnChart> result = monthTotalMap.entries
        .map((entry) => ManHourColumnChart(entry.key, entry.value))
        .toList();

    return result;
  }
}
