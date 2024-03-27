import 'package:flutter/material.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/member/member_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/member/block_dto.dart';
import '../../models/member/block_provider.dart';

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
  MemberService memberService = MemberService();
  MemberAlert memberAlert = MemberAlert();

  @override
  Widget build(BuildContext context) {

    print('데이터 테스트');
    print(widget.level);
    print(widget.nickname);
    print(widget.memberSeq);

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

    BlockProvider blockProvider = Provider.of<BlockProvider>(context, listen: false);
    final RenderBox renderBox = actionKey.currentContext!.findRenderObject() as RenderBox;
    final List<String> options = blockProvider.isBlocked(widget.memberSeq) ? ['차단해제'] : ['차단하기'];

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

      if (blockProvider.isBlocked(widget.memberSeq)) {
        // 차단된 경우 해제
        List<BlockDto> blockDtoList = [];
        BlockDto blockDto = BlockDto(
          blockSeq: 0,
          memberSeq: memberSeq!, blockMemberSeq: widget.memberSeq,
          blockMemberNickname: '',
          regDt: ''
        );
        blockDtoList.add(blockDto);
        bool result = await memberService.deleteBlockMember(blockDtoList);

        if (result) {
          blockProvider.removeBlockList(blockDto);
          if (mounted) {
            memberAlert.successUnBlockMember(context);
          }
        }

      } else {
        // 차단
        int result = await memberService.blockMember(widget.memberSeq);

        if (result != 0) {
          BlockDto blockDto = BlockDto(
            blockSeq: result,
            memberSeq: memberSeq!, blockMemberSeq: widget.memberSeq,
            blockMemberNickname: widget.nickname,
            regDt: ''
          );
          blockProvider.addBlockDtoList(blockDto);
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
