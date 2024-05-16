class CommunityData {
  final int pageNum;
  final int pageSize;
  final int size;
  final int startRow;
  final int endRow;
  final int pages;
  final int prePage;
  final int nextPage;
  final bool isFirstPage;
  final bool isLastPage;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final int navigatePages;
  final List<int> navigatePageNums;
  final int navigateFirstPage;
  final int navigateLastPage;
  final int total;
  final List<Community> list;

  CommunityData({
    required this.pageNum,
    required this.pageSize,
    required this.size,
    required this.startRow,
    required this.endRow,
    required this.pages,
    required this.prePage,
    required this.nextPage,
    required this.isFirstPage,
    required this.isLastPage,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.navigatePages,
    required this.navigatePageNums,
    required this.navigateFirstPage,
    required this.navigateLastPage,
    required this.total,
    required this.list,
  });

  factory CommunityData.fromJson(Map<String, dynamic> json) {
    return CommunityData(
      pageNum: json['pageNum'],
      pageSize: json['pageSize'],
      size: json['size'],
      startRow: json['startRow'],
      endRow: json['endRow'],
      pages: json['pages'],
      prePage: json['prePage'],
      nextPage: json['nextPage'],
      isFirstPage: json['isFirstPage'],
      isLastPage: json['isLastPage'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
      navigatePages: json['navigatePages'],
      navigatePageNums: List<int>.from(json['navigatepageNums']),
      navigateFirstPage: json['navigateFirstPage'],
      navigateLastPage: json['navigateLastPage'],
      total: json['total'],
      list: List<Community>.from(
        json['list'].map((item) => Community.fromJson(item)),
      ),
    );
  }
}

class Community {
  final int boardSeq;
  final String title;
  final String content;

  final String? fileName1;
  final String? fileName2;
  final String? fileName3;
  String? fileUrl1;
  String? fileUrl2;
  String? fileUrl3;

  final int memberSeq;
  int? level;
  final String nickname;
  final int viewCnt;
  int likeCnt = 0;
  bool isMyPress = false;
  final String hotYN;
  final String noticeYN;
  final String deleteYN;
  final DateTime regDt;

  Community({
    required this.boardSeq,
    required this.title,
    required this.content,
    required this.fileName1,
    required this.fileName2,
    required this.fileName3,
    required this.memberSeq,
    required this.nickname,
    required this.viewCnt,
    required this.likeCnt,
    required this.noticeYN,
    required this.hotYN,
    required this.deleteYN,
    required this.regDt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      boardSeq: json['boardSeq'],
      title: json['title'],
      content: json['content'],
      fileName1: json['fileName1'],
      fileName2: json['fileName2'],
      fileName3: json['fileName3'],
      memberSeq: json['memberSeq'],
      nickname: json['nickname'],
      viewCnt: json['viewCnt'],
      likeCnt: json['likeCnt'],
      noticeYN: json['noticeYN'],
      hotYN: json['hotYN'],
      deleteYN: json['deleteYN'],
      regDt: DateTime(
        json['regDt']['date']['year'],
        json['regDt']['date']['month'],
        json['regDt']['date']['day'],
        json['regDt']['time']['hour'],
        json['regDt']['time']['minute'],
        json['regDt']['time']['second'],
        json['regDt']['time']['nano'],
      ),
    );
  }
}
