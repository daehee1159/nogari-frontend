class ReportBoardDto {
  final int reportSeq;

  final String boardType;
  final int boardSeq;
  final String reportReason;

  final int reporterMemberSeq;
  final int reportedMemberSeq;
  final String regDt;

  ReportBoardDto(
      {required this.reportSeq,
        required this.boardType,
        required this.boardSeq,
        required this.reportReason,
        required this.reporterMemberSeq,
        required this.reportedMemberSeq,
        required this.regDt});

  factory ReportBoardDto.fromJson(Map<String, dynamic> json) {
    return ReportBoardDto(
        reportSeq : json['reportSeq'],
        boardType : json['boardType'],
        boardSeq : json['boardSeq'],
        reportReason : json['reportReason'],
        reporterMemberSeq : json['reporterMemberSeq'],
        reportedMemberSeq : json['reportedMemberSeq'],
        regDt : json['regDt']
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reportSeq'] = reportSeq;
    data['boardType'] = boardType;
    data['boardSeq'] = boardSeq;
    data['reportReason'] = reportReason;
    data['reporterMemberSeq'] = reporterMemberSeq;
    data['reportedMemberSeq'] = reportedMemberSeq;
    data['regDt'] = regDt;
    return data;
  }
}
