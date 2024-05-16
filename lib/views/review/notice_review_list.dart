import 'package:flutter/material.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/views/review/review_detail_page.dart';
import 'package:nogari/views/review/review_form_page.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/review/review_data.dart';
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
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final ReviewAlert _reviewAlert = ReviewAlert();
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Review> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;


  @override
  Widget build(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);

    return FutureBuilder(
      future: _reviewRepository.getNoticeReviewList(reviewViewModel.getCurrentPage, reviewViewModel.getSize),
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
          ReviewData reviewData = snapshot.data;
          reviewViewModel.setReviewData = reviewData;
          reviewViewModel.setTotalPages = reviewData.pages;
          reviewViewModel.setNoticeReviewList = reviewData.list;

          List<int> boardSeqList = [];

          for (int i = 0; i < reviewData.list.length; i++) {
            boardSeqList.add(reviewData.list[i].boardSeq);
          }
          reviewViewModel.setBoardSeqList = boardSeqList;
          Future.microtask(() => reviewViewModel.callNotify());

          return FutureBuilder(
              future: _reviewRepository.getCntOfComment(reviewViewModel.getBoardSeqList),
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
                  reviewViewModel.setCntOfComment = snapshot.data;
                  Future.microtask(() => reviewViewModel.callNotify());

                  return Consumer<ReviewViewModel>(
                      builder: (context, viewModel, _) {
                        return Container(
                          // height: MediaQuery.of(context).size.height * 1.0,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Column(
                            children: [
                              (viewModel.getReviewData!.list.isEmpty) ?
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
                                itemCount: viewModel.getNoticeReviewList.length,
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
                                                                viewModel.getNoticeReviewList[index].title,
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
                                                                  'Lv.${viewModel.getNoticeReviewList[index].level} ${viewModel.getNoticeReviewList[index].nickname}',
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  viewModel.getNoticeReviewList[index].regDt.toString().substring(0, 10),
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '조회 ${viewModel.getNoticeReviewList[index].viewCnt}',
                                                                  style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '추천 ${viewModel.getNoticeReviewList[index].likeCnt}',
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
                                                        viewModel.getCntOfComment[viewModel.getNoticeReviewList[index].boardSeq].toString(),
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
                                            await _reviewRepository.addBoardViewCnt(viewModel.getNoticeReviewList[index].boardSeq);

                                            if (mounted) {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewDetailPage(review: viewModel.getNoticeReviewList[index])));
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
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);

    if (reviewViewModel.getReviewData!.pages == page && reviewViewModel.getReviewData!.isLastPage == true) {
      _reviewAlert.lastPage(context);
    } else {
      reviewViewModel.setCurrentPage = page;
      ReviewData reviewData = await _reviewRepository.getReviewList(page, size);
      reviewViewModel.setReviewData = reviewData;
      reviewViewModel.setReviewList = reviewData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < reviewData.list.length; i++) {
        boardSeqList.add(reviewData.list[i].boardSeq);
      }
      reviewViewModel.setBoardSeqList = boardSeqList;
      reviewViewModel.setCntOfComment = await _reviewRepository.getCntOfComment(reviewViewModel.getBoardSeqList);
      reviewViewModel.callNotify();
    }
  }

  // 페이지 바 위젯 생성
  Widget _buildPagingBar(BuildContext context) {
    return Consumer<ReviewViewModel>(
        builder: (context, viewModel, _) {
          return Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.first_page),
                  onPressed: viewModel.getCurrentPage == 1 ? null : () => onPageChanged(1, context), // 첫 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: viewModel.getCurrentPage == 1 ? null : () => onPageChanged(viewModel.getCurrentPage - 1, context), // 이전 페이지로 이동
                ),
                _buildPageButtons(context),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: viewModel.getCurrentPage == viewModel.getTotalPages ? null : () => onPageChanged(viewModel.getCurrentPage + 1, context), // 다음 페이지로 이동
                ),
                IconButton(
                  icon: const Icon(Icons.last_page),
                  onPressed: viewModel.getCurrentPage == viewModel.getTotalPages ? null : () => onPageChanged(viewModel.getTotalPages, context), // 마지막 페이지로 이동
                ),
              ],
            ),
          );
        }
    );
  }

  // 페이징 버튼 목록 생성
  Widget _buildPageButtons(BuildContext context) {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    List<Widget> pageButtons = [];

    int half = reviewViewModel.getMaxVisibleButtons ~/ 2;
    int start = reviewViewModel.getCurrentPage - half;
    if (start < 1) start = 1;

    int end = start + reviewViewModel.getMaxVisibleButtons - 1;
    if (end > reviewViewModel.getTotalPages) {
      end = reviewViewModel.getTotalPages;
      start = end - reviewViewModel.getMaxVisibleButtons + 1;
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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: reviewViewModel.getCurrentPage == i ? const Color(0xff33D679) : null),
                textAlign: TextAlign.center,
              ),
              onTap: () => onPageChanged(i, context),
            ),
          ),
        ),
      );
    }

    return Consumer<ReviewViewModel>(
      builder: (context, viewModel, _) {
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
