import 'package:flutter/material.dart';

import '../../models/member/block.dart';

class BlockViewModel extends ChangeNotifier {
  List<Block> blockDtoList = [];
  Set<int> selectedItems = <int>{};

  get getBlockDtoList => blockDtoList;

  set setBlockDtoList(List<Block> list) {
    blockDtoList = list;
    notifyListeners();
  }

  void addBlockDtoList(Block block) {
    blockDtoList.add(block);
    notifyListeners();
  }

  bool isBlocked(int blockMemberSeq) {
    return blockDtoList.any((dto) => dto.blockMemberSeq == blockMemberSeq);
  }

  void removeBlockList(Block block) {
    blockDtoList.removeWhere((dto) => dto.memberSeq == block.memberSeq && dto.blockMemberSeq == block.blockMemberSeq);
    notifyListeners();
  }

  void callNotify() {
    notifyListeners();
  }
}
