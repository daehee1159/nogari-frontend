import 'package:flutter/material.dart';
import 'package:nogari/models/community/comment.dart';
import 'package:nogari/models/community/community_data.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/viewmodels/community/comment_viewmodel.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/viewmodels/member/level_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../common/custom.divider.dart';

class CommunityCommentWidget extends StatefulWidget {
  final Community communityDetail;
  final List<Comment> commentList;

  const CommunityCommentWidget({required this.communityDetail, required this.commentList, super.key});

  @override
  State<CommunityCommentWidget> createState() => _CommunityCommentWidgetState();
}

class _CommunityCommentWidgetState extends State<CommunityCommentWidget> {
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
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
    final CommonAlert commonAlert = CommonAlert();
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final commentViewModel = Provider.of<CommentViewModel>(context, listen: false);
    final levelViewModel = Provider.of<LevelViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final pointHistoryViewModel = Provider.of<PointHistoryViewModel>(context, listen: false);

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
                      '닉네임 : Lv.${levelViewModel.getLevel} ${memberViewModel.getNickName}',
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

                        int result = await _communityRepository.setComment(widget.communityDetail.boardSeq, memberViewModel.getMemberSeq!, memberViewModel.getNickName!, commentController.text);

                        if (result != 0) {
                          // 성공했으면 provider 에 방금 데이터 넣어야함
                          Comment comment = Comment(
                              commentSeq: result, boardSeq: widget.communityDetail.boardSeq,
                              memberSeq: memberViewModel.getMemberSeq!, nickname: memberViewModel.getNickName!,
                              content: commentController.text,
                              deleteYN: 'N',
                              regDt: DateTime.now().toString());
                          commentViewModel.addCommentList(comment);
                          communityViewModel.addCntOfComment(widget.communityDetail.boardSeq);
                          commentController.text = '';

                          pointHistoryViewModel.addCommunityComment();
                          if (pointHistoryViewModel.getCommunityComment >= pointHistoryViewModel.getTotalCommunityComment == false) {
                            await _memberRepository.setPoint('COMMUNITY_COMMENT');
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
