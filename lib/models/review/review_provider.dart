import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data_dto.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewDataDto? reviewData;
  // 전체
  List<Review> reviewList = [];
  List<Review> next10ReviewList = [];
  List<int> boardSeqList = [];
  Map<int, int> cntOfComment = {};
  // 내가 쓴 글
  List<Review> myReviewList = [];
  List<Review> next10MyReviewList = [];
  // 추천글
  List<Review> likeReviewList = [];
  // 공지글
  List<Review> noticeReviewList = [];
  // 검색글
  List<Review> searchReviewList = [];
  // 검색으로 인한 기존 데이터 넣어두는곳
  ReviewDataDto? tempReviewData;
  List<Review> tempReviewList = [];

  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;
  int likeCount = 30;

  // 글쓰기
  Review review = Review(boardSeq: 0,
      title: '', rank: '', period: '', atmosphere: '', content: '', memberSeq: 0, nickname: '',
      viewCnt: 0, likeCnt: 0, isMyPress: false,
      hotYN: 'N', deleteYN: 'N',
      regDt: DateTime.now()
  );

  TextEditingController _titleController = TextEditingController();
  TextEditingController _rankController = TextEditingController();
  TextEditingController _periodController = TextEditingController();
  TextEditingController _atmosphereController = TextEditingController();
  TextEditingController _contentController = TextEditingController();


  ReviewDataDto? get getReviewData => reviewData;
  List<Review> get getReviewList => reviewList;
  List<int> get getBoardSeqList => boardSeqList;
  Map<int, int> get getCntOfComment => cntOfComment;
  List<Review> get getNext10ReviewList => next10ReviewList;
  List<Review> get getMyReviewList => myReviewList;
  List<Review> get getNext10MyReviewList => next10MyReviewList;
  List<Review> get getLikeReviewList => likeReviewList;
  List<Review> get getNoticeReviewList => noticeReviewList;
  List<Review> get getSearchReviewList => searchReviewList;
  ReviewDataDto? get getTempReviewData => tempReviewData;
  List<Review> get getTempReviewList => tempReviewList;

  int get getCurrentPage => currentPage;
  int get getTotalPages => totalPages;
  int get getMaxVisibleButtons => maxVisibleButtons;
  int get getSize => size;
  int get getLikeCount => likeCount;

  Review get getReview => review;
  TextEditingController get getTitleController => _titleController;
  TextEditingController get getRankController => _rankController;
  TextEditingController get getPeriodController => _periodController;
  TextEditingController get getAtmosphereController => _atmosphereController;
  TextEditingController get getContentController => _contentController;

  void initPageData() {
    currentPage = 1;
    totalPages = 10;
    maxVisibleButtons = 5;
    size = 15;
    notifyListeners();
  }

  void addCntOfComment(int boardSeq) {
    if (cntOfComment.containsKey(boardSeq)) {
      cntOfComment[boardSeq] = cntOfComment[boardSeq]! + 1;
      notifyListeners();
    }
  }

  void minusCntOfComment(int boardSeq) {
    if (cntOfComment.containsKey(boardSeq)) {
      cntOfComment[boardSeq] = cntOfComment[boardSeq]! - 1;
      notifyListeners();
    }
  }

  set setReviewData(ReviewDataDto reviewDataDto) {
    reviewData = reviewDataDto;
    // notifyListeners();
  }

  set setReviewList(List<Review> review) {
    reviewList = review;
    // notifyListeners();
  }

  set setBoardSeqList(List<int> list) {
    boardSeqList = list;
    // notifyListeners();
  }

  set setCntOfComment(Map<int, int> value) {
    cntOfComment = value;
    // notifyListeners();
  }

  set setNext10ReviewList(List<Review> review) {
    next10ReviewList = review;
    // notifyListeners();
  }

  set setMyReviewList(List<Review> review) {
    myReviewList = review;
    // notifyListeners();
  }

  set setNextMy10ReviewList(List<Review> review) {
    next10MyReviewList = review;
    // notifyListeners();
  }

  set setLikeReviewList(List<Review> review) {
    likeReviewList = review;
    // notifyListeners();
  }

  set setNoticeReviewList(List<Review> review) {
    noticeReviewList = review;
    // notifyListeners();
  }

  set setSearchReviewList(List<Review> review) {
    searchReviewList = review;
    // notifyListeners();
  }

  set setTempReviewData(ReviewDataDto? reviewDataDto) {
    tempReviewData = reviewDataDto;
    // notifyListeners();
  }

  set setTempReviewList(List<Review> review) {
    tempReviewList = review;
    // notifyListeners();
  }

  set setCurrentPage(int value) {
    currentPage = value;
    notifyListeners();
  }

  set setTotalPages(int value) {
    totalPages = value;
    // notifyListeners();
  }

  set setMaxVisibleButtons(int value) {
    maxVisibleButtons = value;
    notifyListeners();
  }

  set setSize(int value) {
    size = value;
    notifyListeners();
  }

  set setLikeCount(int value) {
    likeCount = value;
    notifyListeners();
  }

  set setReview(Review value) {
    review = value;
    notifyListeners();
  }

  set setTitleController(String text) {
    _titleController.text = text;
    // notifyListeners();
  }

  set setRankController(String text) {
    _rankController.text = text;
    // notifyListeners();
  }

  set setPeriodController(String text) {
    _periodController.text = text;
    // notifyListeners();
  }

  set setAtmosphereController(String text) {
    _atmosphereController.text = text;
    // notifyListeners();
  }

  set setContentController(String text) {
    _contentController.text = text;
    // notifyListeners();
  }

  void callNotify() {
    notifyListeners();
  }
}
