import 'package:nogari/enums/rank.dart';

class LevelDto {
  late int levelSeq;
  late int memberSeq;
  late int level;
  late int point;

  LevelDto({
    required this.levelSeq,
    required this.memberSeq,
    required this.level,
    required this.point
  });

  LevelDto.fromJson(Map<String, dynamic> json) {
    levelSeq = json['levelSeq'];
    memberSeq = json['memberSeq'];
    level = json['level'];
    point = json['point'];
  }
}
