import 'package:flutter/material.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/viewmodels/community/comment_viewmodel.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../../views/home.dart';

class CommunityAlert {
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  final CommonAlert commonAlert = CommonAlert();

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
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final commentViewModel = Provider.of<CommentViewModel>(context, listen: false);

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            '삭제 후 복구는 불가능합니다.\n삭제하시겠습니까?',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                '삭제',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
                bool result = await _communityRepository.deleteCommunity(type, seq);

                if (result && context.mounted) {
                  switch (type) {
                    case 'board':
                      /// provider 에서 제거
                      communityViewModel.communityList.removeWhere((community) => community.boardSeq == seq);
                      communityViewModel.callNotify();
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                      break;
                    case 'comment':
                      commentViewModel.commentList.removeWhere((comment) => comment.commentSeq == seq);
                      communityViewModel.minusCntOfComment(boardSeq!);
                      commentViewModel.callNotify();
                      Navigator.of(context).pop();
                      break;
                    case 'childComment':
                      commentViewModel.childCommentList.removeWhere((childComment) => childComment.childCommentSeq == seq);
                      commentViewModel.callNotify();
                      Navigator.of(context).pop();
                      break;
                  }
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    commonAlert.errorAlert(context);
                  }
                }
              },
            ),
            TextButton(
              child: Text(
                '취소',
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

  void completeAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(
            '노가리',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff33D679),
            ),
          ),
          content: Text(
            '완료되었습니다.',
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
}
