import 'package:flutter/material.dart';

import '../../models/member/point_history.dart';

class PointHistoryViewModel extends ChangeNotifier {
  List<PointHistory> pointHistoryList = [];

  // 남은 갯수
  int attendance = 0;
  int communityWriting = 0;
  int reviewWriting = 0;
  int communityComment = 0;
  int reviewComment = 0;
  int watch5SecAd = 0;
  int watch30SecAd = 0;

  // 전체 갯수(
  int totalAttendance = 1;
  int totalCommunityWriting = 3;
  int totalReviewWriting = 3;
  int totalCommunityComment = 5;
  int totalReviewComment = 5;
  int totalWatch5SecAd = 5;
  int totalWatch30SecAd = 3;

  get getPointHistoryList => pointHistoryList;
  get getAttendance => attendance;
  get getCommunityWriting => communityWriting;
  get getReviewWriting => reviewWriting;
  get getCommunityComment => communityComment;
  get getReviewComment => reviewComment;
  get getWatch5SecAd => watch5SecAd;
  get getWatch30SecAd => watch30SecAd;

  get getTotalAttendance => totalAttendance;
  get getTotalCommunityWriting => totalCommunityWriting;
  get getTotalReviewWriting => totalReviewWriting;
  get getTotalCommunityComment => totalCommunityComment;
  get getTotalReviewComment => totalReviewComment;
  get getTotalWatch5SecAd => totalWatch5SecAd;
  get getTotalWatch30SecAd => totalWatch30SecAd;

  set setPointHistoryList(List<PointHistory> list) {
    pointHistoryList = list;
    notifyListeners();
  }
  addAttendance() {
    attendance = attendance +1;
    notifyListeners();
  }
  addCommunityWriting() {
    communityWriting = communityWriting +1;
    notifyListeners();
  }
  addReviewWriting() {
    reviewWriting = reviewWriting +1;
    notifyListeners();
  }
  addCommunityComment() {
    communityComment = communityComment +1;
    notifyListeners();
  }
  addReviewComment() {
    reviewComment = reviewComment +1;
    notifyListeners();
  }
  addWatch5SecAd() {
    watch5SecAd = watch5SecAd +1;
    notifyListeners();
  }
  addWatch30SecAd() {
    watch30SecAd = watch30SecAd +1;
    notifyListeners();
  }
}
