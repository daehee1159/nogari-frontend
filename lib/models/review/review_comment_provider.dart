import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_child_comment_dto.dart';
import 'package:nogari/models/review/review_comment_dto.dart';

class ReviewCommentProvider extends ChangeNotifier {
  List<ReviewCommentDto> reviewCommentList = [];
  List<ReviewChildCommentDto> reviewChildCommentList = [];
  List<bool> isCommentList = [];
  int? openCommentIndex; // 열린 댓글의 인덱스
  int? openChildCommentIndex;


  List<ReviewCommentDto> get getReviewCommentList => reviewCommentList;
  List<ReviewChildCommentDto> get getReviewChildCommentList => reviewChildCommentList;

  set setReviewCommentList(List<ReviewCommentDto> list) {
    reviewCommentList = list;
    isCommentList = List.generate(list.length, (index) => false);
    // 열린 댓글 인덱스 초기화
    openCommentIndex = null;
    // notifyListeners();
  }

  set setReviewChildCommentList(List<ReviewChildCommentDto> list) {
    reviewChildCommentList = list;
    // notifyListeners();
  }

  bool hasChildComments(ReviewCommentDto reviewCommentDto) {
    return reviewChildCommentList.any((childCommentDto) => childCommentDto.commentSeq == reviewCommentDto.commentSeq);
  }

  void addCommentList(ReviewCommentDto reviewCommentDto) {
    reviewCommentList.add(reviewCommentDto);
    notifyListeners();
  }

  void addChildCommentList(ReviewChildCommentDto reviewChildCommentDto) {
    reviewChildCommentList.add(reviewChildCommentDto);
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
