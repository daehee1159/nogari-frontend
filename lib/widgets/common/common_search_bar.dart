import 'package:flutter/material.dart';
import 'package:nogari/repositories/community/community_repository.dart';
import 'package:nogari/repositories/community/community_repository_impl.dart';
import 'package:nogari/views/community/community_search_page.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:provider/provider.dart';

import '../../enums/search_condition.dart';
import '../../models/community/community_data.dart';

class CommonSearchBar extends StatefulWidget {
  final String type;
  final bool isFirstTime;  // 처음 == true
  const CommonSearchBar({super.key, required this.type, required this.isFirstTime});

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  final CommonService _commonService = CommonService();
  final CommunityRepository _communityRepository = CommunityRepositoryImpl();
  TextEditingController textController = TextEditingController();
  SearchCondition searchCondition = SearchCondition.title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
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
                    _commonService.getConditionLabel(condition),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
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
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
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
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    // 검색 로직을 여기에 구현
    if (widget.isFirstTime) {
      /// 뒤로가기 할 때 데이터의 보존을 위해 temp에 넣어두고 뒤로가기 했을 때 temp 를 다시 CommunityList 에 넣어줌
      communityViewModel.setTempCommunityData = communityViewModel.getCommunityData;
      communityViewModel.setTempCommunityList = communityViewModel.getCommunityList;
      communityViewModel.callNotify();
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunitySearchPage(type: widget.type, searchCondition: searchCondition.name, keyword: textController.text)));
    } else {
      final CommunityData communityData;
      if (widget.type == 'like') {
        communityData = await _communityRepository.getSearchCommunity(widget.type, searchCondition.name, textController.text, communityViewModel.getLikeCount, communityViewModel.getCurrentPage, communityViewModel.getSize);
      } else {
        communityData = await _communityRepository.getSearchCommunity(widget.type, searchCondition.name, textController.text, null, communityViewModel.getCurrentPage, communityViewModel.getSize);
      }

      CommunityData resultData = communityData;
      communityViewModel.setCommunityData = resultData;
      communityViewModel.setTotalPages = resultData.pages;
      communityViewModel.setSearchCommunityList = resultData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < resultData.list.length; i++) {
        boardSeqList.add(resultData.list[i].boardSeq);
      }
      communityViewModel.setBoardSeqList = boardSeqList;
      Future.microtask(() => communityViewModel.callNotify());


      Map<int, int> result = await _communityRepository.getCntOfComment(communityViewModel.getBoardSeqList);
      communityViewModel.setCntOfComment = result;
      Future.microtask(() => communityViewModel.callNotify());
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }
}

