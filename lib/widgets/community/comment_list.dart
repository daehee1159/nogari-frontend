import 'package:flutter/material.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/report_button.dart';
import 'package:nogari/widgets/community/community_alert.dart';
import 'package:provider/provider.dart';

import '../../enums/board_type.dart';
import '../../models/community/child_comment_dto.dart';
import '../../models/community/comment_provider.dart';
import '../../models/member/member_info_provider.dart';
import '../../models/member/point_history_provider.dart';
import '../../services/community_service.dart';
import '../common/block_dropdown_widget.dart';
import '../common/custom.divider.dart';

class CommentList extends StatefulWidget {
  const CommentList({super.key});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {

  @override
  Widget build(BuildContext context) {
    final CommunityService communityService = CommunityService();
    final CommunityAlert communityAlert = CommunityAlert();
    final MemberService memberService = MemberService();
    final CommonAlert commonAlert = CommonAlert();

    CommentProvider commentProvider = Provider.of<CommentProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);
    TextEditingController childCommentController = TextEditingController();

    return Consumer<CommentProvider>(
      builder: (context, provider, _) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: commentProvider.getCommentList.length,
            itemBuilder: (context, index) {
              /// Consumer -> ListView.builder -> FutureBuilder 구조로 하게 되면 notifyListeners(); 할 때 FutureBuilder 무한 루프 걸리기 때문에
              /// 애초에 commentList에서 모든 childCommentList를 가져와서 여기서 서로 맞는 대댓글을 보여주게됨

              // 현재 댓글에 해당하는 commentSeq
              int currentCommentSeq = commentProvider.getCommentList[index].commentSeq;
              // 현재 댓글에 해당하는 대댓글 추출
              List<ChildCommentDto> currentChildComments = commentProvider.getChildCommentList
                  .where((childComment) => childComment.commentSeq == currentCommentSeq)
                  .toList();

              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      child: SizedBox(
                        // padding: const EdgeInsets.all(10.0),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Text(
                                    commentProvider.getCommentList[index].content.toString(),
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
                                    maxLines: 10,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          (commentProvider.getCommentList[index].memberSeq == memberInfoProvider.getMemberSeq) ?
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                            child: Text(
                                              'Lv.${commentProvider.getCommentList[index].level} ${commentProvider.getCommentList[index].nickname}',
                                              textAlign: TextAlign.start,
                                            ),
                                          ) :
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                            child: BlockDropdownWidget(level: commentProvider.getCommentList[index].level!, nickname: commentProvider.getCommentList[index].nickname, memberSeq: commentProvider.getCommentList[index].memberSeq),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                                            child: Text(
                                              commentProvider.getCommentList[index].regDt,
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    (commentProvider.getCommentList[index].memberSeq == memberInfoProvider.getMemberSeq) ?
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {
                                          communityAlert.deleteConfirm(context, 'comment', commentProvider.getCommentList[index].boardSeq, commentProvider.getCommentList[index].commentSeq, null);
                                        },
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 15,
                                        ),
                                      ),
                                    ) : ReportButton(boardType: BoardType.communityComment, boardSeq: commentProvider.getCommentList[index].commentSeq, reportedMemberSeq: commentProvider.getCommentList[index].memberSeq)
                                  ],
                                )
                              ],
                            ),
                            /// 대댓글
                            Container(
                              color: Colors.grey,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: currentChildComments.length,
                                itemBuilder: (context, i) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        margin: const EdgeInsets.only(left: 16),
                                        child: Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                '┗'
                                              ),
                                            ),
                                            Expanded(
                                              flex: 15,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    currentChildComments[i].content.toString(),
                                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                                  ),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 12,
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            (currentChildComments[i].memberSeq == memberInfoProvider.getMemberSeq) ?
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                              child: Text(
                                                                'Lv.${currentChildComments[i].level} ${currentChildComments[i].nickname}'
                                                              ),
                                                            ) :
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 5, 5, 0),
                                                              child: BlockDropdownWidget(level: currentChildComments[i].level!, nickname: currentChildComments[i].nickname, memberSeq: currentChildComments[i].memberSeq),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.fromLTRB(0, 0, 5, 10),
                                                              child: Text(
                                                                currentChildComments[i].regDt,
                                                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10,),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      (currentChildComments[i].memberSeq == memberInfoProvider.getMemberSeq) ?
                                                      Expanded(
                                                        flex: 2,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            communityAlert.deleteConfirm(context, 'childComment', null, null, currentChildComments[i].childCommentSeq);
                                                          },
                                                          icon: const Icon(
                                                            Icons.clear_rounded,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      )
                                                      : ReportButton(boardType: BoardType.communityChildComment, boardSeq: currentChildComments[i].childCommentSeq, reportedMemberSeq: currentChildComments[i].memberSeq)
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const CustomDivider(height: 1, color: Colors.white),
                                    ],
                                  );
                                }
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        // 클릭된 댓글의 인덱스를 저장하고 상태를 업데이트
                        commentProvider.toggleComment(index);
                        // 닫혀있는 자식 댓글이 있다면 열기
                        if (commentProvider.openChildCommentIndex != null) {
                          commentProvider.toggleChildComment(null);
                        }
                      },
                    ),
                    const CustomDivider(height: 1, color: Colors.grey),
                    Container(
                      color: Colors.grey,
                      child: Column(
                        children: [
                          Consumer<CommentProvider>(
                            builder: (context, provider, _) {
                              if (commentProvider.openCommentIndex == index) {
                                return Container(
                                  color: Colors.grey.withOpacity(0.5),
                                  padding: const EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.only(left: 16),
                                  child: Row(
                                    children: [
                                      const Expanded(
                                        flex: 1,
                                        child: Text(
                                          '┗'
                                        ),
                                      ),
                                      Expanded(
                                        flex: 15,
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              color: Colors.white,
                                              width: double.infinity,
                                              child: Text(
                                                '닉네임 : ${memberInfoProvider.getNickName}',
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                            ),
                                            const CustomDivider(height: 1, color: Colors.grey),
                                            Container(
                                              height: MediaQuery.of(context).size.height * 0.13,
                                              color: Colors.white,
                                              child: TextField(
                                                controller: childCommentController,
                                                // textAlignVertical: TextAlignVertical(y: -0.5),
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                maxLines: 10,
                                                decoration: const InputDecoration(
                                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0)
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
                                                    if (childCommentController.text.isEmpty || childCommentController.text == ' ') {
                                                      return commonAlert.spaceError(context, '내용');
                                                    }

                                                    int result = await communityService.setChildComment(
                                                        commentProvider.getCommentList[index].commentSeq,
                                                        commentProvider.getCommentList[index].boardSeq,
                                                        memberInfoProvider.getMemberSeq!,
                                                        memberInfoProvider.getNickName!,
                                                        childCommentController.text);
                                                    if (result != 0) {
                                                      ChildCommentDto childCommentDto = ChildCommentDto(
                                                          childCommentSeq: result, boardSeq: commentProvider.getCommentList[index].boardSeq, commentSeq: commentProvider.getCommentList[index].commentSeq,
                                                          memberSeq: memberInfoProvider.getMemberSeq!, nickname: memberInfoProvider.getNickName!,
                                                          content: childCommentController.text,
                                                          deleteYN: 'N',
                                                          regDt: DateTime.now().toString().substring(0, 10));

                                                      commentProvider.addChildCommentList(childCommentDto);
                                                      pointHistoryProvider.addCommunityComment();
                                                      if (pointHistoryProvider.getCommunityComment >= pointHistoryProvider.getTotalCommunityComment == false) {
                                                        await memberService.setPoint('COMMUNITY_COMMENT');
                                                      }

                                                      childCommentController.text = '';
                                                      FocusManager.instance.primaryFocus?.unfocus();
                                                    } else {
                                                      // 실패
                                                      if (mounted) {
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
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }
                          ),
                          const CustomDivider(height: 1, color: Colors.white)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
        );
      }
    );
  }
}
