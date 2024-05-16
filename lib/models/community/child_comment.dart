class ChildComment {
  final int childCommentSeq;
  final int boardSeq;
  final int commentSeq;
  final int memberSeq;
  int? level;
  final String nickname;
  final String content;
  final String deleteYN;
  final String regDt;

  ChildComment(
      {required this.childCommentSeq,
        required this.boardSeq,
        required this.commentSeq,
        required this.memberSeq,
        required this.nickname,
        required this.content,
        required this.deleteYN,
        required this.regDt});

  factory ChildComment.fromJson(Map<String, dynamic> json) {
    return ChildComment(
      childCommentSeq : json['childCommentSeq'],
      boardSeq : json['boardSeq'],
      commentSeq : json['commentSeq'],
      memberSeq : json['memberSeq'],
      nickname : json['nickname'],
      content : json['content'],
      deleteYN : json['deleteYN'],
      regDt : json['regDt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['childCommentSeq'] = childCommentSeq;
    data['boardSeq'] = boardSeq;
    data['commentSeq'] = commentSeq;
    data['memberSeq'] = memberSeq;
    data['nickname'] = nickname;
    data['content'] = content;
    data['deleteYN'] = deleteYN;
    data['regDt'] = regDt;
    return data;
  }
}
