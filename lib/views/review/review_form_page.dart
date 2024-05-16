import 'package:flutter/material.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../services/common_service.dart';
import '../../widgets/common/common_widget.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final CommonService _commonService = CommonService();
  final CommonWidget _commonWidget = CommonWidget();
  final CommonAlert _commonAlert = CommonAlert();

  @override
  Widget build(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final pointHistoryViewModel = Provider.of<PointHistoryViewModel>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '리뷰 글쓰기',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            reviewViewModel.setTitleController = '';
            reviewViewModel.setContentController = '';

            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.height * 0.007, 0, 0),
              child: Text(
                "저장",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            onPressed: () async {
              if (reviewViewModel.getTitleController.text.isEmpty || reviewViewModel.getTitleController.text == '') {
                return _commonAlert.spaceError(context, '제목');
              } else if (reviewViewModel.getContentController.text.isEmpty || reviewViewModel.getContentController.text == '') {
                return _commonAlert.spaceError(context, '업체 리뷰');
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                int? memberSeq = memberViewModel.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                String nickname = memberViewModel.getNickName.toString();

                bool result = await _reviewRepository.setReview(memberSeq!, nickname, reviewViewModel.getTitleController.text, reviewViewModel.getContentController.text);
                if (result && mounted) {
                  // 성공
                  reviewViewModel.setTitleController = '';
                  reviewViewModel.setContentController = '';

                  pointHistoryViewModel.addReviewWriting();
                  if (pointHistoryViewModel.getReviewWriting >= pointHistoryViewModel.getTotalReviewWriting == false) {
                    await _memberRepository.setPoint('REVIEW_WRITING');
                  }

                  if (mounted) {
                    _commonWidget.saveSuccessAlert(context);
                  }
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
                        // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                        // textAlignVertical: TextAlignVertical(y: -0.5),
                        controller: viewModel.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          _commonService.debounce(() {
                            viewModel.setTitleController = viewModel.getTitleController.text;
                            viewModel.callNotify();
                          });

                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '직급',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Consumer<ReviewViewModel>(
                        builder: (context, viewModel, _) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                            child: TextField(
                              // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                              // textAlignVertical: TextAlignVertical(y: -0.5),
                              controller: viewModel.getRankController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                              ),
                              onChanged: (String value) {
                                _commonService.debounce(() {
                                  viewModel.setRankController = viewModel.getRankController.text;
                                  viewModel.callNotify();
                                });
                              },
                            ),
                          );
                        }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '근무 일시',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Consumer<ReviewViewModel>(
                          builder: (context, viewModel, _) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                              child: TextField(
                                controller: viewModel.getPeriodController,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                                ),
                                onChanged: (String value) {
                                  _commonService.debounce(() {
                                    viewModel.setPeriodController = viewModel.getPeriodController.text;
                                    viewModel.callNotify();
                                  });
                                },
                              ),
                            );
                          }
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
                Text(
                  '전반적 분위기',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10,),
                Consumer<ReviewViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: TextField(
                        controller: viewModel.getAtmosphereController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          _commonService.debounce(() {
                            viewModel.setAtmosphereController = viewModel.getAtmosphereController.text;
                            viewModel.callNotify();
                          });
                        },
                      ),
                    );
                  }
                ),
                const SizedBox(height: 10,),
                Text(
                  '업체 리뷰',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10,),
                Consumer<ReviewViewModel>(
                  builder: (context, viewModel, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: viewModel.getContentController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          _commonService.debounce(() {
                            viewModel.setContentController = viewModel.getContentController.text;
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
