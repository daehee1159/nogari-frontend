import 'package:flutter/material.dart';
import 'package:nogari/models/community/community_data_dto.dart';
import 'package:nogari/services/community_service.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../../models/community/comment_dto.dart';
import '../../models/community/comment_provider.dart';
import '../../models/community/community_provider.dart';
import '../../models/member/member_info_provider.dart';
import '../../models/member/level_provider.dart';
import '../../models/member/point_history_provider.dart';
import '../common/custom.divider.dart';

class CommunityCommentWidget extends StatefulWidget {
  final Community communityDetail;
  final List<CommentDto> commentDtoList;

  const CommunityCommentWidget({required this.communityDetail, required this.commentDtoList, super.key});

  @override
  State<CommunityCommentWidget> createState() => _CommunityCommentWidgetState();
}

class _CommunityCommentWidgetState extends State<CommunityCommentWidget> {
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    commentController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CommunityService communityService = CommunityService();
    final MemberService memberService = MemberService();
    final CommonAlert commonAlert = CommonAlert();
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    CommentProvider commentProvider = Provider.of<CommentProvider>(context, listen: false);
    LevelProvider levelProvider = Provider.of<LevelProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomDivider(height: 3, color: Colors.grey),
            Container(
              color: Colors.grey.withOpacity(0.5),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.white,
                    width: double.infinity,
                    child: Text(
                      '닉네임 : Lv.${levelProvider.getLevel} ${memberInfoProvider.getNickName}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const CustomDivider(height: 1, color: Colors.grey),
                  Container(
                    height: MediaQueryData.fromView(View.of(context)).size.height * 0.15,
                    color: Colors.white,
                    child: TextField(
                      controller: commentController,
                      // textAlignVertical: TextAlignVertical(y: -0.5),
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        border: InputBorder.none
                      ),
                      onChanged: (value) {
                      },
                    ),
                  ),
                  const CustomDivider(height: 1, color: Colors.grey),
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      style: TextButton.styleFrom(

                      ),
                      onPressed: () async {
                        if (commentController.text.isEmpty || commentController.text == ' ') {
                          return commonAlert.spaceError(context, '내용');
                        }

                        int result = await communityService.setComment(widget.communityDetail.boardSeq, memberInfoProvider.getMemberSeq!, memberInfoProvider.getNickName!, commentController.text);

                        if (result != 0) {
                          // 성공했으면 provider 에 방금 데이터 넣어야함
                          CommentDto commentDto = CommentDto(
                              commentSeq: result, boardSeq: widget.communityDetail.boardSeq,
                              memberSeq: memberInfoProvider.getMemberSeq!, nickname: memberInfoProvider.getNickName!,
                              content: commentController.text,
                              deleteYN: 'N',
                              regDt: DateTime.now().toString());
                          commentProvider.addCommentList(commentDto);
                          communityProvider.addCntOfComment(widget.communityDetail.boardSeq);
                          commentController.text = '';

                          pointHistoryProvider.addCommunityComment();
                          if (pointHistoryProvider.getCommunityComment >= pointHistoryProvider.getTotalCommunityComment == false) {
                            await memberService.setPoint('COMMUNITY_COMMENT');
                          }

                          FocusManager.instance.primaryFocus?.unfocus();
                        } else {
                          // 실패
                          if (context.mounted) {
                            CommonAlert().errorAlert(context);
                          }
                        }
                      },
                      child: Text(
                        '등록',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
