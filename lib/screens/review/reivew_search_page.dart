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

class ReviewSearchPage extends StatefulWidget {
  // 여기서 타입은 전체,추천,공지 등의 타입임
  final String type;
  final String searchCondition;
  final String keyword;

  const ReviewSearchPage({required this.type, required this.searchCondition, required this.keyword, super.key});

  @override
  State<ReviewSearchPage> createState() => _ReviewSearchPageState();
}

class _ReviewSearchPageState extends State<ReviewSearchPage> {
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Review> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  @override
  Widget build(BuildContext context) {
    final ReviewService reviewService = ReviewService();
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '검색 결과',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              reviewProvider.initPageData();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: FutureBuilder(
          future: reviewService.getSearchReview(widget.type, widget.searchCondition, widget.keyword, (widget.type == 'like') ? reviewProvider.getLikeCount : null, reviewProvider.getCurrentPage, reviewProvider.getSize),
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
              ReviewDataDto reviewDataDto = snapshot.data;
              reviewProvider.setReviewData = reviewDataDto;
              reviewProvider.setTotalPages = reviewDataDto.pages;
              reviewProvider.setSearchReviewList = reviewDataDto.list;

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
                                  itemCount: reviewProvider.getSearchReviewList.length,
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
                                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  reviewProvider.getSearchReviewList[index].title,
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
                                                                    'Lv.${reviewProvider.getSearchReviewList[index].level} ${reviewProvider.getSearchReviewList[index].nickname}',
                                                                    style: Theme.of(context).textTheme.bodySmall,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    reviewProvider.getSearchReviewList[index].regDt.toString().substring(0, 10),
                                                                    style: Theme.of(context).textTheme.bodySmall,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '조회 ${reviewProvider.getSearchReviewList[index].viewCnt}',
                                                                    style: Theme.of(context).textTheme.bodySmall,
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '추천 ${reviewProvider.getSearchReviewList[index].likeCnt}',
                                                                    style: Theme.of(context).textTheme.bodySmall,
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
                                                          reviewProvider.getCntOfComment[reviewProvider.getSearchReviewList[index].boardSeq].toString(),
                                                          style: Theme.of(context).textTheme.bodyMedium,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            onTap: () async {
                                              // 이건 비동기 안해도 됨
                                              await reviewService.addBoardViewCnt(reviewProvider.getSearchReviewList[index].boardSeq);

                                              if (mounted) {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetailPage(review: reviewProvider.getSearchReviewList[index])));
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
                                ReviewSearchBar(type: widget.type, isFirstTime: false,)
                              ],
                            ),
                          );
                        }
                    );
                  }
                },
              );
            }
          },
        )
    );
  }
  // 페이지 변경 시 데이터 로드 및 UI 갱신
  void onPageChanged(int page, BuildContext context) async {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    if (reviewProvider.getReviewData!.pages == page && reviewProvider.getReviewData!.isLastPage == true) {
      ReviewAlert().lastPage(context);
    } else {
      reviewProvider.setCurrentPage = page;
      ReviewDataDto communityData = await ReviewService().getReviewList(page, size);
      reviewProvider.setReviewData = communityData;
      reviewProvider.setReviewList = communityData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < communityData.list.length; i++) {
        boardSeqList.add(communityData.list[i].boardSeq);
      }
      reviewProvider.setBoardSeqList = boardSeqList;
      reviewProvider.setCntOfComment = await ReviewService().getCntOfComment(reviewProvider.getBoardSeqList);
      reviewProvider.callNotify();
    }

  }

  // 페이지 바 위젯 생성
  Widget _buildPagingBar(BuildContext context) {
    ReviewProvider communityProvider = Provider.of<ReviewProvider>(context, listen: false);
    return Consumer<ReviewProvider>(
        builder: (context, provider, _) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: communityProvider.getCurrentPage == 1 ? null : () => onPageChanged(1, context), // 첫 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: communityProvider.getCurrentPage == 1 ? null : () => onPageChanged(communityProvider.getCurrentPage - 1, context), // 이전 페이지로 이동
                ),
                _buildPageButtons(context),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: communityProvider.getCurrentPage == communityProvider.getTotalPages ? null : () => onPageChanged(communityProvider.getCurrentPage + 1, context), // 다음 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: communityProvider.getCurrentPage == communityProvider.getTotalPages ? null : () => onPageChanged(communityProvider.getTotalPages, context), // 마지막 페이지로 이동
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
