import 'package:flutter/material.dart';
import 'package:nogari/repositories/review/review_repository.dart';
import 'package:nogari/repositories/review/review_repository_impl.dart';
import 'package:nogari/services/review_service.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../enums/search_condition.dart';
import '../../models/review/review_data.dart';
import '../../views/review/reivew_search_page.dart';

class ReviewSearchBar extends StatefulWidget {
  final String type;
  final bool isFirstTime;
  const ReviewSearchBar({required this.type, required this.isFirstTime, super.key});

  @override
  State<ReviewSearchBar> createState() => _ReviewSearchBarState();
}

class _ReviewSearchBarState extends State<ReviewSearchBar> {
  final ReviewRepository _reviewRepository = ReviewRepositoryImpl();
  final ReviewService _reviewService = ReviewService();
  TextEditingController textController = TextEditingController();
  SearchCondition searchCondition = SearchCondition.title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.04,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButton<SearchCondition>(
              value: searchCondition,
              onChanged: (value) {
                setState(() {
                  searchCondition = value!;
                });
              },
              items: SearchCondition.values
                  .map((condition) => DropdownMenuItem(
                value: condition,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  alignment: Alignment.center,
                  child: Text(
                    _reviewService.getConditionLabel(condition),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ))
                  .toList(),
              isExpanded: false,
              underline: const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
              child: TextField(
                controller: textController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  hintStyle: Theme.of(context).textTheme.bodyLarge,
                  suffixIcon: textController.text.isNotEmpty
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 14,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            textController.clear();
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.search,
                        ),
                        onPressed: () {
                          // 검색 버튼을 눌렀을 때의 로직 추가
                          _performSearch(context);
                        },
                      ),
                    ],
                  ) :
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      // 검색 버튼을 눌렀을 때의 로직 추가
                      _performSearch(context);
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context) async {
    final reviewViewModel = Provider.of<ReviewViewModel>(context, listen: false);
    // 검색 로직을 여기에 구현
    if (widget.isFirstTime) {
      /// 뒤로가기 할 때 데이터의 보존을 위해 temp에 넣어두고 뒤로가기 했을 때 temp 를 다시 CommunityList 에 넣어줌
      reviewViewModel.setTempReviewData = reviewViewModel.getReviewData;
      reviewViewModel.setTempReviewList = reviewViewModel.getReviewList;
      reviewViewModel.callNotify();
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewSearchPage(type: widget.type, searchCondition: searchCondition.name, keyword: textController.text)));
    } else {
      final ReviewData reviewData;
      if (widget.type == 'like') {
        reviewData = await _reviewRepository.getSearchReview(widget.type, searchCondition.name, textController.text, reviewViewModel.getLikeCount, reviewViewModel.getCurrentPage, reviewViewModel.getSize);
      } else {
        reviewData = await _reviewRepository.getSearchReview(widget.type, searchCondition.name, textController.text, null, reviewViewModel.getCurrentPage, reviewViewModel.getSize);
      }

      ReviewData resultData = reviewData;
      reviewViewModel.setReviewData = resultData;
      reviewViewModel.setTotalPages = resultData.pages;
      reviewViewModel.setSearchReviewList = resultData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < resultData.list.length; i++) {
        boardSeqList.add(resultData.list[i].boardSeq);
      }
      reviewViewModel.setBoardSeqList = boardSeqList;
      Future.microtask(() => reviewViewModel.callNotify());

      Map<int, int> result = await _reviewRepository.getCntOfComment(reviewViewModel.getBoardSeqList);
      reviewViewModel.setCntOfComment = result;
      Future.microtask(() => reviewViewModel.callNotify());
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}
