import 'package:flutter/material.dart';
import 'package:nogari/models/community/community_data.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/views/community/all_community_list.dart';
import 'package:nogari/views/community/lkie_community_list.dart';
import 'package:nogari/views/community/notice_community_list.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/widgets/community/community_alert.dart';
import 'package:provider/provider.dart';

class PagingCommunity extends StatefulWidget {
  const PagingCommunity({super.key});

  @override
  State<PagingCommunity> createState() => _PagingCommunityState();
}

class _PagingCommunityState extends State<PagingCommunity> with SingleTickerProviderStateMixin {
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  late TabController _tabController;

  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Community> items = []; // 각 페이지별 데이터
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

  // 페이지 변경 시 데이터 로드 및 UI 갱신
  void onPageChanged(int page, BuildContext context) async {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);

    if (communityViewModel.getCommunityData!.pages == page && communityViewModel.getCommunityData!.isLastPage == true) {
      CommunityAlert().lastPage(context);
    } else {
      communityViewModel.setCurrentPage = page;
      CommunityData communityData = await _communityRepository.getCommunityList(page, size);
      communityViewModel.setCommunityData = communityData;
      communityViewModel.setCommunityList = communityData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < communityData.list.length; i++) {
        boardSeqList.add(communityData.list[i].boardSeq);
      }
      communityViewModel.setBoardSeqList = boardSeqList;
      communityViewModel.setCntOfComment = await _communityRepository.getCntOfComment(communityViewModel.getBoardSeqList);
      communityViewModel.callNotify();
    }
  }


  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
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
                communityViewModel.initPageData();
                communityViewModel.setCommunityData = communityViewModel.getTempCommunityData!;
                communityViewModel.setCommunityList = communityViewModel.getCommunityList;
                communityViewModel.callNotify();
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
      )
    );
  }

  Widget _buildTabContent(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return const AllCommunityList();
      case 1:
        return const LikeCommunityList();
      case 2:
        return const NoticeCommunityList();
      default:
        return Container();
    }
  }
}
