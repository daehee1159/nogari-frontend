import 'package:flutter/material.dart';
import 'package:nogari/widgets/community/community_alert.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_data_dto.dart';
import '../../models/community/community_provider.dart';
import '../../services/community_service.dart';
import '../../widgets/common/common_search_bar.dart';
import '../../widgets/common/custom.divider.dart';
import 'community_detail_page.dart';
import 'community_form_page.dart';
import 'information_use.dart';

/// 이 페이지로 오는 경로는 MyBoardPage 밖에 없으므로 여기서 FutureBuilder 를 굳이 사용해서 또 api 호출 할 필요가 없음
/// 이 전 페이지에서 이미 API 호출 후 Provider 에 1페이지 내용이 담겨있기 때문에 페이지가 변경되었을때만 다시 호출하면 됨

class PagingMyCommunity extends StatefulWidget {
  const PagingMyCommunity({super.key});

  @override
  State<PagingMyCommunity> createState() => _PagingMyCommunityState();
}

class _PagingMyCommunityState extends State<PagingMyCommunity> {
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Community> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  // 페이지 변경 시 데이터 로드 및 UI 갱신
  void onPageChanged(int page, BuildContext context) async {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    if (communityProvider.getCommunityData!.pages == page && communityProvider.getCommunityData!.isLastPage == true) {
      CommunityAlert().lastPage(context);
    } else {
      communityProvider.setCurrentPage = page;
      CommunityDataDto communityData = await CommunityService().getCommunityList(page, size);
      communityProvider.setCommunityData = communityData;
      communityProvider.setCommunityList = communityData.list;
      communityProvider.callNotify();
    }
  }

  @override
  Widget build(BuildContext context) {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);

    List<int> boardSeqList = [];

    for (int i = 0; i < communityProvider.getMyCommunityList.length; i++) {
      boardSeqList.add(communityProvider.getMyCommunityList[i].boardSeq);
    }
    communityProvider.setBoardSeqList = boardSeqList;

    Future.microtask(() => communityProvider.callNotify());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 커뮤니티 글 목록',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            communityProvider.initPageData();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: CommunityService().getCntOfComment(communityProvider.getBoardSeqList),
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
            Map<int, int> result = snapshot.data;
            communityProvider.setCntOfComment = snapshot.data;
            Future.microtask(() => communityProvider.callNotify());

            return Consumer<CommunityProvider>(
              builder: (context, provider, _) {
                return SingleChildScrollView(
                  child: Container(
                    // height: MediaQuery.of(context).size.height * 1.0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        (communityProvider.getMyCommunityList.isEmpty) ?
                        Center(
                          child: Text(
                            '데이터 없음',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ):
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: communityProvider.getMyCommunityList.length,
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
                                                          communityProvider.getMyCommunityList[index].title,
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
                                                            communityProvider.getMyCommunityList[index].regDt.toString().substring(0, 10),
                                                            style: Theme.of(context).textTheme.bodySmall,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '조회 ${communityProvider.getMyCommunityList[index].viewCnt}',
                                                            style: Theme.of(context).textTheme.bodySmall,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            '추천 ${communityProvider.getMyCommunityList[index].likeCnt}',
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
                                                  communityProvider.getCntOfComment[communityProvider.getMyCommunityList[index].boardSeq].toString(),
                                                  style: Theme.of(context).textTheme.bodyMedium,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      CommunityService().addBoardViewCnt(communityProvider.getCommunityList[index].boardSeq);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: communityProvider.getMyCommunityList[index])));
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
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CommunityFormPage()));
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
                        const CommonSearchBar(type: 'my', isFirstTime: true,)
                      ],
                    ),
                  ),
                );
              }
            );
          }
        },
      ),
    );
  }
  // 페이지 바 위젯 생성
  Widget _buildPagingBar(BuildContext context) {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    return Consumer<CommunityProvider>(
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
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    List<Widget> pageButtons = [];

    int half = communityProvider.getMaxVisibleButtons ~/ 2;
    int start = communityProvider.getCurrentPage - half;
    if (start < 1) start = 1;

    int end = start + communityProvider.getMaxVisibleButtons - 1;
    if (end > communityProvider.getTotalPages) {
      end = communityProvider.getTotalPages;
      start = end - communityProvider.getMaxVisibleButtons + 1;
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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: communityProvider.getCurrentPage == i ? const Color(0xff33D679) : null),
                textAlign: TextAlign.center,
              ),
              onTap: () => onPageChanged(i, context),
            ),
          ),
        ),
      );
    }

    return Consumer<CommunityProvider>(
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
