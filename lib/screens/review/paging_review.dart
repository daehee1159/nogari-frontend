import 'package:flutter/material.dart';
import 'package:nogari/models/review/review_data_dto.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:provider/provider.dart';

import 'all_review_list.dart';
import 'like_review_list.dart';
import 'notice_review_list.dart';

class PagingReview extends StatefulWidget {
  const PagingReview({super.key});

  @override
  State<PagingReview> createState() => _PagingReviewState();
}

class _PagingReviewState extends State<PagingReview> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Review> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  @override
  void initState() {
    super.initState();
    // _fetchData(currentPage); // 초기 데이터 가져오기
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ReviewProvider reviewProvider = Provider.of<ReviewProvider>(context, listen: false);

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: TabBar(
              // tabAlignment: TabAlignment.center,
              controller: _tabController,
              labelColor: const Color(0xff33D679),
              // isScrollable: true,
              indicatorColor: Colors.transparent,
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              onTap: (int index) {
                reviewProvider.initPageData();
                reviewProvider.setReviewData = reviewProvider.getTempReviewData!;
                reviewProvider.setReviewList = reviewProvider.getReviewList;
                reviewProvider.callNotify();
              },
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "전체보기",
                    style: TextStyle(fontFamily: 'NotoSansKR-Regular'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "추천글",
                    style: TextStyle(fontFamily: 'NotoSansKR-Regular'),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "공지사항",
                    style: TextStyle(fontFamily: 'NotoSansKR-Regular'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(child: _buildTabContent(context, 0)),
                SingleChildScrollView(child: _buildTabContent(context, 1)),
                SingleChildScrollView(child: _buildTabContent(context, 2)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const AllReviewList();
      case 1:
        return const LikeReviewList();
      case 2:
        return const NoticeReviewList();
      default:
        return Container();
    }
  }
}
