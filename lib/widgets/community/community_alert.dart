import 'package:flutter/material.dart';
import 'package:nogari/models/community/comment_provider.dart';
import 'package:nogari/services/community_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_provider.dart';
import '../../screens/home.dart';

class CommunityAlert {
  final CommunityService communityService = CommunityService();
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
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    CommentProvider commentProvider = Provider.of<CommentProvider>(context, listen: false);

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
                bool result = await communityService.deleteCommunity(type, seq);

                if (result && context.mounted) {
                  switch (type) {
                    case 'board':
                      /// provider 에서 제거
                      communityProvider.communityList.removeWhere((community) => community.boardSeq == seq);
                      communityProvider.callNotify();
                      Navigator.of(context).pop();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                      break;
                    case 'comment':
                      commentProvider.commentList.removeWhere((comment) => comment.commentSeq == seq);
                      communityProvider.minusCntOfComment(boardSeq!);
                      commentProvider.callNotify();
                      Navigator.of(context).pop();
                      break;
                    case 'childComment':
                      commentProvider.childCommentList.removeWhere((childComment) => childComment.childCommentSeq == seq);
                      commentProvider.callNotify();
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
