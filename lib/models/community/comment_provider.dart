import 'package:flutter/material.dart';
import 'package:nogari/models/community/child_comment_dto.dart';

import 'comment_dto.dart';

/// 댓글과 대댓글은 함께 관리
class CommentProvider extends ChangeNotifier {
  List<CommentDto> commentList = [];
  List<ChildCommentDto> childCommentList = [];
  List<bool> isCommentList = [];
  int? openCommentIndex; // 열린 댓글의 인덱스
  int? openChildCommentIndex;


  List<CommentDto> get getCommentList => commentList;
  List<ChildCommentDto> get getChildCommentList => childCommentList;

  set setCommentList(List<CommentDto> list) {
    commentList = list;
    isCommentList = List.generate(list.length, (index) => false);
    // 열린 댓글 인덱스 초기화
    openCommentIndex = null;
    // notifyListeners();
  }

  set setChildCommentList(List<ChildCommentDto> list) {
    childCommentList = list;
    // notifyListeners();
  }

  bool hasChildComments(CommentDto commentDto) {
    return childCommentList.any((childCommentDto) => childCommentDto.commentSeq == commentDto.commentSeq);
  }

  void addCommentList(CommentDto commentDto) {
    commentList.add(commentDto);
    notifyListeners();
  }

  void addChildCommentList(ChildCommentDto childCommentDto) {
    childCommentList.add(childCommentDto);
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
