class PointHistoryDto {
  late int pointHistorySeq;
  late int memberSeq;
  late int point;
  late String? pointHistory;
  late String historyComment;
  late String? resultComment;
  late String? regDt;

  PointHistoryDto({
    required this.pointHistorySeq,
    required this.memberSeq,
    required this.point,
    required this.pointHistory,
    required this.historyComment,
    required this.resultComment,
    required this.regDt
  });

  PointHistoryDto.fromJson(Map<String, dynamic> json) {
    pointHistorySeq = json['pointHistorySeq'];
    memberSeq = json['memberSeq'];
    point = json['point'];
    pointHistory = json['pointHistory'];
    historyComment = json['historyComment'];
    resultComment = json['resultComment'];
    regDt = json['regDt'];
  }
}
