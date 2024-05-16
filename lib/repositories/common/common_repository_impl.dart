import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:nogari/repositories/common/common_repository.dart';

import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../enums/board_type.dart';
import '../../enums/report_reason.dart';
import '../../models/common/app_version.dart';
import '../../models/common/news.dart';
import '../../models/global/global_variable.dart';
import '../../models/man_hour/tax_info.dart';

class CommonRepositoryImpl implements CommonRepository {

  @override
  Future<AppVersion> getAppVersion() async {
    var url = Uri.parse('${Glob.commonUrl}/app/version');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      url,
      headers: headers,
    );

    AppVersion appVersion = AppVersion.fromJson(jsonDecode(response.body));

    return appVersion;
  }

  @override
  Future<bool> fetchData(BuildContext context) {
    Future<bool> result = true as Future<bool>;
    return result;
  }

  @override
  Future<List<News>> getNews() async {
    final Uri uri = Uri.parse('${Glob.commonUrl}/data/news');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<News> fetchData =((json.decode(response.body) as List).map((e) => News.fromJson(e)).toList());

    return fetchData;
  }

  @override
  Future<TaxInfo> getTaxInfo(String standardDt) async {
    final Uri uri = Uri.parse('${Glob.commonUrl}/tax/$standardDt');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    TaxInfo taxInfoDto = TaxInfo.fromJson(json.decode(response.body));

    return taxInfoDto;
  }

  @override
  Future<bool> reportBoard(BoardType boardType, int boardSeq, ReportReason reportReason, int reportedMemberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var url = Uri.parse('${Glob.commonUrl}/report');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var saveData = jsonEncode({
      'boardType': ReCase(boardType.toString().split('.').last).constantCase,
      'boardSeq': boardSeq,
      'reportReason': ReCase(reportReason.toString().split('.').last).constantCase,
      'reporterMemberSeq': memberSeq,
      'reportedMemberSeq': reportedMemberSeq,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }
}
