import 'package:flutter/material.dart';
import 'package:nogari/screens/community/information_use.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_data_dto.dart';
import '../../models/community/community_like_dto.dart';
import '../../models/community/community_provider.dart';
import '../../models/member/member_info_provider.dart';
import '../../services/community_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/common_search_bar.dart';
import '../../widgets/common/custom.divider.dart';
import '../../widgets/community/community_alert.dart';
import 'community_detail_page.dart';
import 'community_form_page.dart';

class AllCommunityList extends StatefulWidget {
  const AllCommunityList({super.key});

  @override
  State<AllCommunityList> createState() => _AllCommunityListState();
}

class _AllCommunityListState extends State<AllCommunityList> {
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Community> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  @override
  Widget build(BuildContext context) {
    final StorageService storage = StorageService();
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);

    return FutureBuilder(
        future: CommunityService().getCommunityList(communityProvider.getCurrentPage, communityProvider.getSize),
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
            CommunityDataDto communityData = snapshot.data;
            communityProvider.setCommunityData = communityData;
            communityProvider.setTotalPages = communityData.pages;
            communityProvider.setCommunityList = communityData.list;

            List<int> boardSeqList = [];

            for (int i = 0; i < communityData.list.length; i++) {
              boardSeqList.add(communityData.list[i].boardSeq);
            }
            communityProvider.setBoardSeqList = boardSeqList;
            communityProvider.setTempCommunityData = communityProvider.getCommunityData;
            communityProvider.setTempCommunityList = communityProvider.getCommunityList;
            Future.microtask(() => communityProvider.callNotify());


            return FutureBuilder(
                future: CommunityService().getCntOfComment(communityProvider.getBoardSeqList),
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
                    communityProvider.setCntOfComment = snapshot.data;
                    Future.microtask(() => communityProvider.callNotify());

                    return Consumer<CommunityProvider>(
                        builder: (context, provider, _) {
                          return Container(
                            // height: MediaQuery.of(context).size.height * 1.0,
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                            child: Column(
                              children: [
                                (communityProvider.getCommunityData!.list.isEmpty) ?
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
                                  itemCount: communityProvider.getCommunityList.length,
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
                                                                  communityProvider.getCommunityList[index].title,
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
                                                                    'Lv.${communityProvider.getCommunityList[index].level} ${communityProvider.getCommunityList[index].nickname}',
                                                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    communityProvider.getCommunityList[index].regDt.toString().substring(0, 10),
                                                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '조회 ${communityProvider.getCommunityList[index].viewCnt}',
                                                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 11),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child: Text(
                                                                    '추천 ${communityProvider.getCommunityList[index].likeCnt}',
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
                                                          communityProvider.getCntOfComment[communityProvider.getCommunityList[index].boardSeq].toString(),
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
                                              await CommunityService().addBoardViewCnt(communityProvider.getCommunityList[index].boardSeq);

                                              if (communityProvider.getCommunityList[index].fileName1 != null) {
                                                communityProvider.getCommunityList[index].fileUrl1 = await storage.downloadURL(communityProvider.getCommunityList[index].fileName1.toString(), 'community');
                                              }

                                              if (communityProvider.getCommunityList[index].fileName2 != null) {
                                                communityProvider.getCommunityList[index].fileUrl2 = await storage.downloadURL(communityProvider.getCommunityList[index].fileName2.toString(), 'community');
                                              }

                                              if (communityProvider.getCommunityList[index].fileName3 != null) {
                                                communityProvider.getCommunityList[index].fileUrl3 = await storage.downloadURL(communityProvider.getCommunityList[index].fileName3.toString(), 'community');
                                              }

                                              List<CommunityLikeDto> fetchData = await CommunityService().getBoardLikeCnt(communityProvider.getCommunityList[index].boardSeq);

                                              for (int i = 0; i < fetchData.length; i++) {
                                                if (fetchData[i].memberSeq == memberInfoProvider.getMemberSeq) {
                                                  communityProvider.getCommunityList[index].isMyPress = true;
                                                }
                                              }

                                              if (mounted) {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: communityProvider.getCommunityList[index])));
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
                                const CommonSearchBar(type: 'all', isFirstTime: true,)
                              ],
                            ),
                          );
                        }
                    );
                  }
                }
            );
          }
        }
    );
  }
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

      List<int> boardSeqList = [];

      for (int i = 0; i < communityData.list.length; i++) {
        boardSeqList.add(communityData.list[i].boardSeq);
      }
      communityProvider.setBoardSeqList = boardSeqList;
      communityProvider.setCntOfComment = await CommunityService().getCntOfComment(communityProvider.getBoardSeqList);
      communityProvider.callNotify();
    }
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
