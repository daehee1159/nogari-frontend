import 'package:flutter/material.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_data.dart';
import '../../services/storage_service.dart';
import '../../widgets/common/common_search_bar.dart';
import '../../widgets/common/custom.divider.dart';
import '../../widgets/community/community_alert.dart';
import 'community_detail_page.dart';
import 'community_form_page.dart';
import 'information_use.dart';

class CommunitySearchPage extends StatefulWidget {
  // 여기서 타입은 전체,추천,공지 등의 타입임
  final String type;
  final String searchCondition;
  final String keyword;
  const CommunitySearchPage({super.key, required this.type, required this.searchCondition, required this.keyword});

  @override
  State<CommunitySearchPage> createState() => _CommunitySearchPageState();
}

class _CommunitySearchPageState extends State<CommunitySearchPage> {
  final StorageService _storage = StorageService();
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  int currentPage = 1; // 현재 페이지 번호
  int totalPages = 10; // 전체 페이지 수 (실제 데이터와 맞게 설정 필요)
  List<Community> items = []; // 각 페이지별 데이터
  int maxVisibleButtons = 5; // 페이징바에 표시될 최대 버튼 수
  int size = 15;

  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '검색 결과',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            communityViewModel.initPageData();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: _communityRepository.getSearchCommunity(widget.type, widget.searchCondition, widget.keyword, (widget.type == 'like') ? communityViewModel.getLikeCount : null, communityViewModel.getCurrentPage, communityViewModel.getSize),
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
            CommunityData communityData = snapshot.data;
            communityViewModel.setCommunityData = communityData;
            communityViewModel.setTotalPages = communityData.pages;
            communityViewModel.setSearchCommunityList = communityData.list;

            List<int> boardSeqList = [];

            for (int i = 0; i < communityData.list.length; i++) {
              boardSeqList.add(communityData.list[i].boardSeq);
            }
            communityViewModel.setBoardSeqList = boardSeqList;
            Future.microtask(() => communityViewModel.callNotify());

            return FutureBuilder(
              future: _communityRepository.getCntOfComment(communityViewModel.getBoardSeqList),
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
                  communityViewModel.setCntOfComment = snapshot.data;
                  Future.microtask(() => communityViewModel.callNotify());

                  return Consumer<CommunityViewModel>(
                      builder: (context, viewModel, _) {
                        return Container(
                          // height: MediaQuery.of(context).size.height * 1.0,
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                          child: Column(
                            children: [
                              (viewModel.getCommunityData!.list.isEmpty) ?
                              Container(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                  child: Text(
                                    '게시글이 존재하지 않습니다.',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ) :
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: viewModel.getSearchCommunityList.length,
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
                                                                viewModel.getSearchCommunityList[index].title,
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
                                                                  'Lv.${viewModel.getSearchCommunityList[index].level} ${viewModel.getSearchCommunityList[index].nickname}',
                                                                  style: Theme.of(context).textTheme.bodySmall,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  viewModel.getSearchCommunityList[index].regDt.toString().substring(0, 10),
                                                                  style: Theme.of(context).textTheme.bodySmall,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '조회 ${viewModel.getSearchCommunityList[index].viewCnt}',
                                                                  style: Theme.of(context).textTheme.bodySmall,
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  '추천 ${viewModel.getSearchCommunityList[index].likeCnt}',
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
                                                        viewModel.getCntOfComment[viewModel.getSearchCommunityList[index].boardSeq].toString(),
                                                        style: Theme.of(context).textTheme.bodyMedium,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () async {
                                            // 이건 비동기 안해도 됨
                                            await _communityRepository.addBoardViewCnt(communityViewModel.getSearchCommunityList[index].boardSeq);

                                            if (viewModel.getSearchCommunityList[index].fileName1 != null) {
                                              viewModel.getSearchCommunityList[index].fileUrl1 = await _storage.downloadURL(viewModel.getSearchCommunityList[index].fileName1.toString(), 'community');
                                            }

                                            if (viewModel.getSearchCommunityList[index].fileName2 != null) {
                                              viewModel.getSearchCommunityList[index].fileUrl2 = await _storage.downloadURL(viewModel.getSearchCommunityList[index].fileName2.toString(), 'community');
                                            }

                                            if (viewModel.getSearchCommunityList[index].fileName3 != null) {
                                              viewModel.getSearchCommunityList[index].fileUrl3 = await _storage.downloadURL(viewModel.getSearchCommunityList[index].fileName3.toString(), 'community');
                                            }

                                            if (mounted) {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: viewModel.getSearchCommunityList[index])));
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
                              CommonSearchBar(type: widget.type, isFirstTime: false,)
                            ],
                          ),
                        );
                      }
                  );
                }
              },
            );
          }
        },
      )
    );
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

  // 페이지 바 위젯 생성
  Widget _buildPagingBar(BuildContext context) {
    return Consumer<CommunityViewModel>(
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
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    List<Widget> pageButtons = [];

    int half = communityViewModel.getMaxVisibleButtons ~/ 2;
    int start = communityViewModel.getCurrentPage - half;
    if (start < 1) start = 1;

    int end = start + communityViewModel.getMaxVisibleButtons - 1;
    if (end > communityViewModel.getTotalPages) {
      end = communityViewModel.getTotalPages;
      start = end - communityViewModel.getMaxVisibleButtons + 1;
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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: communityViewModel.getCurrentPage == i ? const Color(0xff33D679) : null),
                textAlign: TextAlign.center,
              ),
              onTap: () => onPageChanged(i, context),
            ),
          ),
        ),
      );
    }

    return Consumer<CommunityViewModel>(
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
