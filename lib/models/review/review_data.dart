class ReviewData {
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
  final List<Review> list;

  ReviewData({
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

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
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
      list: List<Review>.from(
        json['list'].map((item) => Review.fromJson(item)),
      ),
    );
  }
}

class Review {
  final int boardSeq;
  final String title;
  final String rank;
  final String period;
  final String atmosphere;
  final String content;
  final int memberSeq;
  int? level;
  final String nickname;
  final int viewCnt;
  int likeCnt = 0;
  bool isMyPress = false;
  final String hotYN;
  final String deleteYN;
  final DateTime regDt;

  Review({
    required this.boardSeq,
    required this.title,
    required this.rank,
    required this.period,
    required this.atmosphere,
    required this.content,
    required this.memberSeq,
    required this.nickname,
    required this.viewCnt,
    required this.likeCnt,
    required this.isMyPress,
    required this.hotYN,
    required this.deleteYN,
    required this.regDt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      boardSeq: json['boardSeq'],
      title: json['title'],
      rank: json['rank'],
      period: json['period'],
      atmosphere: json['atmosphere'],
      content: json['content'],
      memberSeq: json['memberSeq'],
      nickname: json['nickname'],
      viewCnt: json['viewCnt'],
      likeCnt: json['likeCnt'],
      isMyPress: json['isMyPress'],
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
