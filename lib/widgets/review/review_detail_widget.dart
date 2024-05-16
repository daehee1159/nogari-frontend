import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data.dart';
import 'package:nogari/repositories/review/review_comment_repository_impl.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_comment_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:nogari/widgets/common/banner_ad_widget.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/review/review_alert.dart';
import 'package:nogari/widgets/review/review_comment.dart';
import 'package:nogari/widgets/review/review_comment_list.dart';
import 'package:provider/provider.dart';

import '../../enums/board_type.dart';
import '../../models/review/review_child_comment.dart';
import '../../repositories/review/review_comment_repository.dart';
import '../../views/review/review_update_form_page.dart';
import '../common/block_dropdown_widget.dart';
import '../common/report_button.dart';
import '../common/review_circular_icon_text.dart';

class ReviewDetailWidget extends StatelessWidget {
  final Review reviewDetail;
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final ReviewCommentRepository _reviewCommentRepository = ReviewCommentRepositoryImpl();
  final ReviewAlert _reviewAlert = ReviewAlert();
  ReviewDetailWidget({super.key, required this.reviewDetail});

  @override
  Widget build(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final reviewCommentViewModel = Provider.of<ReviewCommentViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);

    // 여기서 futurebuilder 로 대댓글 모두 가져오기
    return FutureBuilder(
      future: _reviewCommentRepository.getChildCommentList(reviewCommentViewModel.getReviewCommentList),
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
          List<ReviewChildComment> childCommentList = snapshot.data;
          reviewCommentViewModel.setReviewChildCommentList = childCommentList;
          Future.microtask(() => reviewCommentViewModel.callNotify());

          return GestureDetector(
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
                          reviewDetail.title,
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
                            (reviewDetail.memberSeq == memberViewModel.getMemberSeq) ?
                            TextButton(
                                onPressed: () {

                                },
                                child: Text(
                                  'Lv.${reviewDetail.level} ${reviewDetail.nickname}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                )
                            ) :
                            BlockDropdownWidget(level: reviewDetail.level!, nickname: reviewDetail.nickname, memberSeq: reviewDetail.memberSeq),
                            const SizedBox(width: 10,),
                            Text(
                              reviewDetail.regDt.toString().substring(0, 10),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            '직급 : ',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                          ),
                          Text(
                            reviewDetail.rank,
                            style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Text(
                            '근무 일시 : ',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                          ),
                          Text(
                            reviewDetail.period,
                            style: Theme.of(context).textTheme.bodyMedium
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '전반적 분위기 : ',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                      ),
                      Text(
                        reviewDetail.atmosphere,
                        style: Theme.of(context).textTheme.bodyMedium
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '업체 리뷰 : ',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
                      ),
                      Text(
                        reviewDetail.content,
                        style: Theme.of(context).textTheme.bodyMedium
                      ),
                      SizedBox(height: MediaQueryData.fromView(View.of(context)).size.height * 0.05,),
                      Consumer<ReviewViewModel>(
                        builder: (context, viewModel, _) {
                          return Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                InkWell(
                                  child: ReviewCircularIconText(icon: Icons.star, cnt: viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).likeCnt, review: reviewDetail),
                                  onTap: () async {
                                    bool isMyPress = viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).isMyPress;
                                    if (isMyPress) {
                                      // delete
                                      bool result = await _reviewRepository.deleteBoardLike(reviewDetail.boardSeq, memberViewModel.getMemberSeq!);
                                      viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).isMyPress = false;
                                      viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).likeCnt = viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).likeCnt -1;
                                      viewModel.callNotify();
                                    } else {
                                      // set
                                      bool result = await _reviewRepository.setBoardLike(reviewDetail.boardSeq, memberViewModel.getMemberSeq!);
                                      viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).isMyPress = true;
                                      viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).likeCnt = viewModel.getReviewList.firstWhere((community) => community.boardSeq == reviewDetail.boardSeq, orElse: () => viewModel.getReview).likeCnt +1;
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
                (reviewDetail.memberSeq != memberViewModel.memberSeq) ?
                SizedBox(
                  width: double.infinity,
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                        child: ReportButton(boardType: BoardType.review, boardSeq: reviewDetail.boardSeq, reportedMemberSeq: reviewDetail.memberSeq,),
                      )
                  ),
                ) : const SizedBox(),
                (reviewDetail.memberSeq == memberViewModel.memberSeq) ?
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
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewUpdateFormPage(review: reviewDetail,)));
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
                            _reviewAlert.deleteConfirm(context, 'board', reviewDetail.boardSeq, null, null);
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
                    Consumer<ReviewCommentViewModel>(
                      builder: (context, viewModel, _) {
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '전체 댓글 ${viewModel.getReviewCommentList.length}개',
                                style: Theme.of(context).textTheme.bodyMedium
                              ),
                            ],
                          ),
                        );
                      }
                    ),
                    const CustomDivider(height: 3, color: Colors.grey),
                    (reviewViewModel.getReviewList.isEmpty) ?
                    Column(
                      children: [
                        const SizedBox(height: 10,),
                        const BannerAdWidget(),
                        const SizedBox(height: 10,),
                        ReviewCommentWidget(reviewDetail: reviewDetail, reviewCommentList: reviewCommentViewModel.getReviewCommentList),
                      ],
                    ) :
                    Column(
                      children: [
                        const ReviewCommentList(),
                        const SizedBox(height: 10,),
                        const BannerAdWidget(),
                        const SizedBox(height: 10,),
                        ReviewCommentWidget(reviewDetail: reviewDetail, reviewCommentList: reviewCommentViewModel.getReviewCommentList)
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
          );
        }
      },
    );

  }
}
