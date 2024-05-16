import 'package:flutter/material.dart';
import 'package:nogari/enums/board_type.dart';
import 'package:nogari/models/community/community_data.dart';
import 'package:nogari/repositories/community/community_comment_repository_impl.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/views/community/community_update_form_page.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/widgets/common/banner_ad_widget.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/common/report_button.dart';
import 'package:nogari/widgets/community/comment_list.dart';
import 'package:nogari/widgets/community/community_comment.dart';
import 'package:provider/provider.dart';

import '../../models/community/child_comment.dart';
import '../../repositories/community/community_comment_repository.dart';
import '../../viewmodels/community/comment_viewmodel.dart';
import '../common/block_dropdown_widget.dart';
import '../common/circular_icon_text.dart';
import 'community_alert.dart';

class PostDetailWidget extends StatelessWidget {
  final Community postDetail;
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final CommunityCommentRepository _communityCommentRepository = CommunityCommentRepositoryImpl();
  final CommunityAlert _communityAlert = CommunityAlert();
  PostDetailWidget({super.key, required this.postDetail});

  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final commentViewModel = Provider.of<CommentViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);

    // 여기서 futurebuilder 로 대댓글 모두 가져오기
    return FutureBuilder(
      future: _communityCommentRepository.getChildCommentList(commentViewModel.getCommentList),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQueryData.fromView(View.of(context)).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff33D679),)
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else {
          List<ChildComment> childCommentList = snapshot.data;
          commentViewModel.setChildCommentList = childCommentList;
          Future.microtask(() => commentViewModel.callNotify());

          return SingleChildScrollView(
            child: GestureDetector(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 게시글 내용
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            postDetail.title,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (postDetail.memberSeq == memberViewModel.getMemberSeq) ?
                              TextButton(
                                onPressed: () {

                                },
                                child: Text(
                                  'Lv.${postDetail.level} ${postDetail.nickname}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
                              ) :
                              BlockDropdownWidget(level: postDetail.level!, nickname: postDetail.nickname, memberSeq: postDetail.memberSeq),
                              const SizedBox(width: 10,),
                              Text(
                                postDetail.regDt.toString().substring(0, 10),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        if (postDetail.fileUrl1 != null)
                          Image.network(
                            postDetail.fileUrl1.toString(),
                          ),
                        if (postDetail.fileUrl2 != null)
                          Image.network(
                            postDetail.fileUrl2.toString(),
                          ),
                        if (postDetail.fileUrl3 != null)
                          Image.network(
                            postDetail.fileUrl3.toString(),
                          ),
                        (postDetail.fileUrl1 != null || postDetail.fileUrl2 != null || postDetail.fileUrl3 != null) ?
                        const SizedBox(height: 20.0,) : const SizedBox(height: 8.0),
                        Text(
                          postDetail.content,
                          style: Theme.of(context).textTheme.bodyMedium
                        ),
                        SizedBox(height: MediaQueryData.fromView(View.of(context)).size.height * 0.05,),
                        Consumer<CommunityViewModel>(
                          builder: (context, viewModel, _) {
                            return Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  InkWell(
                                    child: CircularIconText(icon: Icons.star, cnt: viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).likeCnt, community: postDetail),
                                    onTap: () async {
                                      bool isMyPress = viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).isMyPress;
                                      if (isMyPress) {
                                        // delete
                                        bool result = await _communityRepository.deleteBoardLike(postDetail.boardSeq, memberViewModel.getMemberSeq!);
                                        viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).isMyPress = false;
                                        viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).likeCnt = viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).likeCnt -1;
                                        viewModel.callNotify();
                                      } else {
                                        // set
                                        bool result = await _communityRepository.setBoardLike(postDetail.boardSeq, memberViewModel.getMemberSeq!);
                                        viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).isMyPress = true;
                                        viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).likeCnt = viewModel.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => viewModel.getCommunity).likeCnt +1;
                                        viewModel.callNotify();
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 10.0,),
                                  Text('좋아요', style: Theme.of(context).textTheme.bodyMedium,)
                                ],
                              ),
                            );
                          }
                        ),
                        const SizedBox(height: 20.0,),
                        const BannerAdWidget()
                      ],
                    ),
                  ),
                  (postDetail.memberSeq != memberViewModel.memberSeq) ?
                  SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: ReportButton(boardType: BoardType.community, boardSeq: postDetail.boardSeq, reportedMemberSeq: postDetail.memberSeq,),
                      )
                    ),
                  ) : const SizedBox(),
                  (postDetail.memberSeq == memberViewModel.memberSeq) ?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              side: const BorderSide(color: Colors.black),
                            ),
                            onPressed: () {
                              /// 여기는 수정 위젯으로 바꿔야함
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityUpdateFormPage(postDetail: postDetail,)));
                            },
                            child: Text(
                              '수정',
                              style: Theme.of(context).textTheme.bodyMedium
                            ),
                          ),
                        ),
                        const SizedBox(width: 5.0,),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                              side: const BorderSide(color: Colors.black),
                            ),
                            onPressed: () {
                              _communityAlert.deleteConfirm(context, 'board', postDetail.boardSeq, null, null);
                            },
                            child: Text(
                              '삭제',
                              style: Theme.of(context).textTheme.bodyMedium
                            ),
                          ),
                        ),
                      ],
                    ),
                  ) : Container(),
                  /// 댓글 목록
                  Column(
                    children: [
                      const CustomDivider(height: 3, color: Colors.grey),
                      Consumer<CommentViewModel>(
                        builder: (context, viewModel, _) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '전체 댓글 ${viewModel.getCommentList.length}개',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const CustomDivider(height: 3, color: Colors.grey),
                      (commentViewModel.getCommentList.isEmpty) ?
                      Column(
                        children: [
                          const SizedBox(height: 10,),
                          const BannerAdWidget(),
                          const SizedBox(height: 10,),
                          CommunityCommentWidget(communityDetail: postDetail, commentList: commentViewModel.getCommentList),
                        ],
                      ) :
                      Column(
                        children: [
                          const CommentList(),
                          const SizedBox(height: 10,),
                          const BannerAdWidget(),
                          const SizedBox(height: 10,),
                          CommunityCommentWidget(communityDetail: postDetail, commentList: commentViewModel.getCommentList)
                        ],
                      ),
                    ],
                  )
                ],
              ),
              onTap: () {
                // 키보드 밖 클릭 시 키보드 닫기
                FocusManager.instance.primaryFocus?.unfocus();
              },
            ),
          );
        }
      },
    );
  }
}
