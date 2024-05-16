import 'package:flutter/material.dart';
import 'package:nogari/models/community/comment.dart';

import '../../models/community/child_comment.dart';

class CommentViewModel extends ChangeNotifier {
  List<Comment> commentList = [];
  List<ChildComment> childCommentList = [];
  List<bool> isCommentList = [];
  int? openCommentIndex; // 열린 댓글의 인덱스
  int? openChildCommentIndex;


  List<Comment> get getCommentList => commentList;
  List<ChildComment> get getChildCommentList => childCommentList;

  set setCommentList(List<Comment> list) {
    commentList = list;
    isCommentList = List.generate(list.length, (index) => false);
    // 열린 댓글 인덱스 초기화
    openCommentIndex = null;
    // notifyListeners();
  }

  set setChildCommentList(List<ChildComment> list) {
    childCommentList = list;
    // notifyListeners();
  }

  bool hasChildComments(Comment comment) {
    return childCommentList.any((childCommentDto) => childCommentDto.commentSeq == comment.commentSeq);
  }

  void addCommentList(Comment comment) {
    commentList.add(comment);
    notifyListeners();
  }

  void addChildCommentList(ChildComment childComment) {
    childCommentList.add(childComment);
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
