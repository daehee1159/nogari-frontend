import 'package:flutter/material.dart';

import 'news_dto.dart';

class NewsProvider extends ChangeNotifier {
  List<NewsDto> newsList = [];
  List<NewsDto> randomNewsList = [];
  bool firstLoad = true;
  ScrollController scrollController = ScrollController();
  int visibleNewsCount = 10; // 현재 화면에 보이는 뉴스 갯수

  List<NewsDto> get getNewsList => newsList;
  List<NewsDto> get getRandomNewsList => randomNewsList;
  List<NewsDto> get visibleNewsList => newsList.take(visibleNewsCount).toList();

  void initVisibleNewsCount() {
    visibleNewsCount = 10;
    notifyListeners();
  }

  // 추가된 메소드
  void initializeScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        // Reach the bottom of the list
        loadMoreNews();
      }
    });
    loadMoreNews();
  }

  void loadMoreNews() async {
    // Simulate loading more items, replace this with your actual data fetching logic
    await Future.delayed(const Duration(seconds: 2));

    visibleNewsCount += 10;

    // Notify listeners
    notifyListeners();
  }

  // Dispose the controller when it's no longer needed
  void disposeScrollController() {
    scrollController.dispose();
  }

  set setNewsList(List<NewsDto> list) {
    newsList = list;
    notifyListeners();
  }

  set setRandomNewsList(List<NewsDto> list) {
    list.shuffle(); // 리스트 랜덤 섞기
    randomNewsList = list.take(3).toList(); // 리스트에서 처음 3개만 가져오기
    notifyListeners();
  }

}
