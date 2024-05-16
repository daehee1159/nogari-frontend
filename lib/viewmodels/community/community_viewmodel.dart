import 'package:flutter/material.dart';

import '../../models/community/community_data.dart';

class CommunityViewModel extends ChangeNotifier {
  CommunityData? communityData;
  // 전체
  List<Community> communityList = [];
  List<Community> next10CommunityList = [];
  List<int> boardSeqList = [];
  Map<int, int> cntOfComment = {};
  // 내가 쓴 글
  List<Community> myCommunityList = [];
  List<Community> next10MyCommunityList = [];
  // 추천글
  List<Community> likeCommunityList = [];
  // 공지글
  List<Community> noticeCommunityList = [];
  // 검색글
  List<Community> searchCommunityList = [];
  // 검색으로 인한 기존 데이터 넣어두는곳
  CommunityData? tempCommunityData;
  List<Community> tempCommunityList = [];

  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;
  int likeCount = 30;

  // 글쓰기
  Community community = Community(boardSeq: 0,
      title: '', content: '',
      fileName1: null, fileName2: null, fileName3: null,
      memberSeq: 0, nickname: '',
      viewCnt: 0, likeCnt: 0,
      hotYN: 'N', noticeYN: 'N', deleteYN: 'N',
      regDt: DateTime.now()
  );

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();


  CommunityData? get getCommunityData => communityData;
  List<Community> get getCommunityList => communityList;
  List<int> get getBoardSeqList => boardSeqList;
  Map<int, int> get getCntOfComment => cntOfComment;
  List<Community> get getNext10CommunityList => next10CommunityList;
  List<Community> get getMyCommunityList => myCommunityList;
  List<Community> get getNext10MyCommunityList => next10MyCommunityList;
  List<Community> get getLikeCommunityList => likeCommunityList;
  List<Community> get getNoticeCommunityList => noticeCommunityList;
  List<Community> get getSearchCommunityList => searchCommunityList;
  CommunityData? get getTempCommunityData => tempCommunityData;
  List<Community> get getTempCommunityList => tempCommunityList;

  int get getCurrentPage => currentPage;
  int get getTotalPages => totalPages;
  int get getMaxVisibleButtons => maxVisibleButtons;
  int get getSize => size;
  int get getLikeCount => likeCount;

  Community get getCommunity => community;
  TextEditingController get getTitleController => _titleController;
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

  set setCommunityData(CommunityData communityData) {
    communityData = communityData;
    // notifyListeners();
  }

  set setCommunityList(List<Community> community) {
    communityList = community;
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

  set setNext10CommunityList(List<Community> community) {
    next10CommunityList = community;
    // notifyListeners();
  }

  set setMyCommunityList(List<Community> community) {
    myCommunityList = community;
    // notifyListeners();
  }

  set setNextMy10CommunityList(List<Community> community) {
    next10MyCommunityList = community;
    // notifyListeners();
  }

  set setLikeCommunityList(List<Community> community) {
    likeCommunityList = community;
    // notifyListeners();
  }

  set setNoticeCommunityList(List<Community> community) {
    noticeCommunityList = community;
    // notifyListeners();
  }

  set setSearchCommunityList(List<Community> community) {
    searchCommunityList = community;
    // notifyListeners();
  }

  set setTempCommunityData(CommunityData? communityData) {
    tempCommunityData = communityData;
    // notifyListeners();
  }

  set setTempCommunityList(List<Community> community) {
    tempCommunityList = community;
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

  set setCommunity(Community value) {
    community = value;
    notifyListeners();
  }

  set setTitleController(String text) {
    _titleController.text = text;
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
