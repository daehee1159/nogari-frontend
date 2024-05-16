import 'package:flutter/material.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/viewmodels/community/comment_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/report_button.dart';
import 'package:nogari/widgets/community/community_alert.dart';
import 'package:provider/provider.dart';

import '../../enums/board_type.dart';
import '../../models/community/child_comment.dart';
import '../common/block_dropdown_widget.dart';
import '../common/custom.divider.dart';

class CommentList extends StatefulWidget {
  const CommentList({super.key});

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final CommunityAlert _communityAlert = CommunityAlert();
  final CommonAlert _commonAlert = CommonAlert();

  @override
  Widget build(BuildContext context) {
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final pointHistoryViewModel = Provider.of<PointHistoryViewModel>(context, listen: false);
    TextEditingController childCommentController = TextEditingController();

    return Consumer<CommentViewModel>(
      builder: (context, viewModel, _) {
        return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: viewModel.getCommentList.length,
            itemBuilder: (context, index) {
              /// Consumer -> ListView.builder -> FutureBuilder 구조로 하게 되면 notifyListeners(); 할 때 FutureBuilder 무한 루프 걸리기 때문에
              /// 애초에 commentList에서 모든 childCommentList를 가져와서 여기서 서로 맞는 대댓글을 보여주게됨
              // 현재 댓글에 해당하는 commentSeq
              int currentCommentSeq = viewModel.getCommentList[index].commentSeq;
              // 현재 댓글에 해당하는 대댓글 추출
              List<ChildComment> currentChildComments = viewModel.getChildCommentList
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
                                    viewModel.getCommentList[index].content.toString(),
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
                                          (viewModel.getCommentList[index].memberSeq == memberViewModel.getMemberSeq) ?
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                            child: Text(
                                              'Lv.${viewModel.getCommentList[index].level} ${viewModel.getCommentList[index].nickname}',
                                              textAlign: TextAlign.start,
                                            ),
                                          ) :
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                            child: BlockDropdownWidget(level: viewModel.getCommentList[index].level!, nickname: viewModel.getCommentList[index].nickname, memberSeq: viewModel.getCommentList[index].memberSeq),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(10, 0, 5, 10),
                                            child: Text(
                                              viewModel.getCommentList[index].regDt,
                                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 10, color: Colors.grey),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    (viewModel.getCommentList[index].memberSeq == memberViewModel.getMemberSeq) ?
                                    Expanded(
                                      flex: 2,
                                      child: IconButton(
                                        onPressed: () {
                                          _communityAlert.deleteConfirm(context, 'comment', viewModel.getCommentList[index].boardSeq, viewModel.getCommentList[index].commentSeq, null);
                                        },
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 15,
                                        ),
                                      ),
                                    ) : ReportButton(boardType: BoardType.communityComment, boardSeq: viewModel.getCommentList[index].commentSeq, reportedMemberSeq: viewModel.getCommentList[index].memberSeq)
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
                                                            (currentChildComments[i].memberSeq == memberViewModel.getMemberSeq) ?
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
                                                      (currentChildComments[i].memberSeq == memberViewModel.getMemberSeq) ?
                                                      Expanded(
                                                        flex: 2,
                                                        child: IconButton(
                                                          onPressed: () {
                                                            _communityAlert.deleteConfirm(context, 'childComment', null, null, currentChildComments[i].childCommentSeq);
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
                        viewModel.toggleComment(index);
                        // 닫혀있는 자식 댓글이 있다면 열기
                        if (viewModel.openChildCommentIndex != null) {
                          viewModel.toggleChildComment(null);
                        }
                      },
                    ),
                    const CustomDivider(height: 1, color: Colors.grey),
                    Container(
                      color: Colors.grey,
                      child: Column(
                        children: [
                          Consumer<CommentViewModel>(
                            builder: (context, viewModel, _) {
                              if (viewModel.openCommentIndex == index) {
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
                                                '닉네임 : ${memberViewModel.getNickName}',
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
                                                      return _commonAlert.spaceError(context, '내용');
                                                    }

                                                    int result = await _communityRepository.setChildComment(
                                                        viewModel.getCommentList[index].commentSeq,
                                                        viewModel.getCommentList[index].boardSeq,
                                                        memberViewModel.getMemberSeq!,
                                                        memberViewModel.getNickName!,
                                                        childCommentController.text);
                                                    if (result != 0) {
                                                      ChildComment childComment = ChildComment(
                                                          childCommentSeq: result, boardSeq: viewModel.getCommentList[index].boardSeq, commentSeq: viewModel.getCommentList[index].commentSeq,
                                                          memberSeq: memberViewModel.getMemberSeq!, nickname: memberViewModel.getNickName!,
                                                          content: childCommentController.text,
                                                          deleteYN: 'N',
                                                          regDt: DateTime.now().toString().substring(0, 10));

                                                      viewModel.addChildCommentList(childComment);
                                                      pointHistoryViewModel.addCommunityComment();
                                                      if (pointHistoryViewModel.getCommunityComment >= pointHistoryViewModel.getTotalCommunityComment == false) {
                                                        await _memberRepository.setPoint('COMMUNITY_COMMENT');
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
