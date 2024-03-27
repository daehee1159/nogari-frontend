class CommentDto {
  final int commentSeq;
  final int boardSeq;
  final int memberSeq;
  int? level;
  final String nickname;
  final String content;
  final String deleteYN;
  final String regDt;

  CommentDto(
      {required this.commentSeq,
        required this.boardSeq,
        required this.memberSeq,
        required this.nickname,
        required this.content,
        required this.deleteYN,
        required this.regDt});

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      commentSeq: json['commentSeq'],
      boardSeq: json['boardSeq'],
      memberSeq: json['memberSeq'],
      nickname: json['nickname'],
      content: json['content'],
      deleteYN: json['deleteYN'],
      regDt: json['regDt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['commentSeq'] = commentSeq;
    data['boardSeq'] = boardSeq;
    data['memberSeq'] = memberSeq;
    data['nickname'] = nickname;
    data['content'] = content;
    data['deleteYN'] = deleteYN;
    data['regDt'] = regDt;
    return data;
  }
}
