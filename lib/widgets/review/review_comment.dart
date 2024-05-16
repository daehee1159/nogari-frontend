import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/viewmodels/member/level_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_comment_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../../models/review/review_comment.dart';
import '../../repositories/member/member_repository.dart';
import '../common/custom.divider.dart';

class ReviewCommentWidget extends StatelessWidget {
  final Review reviewDetail;
  final List<ReviewComment> reviewCommentList;
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final CommonAlert _commonAlert = CommonAlert();

  ReviewCommentWidget({required this.reviewDetail, required this.reviewCommentList, super.key});

  @override
  Widget build(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final reviewCommentViewModel = Provider.of<ReviewCommentViewModel>(context, listen: false);
    final levelViewModel = Provider.of<LevelViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final pointHistoryViewModel = Provider.of<PointHistoryViewModel>(context, listen: false);
    TextEditingController commentController = TextEditingController();

    return Container(
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
                    '닉네임 : Lv.${levelViewModel.getLevel} ${memberViewModel.getNickName}'
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
                          return _commonAlert.spaceError(context, '내용');
                        }
                        int result = await _reviewRepository.setComment(reviewDetail.boardSeq, memberViewModel.getMemberSeq!, memberViewModel.getNickName!, commentController.text);

                        if (result != 0) {
                          // 성공했으면 provider 에 방금 데이터 넣어야함
                          ReviewComment reviewComment = ReviewComment(
                            commentSeq: result, boardSeq: reviewDetail.boardSeq,
                            memberSeq: memberViewModel.getMemberSeq!, nickname: memberViewModel.getNickName!,
                            content: commentController.text,
                            deleteYN: 'N',
                            regDt: DateTime.now().toString());
                          reviewCommentViewModel.addCommentList(reviewComment);
                          reviewViewModel.addCntOfComment(reviewDetail.boardSeq);
                          commentController.text = '';

                          pointHistoryViewModel.addReviewComment();
                          if (pointHistoryViewModel.getReviewComment >= pointHistoryViewModel.getTotalReviewComment == false) {
                            await _memberRepository.setPoint('REVIEW_COMMENT');
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
    );
  }
}
