class Block {
  final int blockSeq;

  final int memberSeq;
  final int blockMemberSeq;
  final String blockMemberNickname;

  final String regDt;

  Block(
      {required this.blockSeq,
        required this.memberSeq,
        required this.blockMemberSeq,
        required this.blockMemberNickname,
        required this.regDt});

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
        blockSeq : json['blockSeq'],
        memberSeq : json['memberSeq'],
        blockMemberSeq : json['blockMemberSeq'],
        blockMemberNickname : json['blockMemberNickname'],
        regDt : json['regDt']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['blockSeq'] = blockSeq;
    data['memberSeq'] = memberSeq;
    data['blockMemberSeq'] = blockMemberSeq;
    data['blockMemberNickname'] = blockMemberNickname;
    data['regDt'] = regDt;
    return data;
  }

  static List<Map<String, dynamic>> listToJson(List<Block> manHourList) {
    return manHourList.map((manHourDto) => manHourDto.toJson()).toList();
  }
}
