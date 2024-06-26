import 'package:flutter/material.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/viewmodels/review/review_comment_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../views/home.dart';
import '../common/common_alert.dart';

class ReviewAlert {
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final CommonAlert _commonAlert = CommonAlert();

  // 페이징바에서 마지막 페이지일 경우
  void lastPage(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            "마지막 페이지입니다.",
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                '확인',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  void deleteConfirm(BuildContext context, String type, int? boardSeq, int? commentSeq, int? childCommentSeq) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final reviewCommentViewModel = Provider.of<ReviewCommentViewModel>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: const Text(
            '삭제 후 복구는 불가능합니다.\n삭제하시겠습니까?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text('삭제', style: Theme.of(context).textTheme.bodyMedium,),
              onPressed: () async {
                int seq = 0;
                switch (type) {
                  case 'board':
                    seq = boardSeq!;
                    break;
                  case 'comment':
                    seq = commentSeq!;
                    break;
                  case 'childComment':
                    seq = childCommentSeq!;
                    break;
                }
                bool result = await _reviewRepository.deleteReview(type, seq);

                if (result && context.mounted) {
                  switch (type) {
                    case 'board':
                    /// provider 에서 제거
                      reviewViewModel.reviewList.removeWhere((community) => community.boardSeq == seq);
                      reviewViewModel.callNotify();
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                      break;
                    case 'comment':
                      reviewCommentViewModel.reviewCommentList.removeWhere((comment) => comment.commentSeq == seq);
                      reviewViewModel.minusCntOfComment(boardSeq!);
                      reviewCommentViewModel.callNotify();
                      Navigator.of(context).pop();
                      break;
                    case 'childComment':
                      reviewCommentViewModel.reviewChildCommentList.removeWhere((childComment) => childComment.childCommentSeq == seq);
                      reviewCommentViewModel.callNotify();
                      Navigator.of(context).pop();
                      break;
                  }
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    _commonAlert.errorAlert(context);
                  }
                }
              },
            ),
            TextButton(
              child: Text('취소', style: Theme.of(context).textTheme.bodyMedium,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }
}
