import 'package:flutter/material.dart';
import 'package:nogari/screens/review/review_detail_page.dart';
import 'package:nogari/screens/review/review_form_page.dart';
import 'package:provider/provider.dart';

import '../../models/review/review_data_dto.dart';
import '../../models/review/review_provider.dart';
import '../../services/review_service.dart';
import '../../widgets/common/custom.divider.dart';
import '../../widgets/review/review_alert.dart';
import '../../widgets/review/review_search_bar.dart';
import '../community/information_use.dart';

class NoticeReviewList extends StatefulWidget {
  const NoticeReviewList({super.key});

  @override
  State<NoticeReviewList> createState() => _NoticeReviewListState();
}

class _NoticeReviewListState extends State<NoticeReviewList> {
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Review> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  final ReviewService reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return FutureBuilder(
      future: reviewService.getNoticeReviewList(reviewProvider.getCurrentPage, reviewProvider.getSize),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff33D679),)
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else {
          ReviewDataDto reviewDataDto = snapshot.data;
          reviewProvider.setReviewData = reviewDataDto;
          reviewProvider.setTotalPages = reviewDataDto.pages;
          reviewProvider.setNoticeReviewList = reviewDataDto.list;

          List<int> boardSeqList = [];

          for (int i = 0; i < reviewDataDto.list.length; i++) {
            boardSeqList.add(reviewDataDto.list[i].boardSeq);
          }
          reviewProvider.setBoardSeqList = boardSeqList;
          Future.microtask(() => reviewProvider.callNotify());

          return FutureBuilder(
              future: reviewService.getCntOfComment(reviewProvider.getBoardSeqList),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: CircularProgressIndicator(color: Color(0xff33D679),))
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                } else {
                  Map<int, int> result = snapshot.data;
                  reviewProvider.setCntOfComment = snapshot.data;
                  Future.microtask(() => reviewProvider.callNotify());

                  return Consumer<ReviewProvider>(
                      builder: (context, provider, _) {
                        return Container(
                          // height: MediaQuery.of(context).size.height * 1.0,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Column(
                            children: [
                              (reviewProvider.getReviewData!.list.isEmpty) ?
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    '게시글이 존재하지 않습니다.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ) :
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reviewProvider.getNoticeReviewList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Material(
                                        // color: Colors.grey,
                                        child: InkWell(
                                          child: Container(
                                            height: 80.0,
                                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 80,
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                reviewProvider.getNoticeReviewList[index].title,
                                                                style: Theme.of(context).textTheme.bodyMedium,
                                                              ),
                                                            ],
                                                          ),
                                                          // color: Colors.grey,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  'Lv.${reviewProvider.getNoticeReviewList[index].level} ${reviewProvider.getNoticeReviewList[index].nickname}',
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  reviewProvider.getNoticeReviewList[index].regDt.toString().substring(0, 10),
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '조회 ${reviewProvider.getNoticeReviewList[index].viewCnt}',
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '추천 ${reviewProvider.getNoticeReviewList[index].likeCnt}',
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 10,
                                                  child: Container(
                                                    color: Colors.grey.withOpacity(0.2),
                                                    child: Center(
                                                      child: Text(
                                                        reviewProvider.getCntOfComment[reviewProvider.getNoticeReviewList[index].boardSeq].toString(),
                                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () async {
                                            // 이건 비동기 안해도 됨
                                            await reviewService.addBoardViewCnt(reviewProvider.getNoticeReviewList[index].boardSeq);

                                            if (mounted) {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetailPage(review: reviewProvider.getNoticeReviewList[index])));
                                            }
                                          },
                                        ),
                                      ),
                                      const CustomDivider(height: 1.0, color: Colors.grey,),
                                    ],
                                  );
                                },
                              ),
                              _buildPagingBar(context),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0.0),
                                            ),
                                            side: const BorderSide(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => const InformationUse()));
                                          },
                                          child: Text(
                                            '이용안내',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                                          ),
                                        )
                                    ),
                                    const SizedBox(width: 5.0,),
                                    Expanded(
                                      child: OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0.0),
                                          ),
                                          side: const BorderSide(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewFormPage()));
                                        },
                                        child: Text(
                                          '글쓰기',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const ReviewSearchBar(type: 'notice', isFirstTime: true,)
                            ],
                          ),
                        );
                      }
                  );
                }
              }
          );
        }
      },
    );
  }
  // 페이지 변경 시 데이터 로드 및 UI 갱신
  void onPageChanged(int page, BuildContext context) async {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    if (reviewProvider.getReviewData!.pages == page && reviewProvider.getReviewData!.isLastPage == true) {
      ReviewAlert().lastPage(context);
    } else {
      reviewProvider.setCurrentPage = page;
      ReviewDataDto communityData = await reviewService.getReviewList(page, size);
      reviewProvider.setReviewData = communityData;
      reviewProvider.setReviewList = communityData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < communityData.list.length; i++) {
        boardSeqList.add(communityData.list[i].boardSeq);
      }
      reviewProvider.setBoardSeqList = boardSeqList;
      reviewProvider.setCntOfComment = await reviewService.getCntOfComment(reviewProvider.getBoardSeqList);
      reviewProvider.callNotify();
    }
  }

  // 페이지 바 위젯 생성
  Widget _buildPagingBar(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    return Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: reviewProvider.getCurrentPage == 1 ? null : () => onPageChanged(1, context), // 첫 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: reviewProvider.getCurrentPage == 1 ? null : () => onPageChanged(reviewProvider.getCurrentPage - 1, context), // 이전 페이지로 이동
                ),
                _buildPageButtons(context),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: reviewProvider.getCurrentPage == reviewProvider.getTotalPages ? null : () => onPageChanged(reviewProvider.getCurrentPage + 1, context), // 다음 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: reviewProvider.getCurrentPage == reviewProvider.getTotalPages ? null : () => onPageChanged(reviewProvider.getTotalPages, context), // 마지막 페이지로 이동
                ),
              ],
            ),
          );
        }
    );
  }

  // 페이징 버튼 목록 생성
  Widget _buildPageButtons(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    List<Widget> pageButtons = [];

    int half = reviewProvider.getMaxVisibleButtons ~/ 2;
    int start = reviewProvider.getCurrentPage - half;
    if (start < 1) start = 1;

    int end = start + reviewProvider.getMaxVisibleButtons - 1;
    if (end > reviewProvider.getTotalPages) {
      end = reviewProvider.getTotalPages;
      start = end - reviewProvider.getMaxVisibleButtons + 1;
      if (start < 1) start = 1;
    }

    for (int i = start; i <= end; i++) {
      pageButtons.add(
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: GestureDetector(
              child: Text(
                '$i',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: reviewProvider.getCurrentPage == i ? const Color(0xff33D679) : null),
                textAlign: TextAlign.center,
              ),
              onTap: () => onPageChanged(i, context),
            ),
          ),
        ),
      );
    }

    return Consumer<ReviewProvider>(
      builder: (context, provider, _) {
        return Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: pageButtons,
          ),
        );
      }
    );
  }
}
