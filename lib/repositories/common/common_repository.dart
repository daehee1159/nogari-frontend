import 'package:flutter/material.dart';

import '../../enums/board_type.dart';
import '../../enums/report_reason.dart';
import '../../models/common/app_version.dart';
import '../../models/common/news.dart';
import '../../models/man_hour/tax_info.dart';

abstract class CommonRepository {
  // 앱 버전 가져오기
  Future<AppVersion> getAppVersion();
  Future<bool> fetchData(BuildContext context);
  // 네이버 뉴스 데이터 가져오기
  Future<List<News>> getNews();
  // 세금 정보 가져오기
  Future<TaxInfo> getTaxInfo(String standardDt);
  // 게시글 신고하기
  Future<bool> reportBoard(BoardType boardType, int boardSeq, ReportReason reportReason, int reportedMemberSeq);
}
