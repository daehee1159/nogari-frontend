class Level {
  late int levelSeq;
  late int memberSeq;
  late int level;
  late int point;

  Level({
    required this.levelSeq,
    required this.memberSeq,
    required this.level,
    required this.point
  });

  Level.fromJson(Map<String, dynamic> json) {
    levelSeq = json['levelSeq'];
    memberSeq = json['memberSeq'];
    level = json['level'];
    point = json['point'];
  }
}
