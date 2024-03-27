import 'package:flutter/material.dart';
import 'package:nogari/enums/board_type.dart';
import 'package:nogari/models/community/child_comment_dto.dart';
import 'package:nogari/models/community/community_data_dto.dart';
import 'package:nogari/models/community/community_provider.dart';
import 'package:nogari/screens/community/community_update_form_page.dart';
import 'package:nogari/services/community_service.dart';
import 'package:nogari/widgets/common/banner_ad_widget.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/common/report_button.dart';
import 'package:nogari/widgets/community/comment_list.dart';
import 'package:nogari/widgets/community/community_comment.dart';
import 'package:provider/provider.dart';

import '../../models/community/comment_provider.dart';
import '../../models/member/member_info_provider.dart';
import '../../services/community_comment_service.dart';
import '../common/block_dropdown_widget.dart';
import '../common/circular_icon_text.dart';
import 'community_alert.dart';

class PostDetailWidget extends StatelessWidget {
  final Community postDetail;

  const PostDetailWidget({super.key, required this.postDetail});

  @override
  Widget build(BuildContext context) {
    final CommunityService communityService = CommunityService();
    final CommunityAlert communityAlert = CommunityAlert();

    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    CommentProvider commentProvider = Provider.of<CommentProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);

    // 여기서 futurebuilder 로 대댓글 모두 가져오기
    return FutureBuilder(
      future: CommunityCommentService().getChildCommentList(commentProvider.getCommentList),
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
          List<ChildCommentDto> childCommentList = snapshot.data;
          commentProvider.setChildCommentList = childCommentList;
          Future.microtask(() => commentProvider.callNotify());

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
                              (postDetail.memberSeq == memberInfoProvider.getMemberSeq) ?
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
                        Consumer<CommunityProvider>(
                          builder: (context, provider, _) {
                            return Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  InkWell(
                                    child: CircularIconText(icon: Icons.star, cnt: communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).likeCnt, community: postDetail),
                                    onTap: () async {
                                      bool isMyPress = communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).isMyPress;
                                      if (isMyPress) {
                                        // delete
                                        bool result = await communityService.deleteBoardLike(postDetail.boardSeq, memberInfoProvider.getMemberSeq!);
                                        communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).isMyPress = false;
                                        communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).likeCnt = communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).likeCnt -1;
                                        communityProvider.callNotify();
                                      } else {
                                        // set
                                        bool result = await communityService.setBoardLike(postDetail.boardSeq, memberInfoProvider.getMemberSeq!);
                                        communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).isMyPress = true;
                                        communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).likeCnt = communityProvider.getCommunityList.firstWhere((community) => community.boardSeq == postDetail.boardSeq, orElse: () => communityProvider.getCommunity).likeCnt +1;
                                        communityProvider.callNotify();
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
                  (postDetail.memberSeq != memberInfoProvider.memberSeq) ?
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
                  (postDetail.memberSeq == memberInfoProvider.memberSeq) ?
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
                              communityAlert.deleteConfirm(context, 'board', postDetail.boardSeq, null, null);
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
                      Consumer<CommentProvider>(
                        builder: (context, provider, _) {
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  '전체 댓글 ${commentProvider.getCommentList.length}개',
                                  style: Theme.of(context).textTheme.bodyMedium
                                ),
                              ],
                            ),
                          );
                        }
                      ),
                      const CustomDivider(height: 3, color: Colors.grey),
                      (commentProvider.getCommentList.isEmpty) ?
                      Column(
                        children: [
                          const SizedBox(height: 10,),
                          const BannerAdWidget(),
                          const SizedBox(height: 10,),
                          CommunityCommentWidget(communityDetail: postDetail, commentDtoList: commentProvider.getCommentList),
                        ],
                      ) :
                      Column(
                        children: [
                          const CommentList(),
                          const SizedBox(height: 10,),
                          const BannerAdWidget(),
                          const SizedBox(height: 10,),
                          CommunityCommentWidget(communityDetail: postDetail, commentDtoList: commentProvider.getCommentList)
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
