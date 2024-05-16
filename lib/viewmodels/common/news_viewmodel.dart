import 'package:flutter/material.dart';
import 'package:nogari/repositories/common/common_repository.dart';
import 'package:nogari/repositories/common/common_repository_impl.dart';

import '../../models/common/news.dart';

class NewsViewModel extends ChangeNotifier {
  final CommonRepository _repository = CommonRepositoryImpl();

  List<News> newsList = [];
  List<News> randomNewsList = [];
  bool firstLoad = true;
  ScrollController scrollController = ScrollController();
  int visibleNewsCount = 10; // 현재 화면에 보이는 뉴스 갯수

  List<News> get getNewsList => newsList;
  List<News> get getRandomNewsList => randomNewsList;
  List<News> get visibleNewsList => newsList.take(visibleNewsCount).toList();

  Future<void> getNews() async {
    List<News> newsList = await _repository.getNews();
    setNewsList = newsList;
    setRandomNewsList = newsList;
  }

  void initVisibleNewsCount() {
    visibleNewsCount = 10;
    notifyListeners();
  }

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

  set setNewsList(List<News> list) {
    newsList = list;
    notifyListeners();
  }

  set setRandomNewsList(List<News> list) {
    list.shuffle(); // 리스트 랜덤 섞기
    randomNewsList = list.take(3).toList(); // 리스트에서 처음 3개만 가져오기
    notifyListeners();
  }
}
