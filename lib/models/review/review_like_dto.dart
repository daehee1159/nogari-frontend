class ReviewLikeDto {
  int? boardLikeSeq;
  int? boardSeq;
  int? memberSeq;
  String? regDt;

  ReviewLikeDto(
      {this.boardLikeSeq, this.boardSeq, this.memberSeq, this.regDt});

  ReviewLikeDto.fromJson(Map<String, dynamic> json) {
    boardLikeSeq = json['boardLikeSeq'];
    boardSeq = json['boardSeq'];
    memberSeq = json['memberSeq'];
    regDt = json['regDt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['boardLikeSeq'] = boardLikeSeq;
    data['boardSeq'] = boardSeq;
    data['memberSeq'] = memberSeq;
    data['regDt'] = regDt;
    return data;
  }
}
