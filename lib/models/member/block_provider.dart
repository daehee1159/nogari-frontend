import 'package:flutter/material.dart';

import 'block_dto.dart';

class BlockProvider extends ChangeNotifier {
  List<BlockDto> blockDtoList = [];
  Set<int> selectedItems = <int>{};

  get getBlockDtoList => blockDtoList;

  set setBlockDtoList(List<BlockDto> list) {
    blockDtoList = list;
    notifyListeners();
  }

  void addBlockDtoList(BlockDto blockDto) {
    blockDtoList.add(blockDto);
    notifyListeners();
  }

  bool isBlocked(int blockMemberSeq) {
    return blockDtoList.any((dto) => dto.blockMemberSeq == blockMemberSeq);
  }

  void removeBlockList(BlockDto blockDto) {
    blockDtoList.removeWhere((dto) => dto.memberSeq == blockDto.memberSeq && dto.blockMemberSeq == blockDto.blockMemberSeq);
    notifyListeners();
  }

  void callNotify() {
    notifyListeners();
  }
}
