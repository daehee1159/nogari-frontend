import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/views/review/review_form_page.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
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
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final CommonService _commonService = CommonService();
  final adProvider = getIt.get<TempNogari>();
  late InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '출석 체크',
                      isComplete: viewModel.getAttendance >= viewModel.getTotalAttendance ? true : false,
                      cnt: viewModel.getAttendance,
                      totalCnt: viewModel.getTotalAttendance,
                      icon: FontAwesomeIcons.calendarCheck,
                    ),
                    onTap: () {
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '광고 보기',
                      isComplete: viewModel.getWatch5SecAd >= viewModel.getTotalWatch5SecAd ? true : false,
                      cnt: viewModel.getWatch5SecAd,
                      totalCnt: viewModel.getTotalWatch5SecAd,
                      icon: FontAwesomeIcons.rectangleAd,
                    ),
                    onTap: () async {
                      if (viewModel.getWatch5SecAd >= viewModel.getTotalWatch5SecAd == false) {
                        adProvider.setIsWatchingAd(false);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdIndicatorWidget()));
                        await _commonService.getInterstitialAd();
                        await _memberRepository.setPoint('WATCH_5SEC_AD');
                        viewModel.addWatch5SecAd();
                      } else {

                      }
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '커뮤니티 글 작성',
                      isComplete: viewModel.getCommunityWriting >= viewModel.getTotalCommunityWriting ? true : false,
                      cnt: viewModel.getCommunityWriting,
                      totalCnt: viewModel.getTotalCommunityWriting,
                      icon: FontAwesomeIcons.keyboard,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityFormPage()));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '리뷰 글 작성',
                      isComplete: viewModel.getReviewWriting >= viewModel.getTotalReviewWriting ? true : false,
                      cnt: viewModel.getReviewWriting,
                      totalCnt: viewModel.getTotalReviewWriting,
                      icon: Icons.star,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewFormPage()));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '커뮤니티 댓글 작성',
                      isComplete: viewModel.getCommunityComment >= viewModel.getTotalCommunityComment ? true : false,
                      cnt: viewModel.getCommunityComment,
                      totalCnt: viewModel.getTotalCommunityComment,
                      icon: FontAwesomeIcons.keyboard,
                    ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
                    },
                  );
                }
              ),
              const SizedBox(height: 10,),
              Consumer<PointHistoryViewModel>(
                builder: (context, viewModel, _) {
                  return InkWell(
                    child: PointCardWidget(
                      title: '리뷰 댓글 작성',
                      isComplete: viewModel.getReviewComment >= viewModel.getTotalReviewComment ? true : false,
                      cnt: viewModel.getReviewComment,
                      totalCnt: viewModel.getTotalReviewComment,
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
