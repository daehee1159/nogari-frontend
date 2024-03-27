import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data_dto.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:nogari/services/review_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/member/member_info_provider.dart';
import '../../services/common_service.dart';
import '../../widgets/common/common_alert.dart';
import '../../widgets/common/common_widget.dart';

class ReviewUpdateFormPage extends StatefulWidget {
  final Review review;
  const ReviewUpdateFormPage({required this.review, super.key});

  @override
  State<ReviewUpdateFormPage> createState() => _ReviewUpdateFormPageState();
}

class _ReviewUpdateFormPageState extends State<ReviewUpdateFormPage> {
  /// 리뷰는 업데이트때 사진이 필요없으므로 사진관련된 내용은 지워야함
  final CommonService storage = CommonService();
  final CommonService commonService = CommonService();
  final CommonWidget commonWidget = CommonWidget();
  final ReviewService reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    /// build 이후에 setController 를 하게 되면 텍스트를 수정 후에도 계속 이전 텍스트로 돌아가서 어쩔수없이 여기서 처음에만 set해줌
    Future.delayed(
      Duration.zero,
          () {
        ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
        reviewProvider.setTitleController = widget.review.title;
        reviewProvider.setContentController = widget.review.content;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final CommonAlert commonAlert = CommonAlert();

    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);


    Future.microtask(() => reviewProvider.callNotify());

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '커뮤니티 수정 페이지',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            reviewProvider.setTitleController = '';
            reviewProvider.setContentController = '';
            reviewProvider.callNotify();

            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.007, 0, 0),
              child: Text(
                "수정",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              if (reviewProvider.getTitleController.text == widget.review.title && reviewProvider.getContentController.text == widget.review.content) {
                return commonAlert.duplicateAlert(context);
              }

              if (reviewProvider.getTitleController.text.isEmpty || reviewProvider.getTitleController.text == '') {
                return commonAlert.spaceError(context, '제목');
              } else if (reviewProvider.getContentController.text.isEmpty || reviewProvider.getContentController.text == '') {
                return commonAlert.spaceError(context, '내용');
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                int? memberSeq = memberInfoProvider.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                String nickname = memberInfoProvider.getNickName.toString();

                bool result = await reviewService.updateReview(widget.review.boardSeq, memberSeq!, nickname, reviewProvider.getTitleController.text, reviewProvider.getContentController.text);
                if (result && mounted) {
                  // 성공
                  reviewProvider.setTitleController = '';
                  reviewProvider.setContentController = '';
                  reviewProvider.callNotify();

                  commonWidget.updateSuccessAlert(context);
                } else {
                  if (mounted) {
                    return commonAlert.errorAlert(context);
                  }
                }
              }
            },
          )
        ],
      ),
      body: GestureDetector(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '제목',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10,),
                Consumer<ReviewProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextField(
                        controller: reviewProvider.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          commonService.debounce(() {
                            reviewProvider.setTitleController = value;
                            reviewProvider.callNotify();
                          });
                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10,),
                Text(
                  '내용',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Consumer<ReviewProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      // color: Colors.grey,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: reviewProvider.getContentController,
                        maxLines: 10,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          commonService.debounce(() {
                            reviewProvider.setContentController = value;
                            reviewProvider.callNotify();
                          });
                        },
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }
}
