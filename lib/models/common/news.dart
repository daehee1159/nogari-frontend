class News {
  final String title;
  final String originallink;
  final String link;
  final String description;
  final String pubDate;
  final String imgUrl;
  final String regDt;

  News(
      {required this.title,
        required this.originallink,
        required this.link,
        required this.description,
        required this.pubDate,
        required this.imgUrl,
        required this.regDt});

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
        title : json['title'],
        originallink : json['originallink'],
        link : json['link'],
        description : json['description'],
        pubDate : json['pubDate'],
        imgUrl : json['imgUrl'],
        regDt : json['regDt']
    );

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['title'] = title;
    data['originallink'] = originallink;
    data['link'] = link;
    data['description'] = description;
    data['pubDate'] = pubDate;
    data['imgUrl'] = imgUrl;
    data['regDt'] = regDt;
    return data;
  }
}
