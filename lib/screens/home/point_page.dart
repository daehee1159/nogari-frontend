import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nogari/models/member/point_history_provider.dart';
import 'package:nogari/screens/review/review_form_page.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/home/point_card_widget.dart';
import 'package:provider/provider.dart';

import '../../models/common/temp_nogari.dart';
import '../../widgets/common/ad_indicator_widget.dart';
import '../community/community_form_page.dart';
import '../home.dart';

class PointPage extends StatefulWidget {
  const PointPage({super.key});

  @override
  State<PointPage> createState() => _PointPageState();
}

class _PointPageState extends State<PointPage> {
  final CommonService commonService = CommonService();
  late InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);
    final adProvider = getIt.get<TempNogari>();
    final MemberService memberService = MemberService();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '포인트 적립',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
                child: Text(
                  '오늘의 미션',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '출석 체크',
                      isComplete: pointHistoryProvider.getAttendance >= pointHistoryProvider.getTotalAttendance ? true : false,
                      cnt: pointHistoryProvider.getAttendance,
                      totalCnt: pointHistoryProvider.getTotalAttendance,
                      icon: FontAwesomeIcons.calendarCheck,
                    ),
                    onTap: () {
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '광고 보기',
                      isComplete: pointHistoryProvider.getWatch5SecAd >= pointHistoryProvider.getTotalWatch5SecAd ? true : false,
                      cnt: pointHistoryProvider.getWatch5SecAd,
                      totalCnt: pointHistoryProvider.getTotalWatch5SecAd,
                      icon: FontAwesomeIcons.rectangleAd,
                    ),
                    onTap: () async {
                      if (pointHistoryProvider.getWatch5SecAd >= pointHistoryProvider.getTotalWatch5SecAd == false) {
                        adProvider.setIsWatchingAd(false);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdIndicatorWidget()));
                        await commonService.getInterstitialAd();
                        await memberService.setPoint('WATCH_5SEC_AD');
                        pointHistoryProvider.addWatch5SecAd();
                      } else {

                      }
                    },
                  );
                }
              ),
              /// 30초 광고가 없기 때문에 다른 컨텐츠 추가되기전까지 제외
              // const SizedBox(height: 10,),
              // Consumer<PointHistoryProvider>(
              //   builder: (context, provider, _) {
              //     return InkWell(
              //       child: PointCardWidget(
              //         title: '광고 보기(30초)',
              //         isComplete: pointHistoryProvider.getWatch30SecAd >= pointHistoryProvider.getTotalWatch30SecAd ? true : false,
              //         cnt: pointHistoryProvider.getWatch30SecAd,
              //         totalCnt: pointHistoryProvider.getTotalWatch30SecAd,
              //         icon: FontAwesomeIcons.rectangleAd,
              //       ),
              //       onTap: () {
              //         print('광고 보기 30초');
              //       },
              //     );
              //   }
              // ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '커뮤니티 글 작성',
                      isComplete: pointHistoryProvider.getCommunityWriting >= pointHistoryProvider.getTotalCommunityWriting ? true : false,
                      cnt: pointHistoryProvider.getCommunityWriting,
                      totalCnt: pointHistoryProvider.getTotalCommunityWriting,
                      icon: FontAwesomeIcons.keyboard,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityFormPage()));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '리뷰 글 작성',
                      isComplete: pointHistoryProvider.getReviewWriting >= pointHistoryProvider.getTotalReviewWriting ? true : false,
                      cnt: pointHistoryProvider.getReviewWriting,
                      totalCnt: pointHistoryProvider.getTotalReviewWriting,
                      icon: Icons.star,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewFormPage()));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '커뮤니티 댓글 작성',
                      isComplete: pointHistoryProvider.getCommunityComment >= pointHistoryProvider.getTotalCommunityComment ? true : false,
                      cnt: pointHistoryProvider.getCommunityComment,
                      totalCnt: pointHistoryProvider.getTotalCommunityComment,
                      icon: FontAwesomeIcons.keyboard,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryProvider>(
                builder: (context, provider, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '리뷰 댓글 작성',
                      isComplete: pointHistoryProvider.getReviewComment >= pointHistoryProvider.getTotalReviewComment ? true : false,
                      cnt: pointHistoryProvider.getReviewComment,
                      totalCnt: pointHistoryProvider.getTotalReviewComment,
                      icon: Icons.star,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 3,)));
                    },
                  );
                }
              ),
            ],
          ),
        ),
      ),
    );
  }
}
