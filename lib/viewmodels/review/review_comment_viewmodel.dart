import 'package:flutter/material.dart';

import '../../models/review/review_child_comment.dart';
import '../../models/review/review_comment.dart';

class ReviewCommentViewModel extends ChangeNotifier {
  List<ReviewComment> reviewCommentList = [];
  List<ReviewChildComment> reviewChildCommentList = [];
  List<bool> isCommentList = [];
  int? openCommentIndex; // 열린 댓글의 인덱스
  int? openChildCommentIndex;


  List<ReviewComment> get getReviewCommentList => reviewCommentList;
  List<ReviewChildComment> get getReviewChildCommentList => reviewChildCommentList;

  set setReviewCommentList(List<ReviewComment> list) {
    reviewCommentList = list;
    isCommentList = List.generate(list.length, (index) => false);
    // 열린 댓글 인덱스 초기화
    openCommentIndex = null;
    // notifyListeners();
  }

  set setReviewChildCommentList(List<ReviewChildComment> list) {
    reviewChildCommentList = list;
    // notifyListeners();
  }

  bool hasChildComments(ReviewComment reviewComment) {
    return reviewChildCommentList.any((childCommentDto) => childCommentDto.commentSeq == reviewComment.commentSeq);
  }

  void addCommentList(ReviewComment reviewComment) {
    reviewCommentList.add(reviewComment);
    notifyListeners();
  }

  void addChildCommentList(ReviewChildComment reviewChildComment) {
    reviewChildCommentList.add(reviewChildComment);
    notifyListeners();
  }

  void callNotify() {
    notifyListeners();
  }

  void toggleComment(int? index) {
    if (openCommentIndex == index) {
      openCommentIndex = null;
    } else {
      openCommentIndex = index;
    }

    notifyListeners();
  }

  void toggleChildComment(int? index) {
    if (openChildCommentIndex == index) {
      openChildCommentIndex = null;
    } else {
      openChildCommentIndex = index;
    }
    notifyListeners();
  }

  void setOpenCommentIndex(int? index) {
    openCommentIndex = index;
    notifyListeners();
  }
}
