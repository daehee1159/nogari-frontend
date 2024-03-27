import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/services/review_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/member/member_info_provider.dart';
import '../../models/member/point_history_provider.dart';
import '../../services/common_service.dart';
import '../../widgets/common/common_widget.dart';

class ReviewFormPage extends StatefulWidget {
  const ReviewFormPage({super.key});

  @override
  State<ReviewFormPage> createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final CommonService commonService = CommonService();
  final CommonWidget commonWidget = CommonWidget();
  final ReviewService reviewService = ReviewService();
  final MemberService memberService = MemberService();
  final CommonAlert commonAlert = CommonAlert();

  @override
  Widget build(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);

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
            reviewProvider.setTitleController = '';
            reviewProvider.setContentController = '';

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
              if (reviewProvider.getTitleController.text.isEmpty || reviewProvider.getTitleController.text == '') {
                return commonAlert.spaceError(context, '제목');
              } else if (reviewProvider.getContentController.text.isEmpty || reviewProvider.getContentController.text == '') {
                return commonAlert.spaceError(context, '업체 리뷰');
              } else {
                SharedPreferences pref = await SharedPreferences.getInstance();
                int? memberSeq = memberInfoProvider.getMemberSeq ?? pref.getInt(Glob.memberSeq);
                String nickname = memberInfoProvider.getNickName.toString();

                bool result = await reviewService.setReview(memberSeq!, nickname, reviewProvider.getTitleController.text, reviewProvider.getContentController.text);
                if (result && mounted) {
                  // 성공
                  reviewProvider.setTitleController = '';
                  reviewProvider.setContentController = '';

                  pointHistoryProvider.addReviewWriting();
                  if (pointHistoryProvider.getReviewWriting >= pointHistoryProvider.getTotalReviewWriting == false) {
                    await memberService.setPoint('REVIEW_WRITING');
                  }

                  if (mounted) {
                    commonWidget.saveSuccessAlert(context);
                  }
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
                        // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                        // textAlignVertical: TextAlignVertical(y: -0.5),
                        controller: reviewProvider.getTitleController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          commonService.debounce(() {
                            reviewProvider.setTitleController = reviewProvider.getTitleController.text;
                            reviewProvider.callNotify();
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
                      child: Consumer<ReviewProvider>(
                        builder: (context, provider, _) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04,
                            child: TextField(
                              // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                              // textAlignVertical: TextAlignVertical(y: -0.5),
                              controller: reviewProvider.getRankController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                              ),
                              onChanged: (String value) {
                                commonService.debounce(() {
                                  reviewProvider.setRankController = reviewProvider.getRankController.text;
                                  reviewProvider.callNotify();
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
                      child: Consumer<ReviewProvider>(
                          builder: (context, provider, _) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                              child: TextField(
                                controller: reviewProvider.getPeriodController,
                                style: Theme.of(context).textTheme.bodyMedium,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                                ),
                                onChanged: (String value) {
                                  commonService.debounce(() {
                                    reviewProvider.setPeriodController = reviewProvider.getPeriodController.text;
                                    reviewProvider.callNotify();
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
                Consumer<ReviewProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: TextField(
                        controller: reviewProvider.getAtmosphereController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0)
                        ),
                        onChanged: (String value) {
                          commonService.debounce(() {
                            reviewProvider.setAtmosphereController = reviewProvider.getAtmosphereController.text;
                            reviewProvider.callNotify();
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
                Consumer<ReviewProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: TextField(
                        controller: reviewProvider.getContentController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0)
                        ),
                        onChanged: (value) {
                          commonService.debounce(() {
                            reviewProvider.setContentController = reviewProvider.getContentController.text;
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

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    String realMonth = "";
    String realDay = "";

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));

      if (date.month < 10) {
        realMonth = "0${date.month}";
      } else {
        realMonth = date.month.toString();
      }

      if ((date.day) < 10) {
        realDay = "0${date.day}";
      } else {
        realDay = (date.day).toString();
      }

      days.add(DateTime.parse("${date.year}-$realMonth-$realDay"));
    }
    return days;
  }
}
