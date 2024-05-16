import 'package:flutter/material.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/viewmodels/member/block_viewmodel.dart';
import 'package:nogari/widgets/member/member_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/member/block.dart';

class BlockDropdownWidget extends StatefulWidget {
  final int level;
  final String nickname;
  final int memberSeq;
  const BlockDropdownWidget({required this.level, required this.nickname, required this.memberSeq, super.key});

  @override
  State<BlockDropdownWidget> createState() => _BlockDropdownWidgetState();
}

class _BlockDropdownWidgetState extends State<BlockDropdownWidget> {
  String selectedOption = '차단하기';
  GlobalKey actionKey = GlobalKey();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  MemberAlert memberAlert = MemberAlert();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: actionKey,
      onTap: () {
        _showDropdownMenu(context);
      },
      child: Text(
        'Lv.${widget.level} ${widget.nickname}',
        style: Theme.of(context).textTheme.bodyMedium,
      )
    );
  }

  void _showDropdownMenu(BuildContext context) async {
    final BlockViewModel blockViewModel = Provider.of<BlockViewModel>(context, listen: false);
    final RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    final List<String> options = blockViewModel.isBlocked(widget.memberSeq) ? ['차단해제'] : ['차단하기'];

    var offset = renderBox.localToGlobal(Offset.zero);
    var rect = Rect.fromPoints(offset, offset.translate(renderBox.size.width, renderBox.size.height));

    String? result = await showMenu(
      context: context,
      position: RelativeRect.fromRect(rect, Offset(-MediaQuery.of(context).size.width * 0.09, -MediaQuery.of(context).size.height * 0.03) & MediaQuery.of(context).size),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(option),
        );
      }).toList(),
    );

    if (result != null) {
      // 여기서 차단 api 호출하면 될듯
      SharedPreferences pref = await SharedPreferences.getInstance();
      var memberSeq = pref.getInt(Glob.memberSeq);

      if (blockViewModel.isBlocked(widget.memberSeq)) {
        // 차단된 경우 해제
        List<Block> blockList = [];
        Block block = Block(
          blockSeq: 0,
          memberSeq: memberSeq!, blockMemberSeq: widget.memberSeq,
          blockMemberNickname: '',
          regDt: ''
        );
        blockList.add(block);
        bool result = await _memberRepository.deleteBlockMember(blockList);

        if (result) {
          blockViewModel.removeBlockList(block);
          if (mounted) {
            memberAlert.successUnBlockMember(context);
          }
        }

      } else {
        // 차단
        int result = await _memberRepository.blockMember(widget.memberSeq);

        if (result != 0) {
          Block block = Block(
            blockSeq: result,
            memberSeq: memberSeq!, blockMemberSeq: widget.memberSeq,
            blockMemberNickname: widget.nickname,
            regDt: ''
          );
          blockViewModel.addBlockDtoList(block);
          if (mounted) {
            memberAlert.successBlockMember(context);
          }
        }
      }
      // setState(() {
      //   selectedOption = result;
      // });
    }
  }
}
