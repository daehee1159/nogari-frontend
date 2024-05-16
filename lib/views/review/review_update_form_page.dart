import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
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
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final CommonService _commonService = CommonService();
  final CommonWidget _commonWidget = CommonWidget();
  final CommonAlert _commonAlert = CommonAlert();

  @override
  void initState() {
    super.initState();
    /// build 이후에 setController 를 하게 되면 텍스트를 수정 후에도 계속 이전 텍스트로 돌아가서 어쩔수없이 여기서 처음에만 set해줌
    Future.delayed(
      Duration.zero,
          () {
        final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
        reviewViewModel.setTitleController = widget.review.title;
        reviewViewModel.setContentController = widget.review.content;
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);


    Future.microtask(() => reviewViewModel.callNotify());

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
            reviewViewModel.setTitleController = '';
            reviewViewModel.setContentController = '';
            reviewViewModel.callNotify();

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
              if (reviewViewModel.getTitleController.text == widget.review.title && reviewViewModel.getContentController.text == widget.review.content) {
                return _commonAlert.duplicateAlert(context);
              }

              if (reviewViewModel.getTitleController.text.isEmpty || reviewViewModel.getTitleController.text == '') {
                return _commonAlert.spaceError(context, '제목');
              } else if (reviewViewModel.getContentController.text.isEmpty || reviewViewModel.getContentController.text == '') {
                return _commonAlert.spaceError(context, '내용');
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                int? memberSeq = memberViewModel.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                String nickname = memberViewModel.getNickName.toString();

                bool result = await _reviewRepository.updateReview(widget.review.boardSeq, memberSeq!, nickname, reviewViewModel.getTitleController.text, reviewViewModel.getContentController.text);
                if (result && mounted) {
                  // 성공
                  reviewViewModel.setTitleController = '';
                  reviewViewModel.setContentController = '';
                  reviewViewModel.callNotify();

                  _commonWidget.updateSuccessAlert(context);
                } else {
                  if (mounted) {
                    return _commonAlert.errorAlert(context);
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
                Consumer<ReviewViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                      child: TextField(
                        controller: viewModel.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          _commonService.debounce(() {
                            viewModel.setTitleController = value;
                            viewModel.callNotify();
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
                Consumer<ReviewViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      // color: Colors.grey,
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: viewModel.getContentController,
                        maxLines: 10,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          _commonService.debounce(() {
                            viewModel.setContentController = value;
                            viewModel.callNotify();
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
