import 'package:flutter/material.dart';
import 'package:nogari/screens/community/community_search_page.dart';
import 'package:nogari/services/community_service.dart';
import 'package:provider/provider.dart';

import '../../enums/search_condition.dart';
import '../../models/community/community_data_dto.dart';
import '../../models/community/community_provider.dart';

class CommonSearchBar extends StatefulWidget {
  final String type;
  final bool isFirstTime;  // 처음 == true
  const CommonSearchBar({super.key, required this.type, required this.isFirstTime});

  @override
  State<CommonSearchBar> createState() => _CommonSearchBarState();
}

class _CommonSearchBarState extends State<CommonSearchBar> {
  TextEditingController _textController = TextEditingController();
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
                    _getConditionLabel(condition),
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
                controller: _textController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  suffixIcon: _textController.text.isNotEmpty
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
                            _textController.clear();
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

  String _getConditionLabel(SearchCondition condition) {
    switch (condition) {
      case SearchCondition.title:
        return '제목';
      case SearchCondition.titleContent:
        return '제목 + 내용';
      case SearchCondition.content:
        return '내용';
      case SearchCondition.nickname:
        return '닉네임';
    }
  }

  void _performSearch(BuildContext context) async {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    // 검색 로직을 여기에 구현
    if (widget.isFirstTime) {
      /// 뒤로가기 할 때 데이터의 보존을 위해 temp에 넣어두고 뒤로가기 했을 때 temp 를 다시 CommunityList 에 넣어줌
      communityProvider.setTempCommunityData = communityProvider.getCommunityData;
      communityProvider.setTempCommunityList = communityProvider.getCommunityList;
      communityProvider.callNotify();
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunitySearchPage(type: widget.type, searchCondition: searchCondition.name, keyword: _textController.text)));
    } else {
      final CommunityDataDto communityData;
      if (widget.type == 'like') {
        communityData = await CommunityService().getSearchCommunity(widget.type, searchCondition.name, _textController.text, communityProvider.getLikeCount, communityProvider.getCurrentPage, communityProvider.getSize);
      } else {
        communityData = await CommunityService().getSearchCommunity(widget.type, searchCondition.name, _textController.text, null, communityProvider.getCurrentPage, communityProvider.getSize);
      }

      CommunityDataDto resultData = communityData;
      communityProvider.setCommunityData = resultData;
      communityProvider.setTotalPages = resultData.pages;
      communityProvider.setSearchCommunityList = resultData.list;

      List<int> boardSeqList = [];

      for (int i = 0; i < resultData.list.length; i++) {
        boardSeqList.add(resultData.list[i].boardSeq);
      }
      communityProvider.setBoardSeqList = boardSeqList;
      Future.microtask(() => communityProvider.callNotify());


      Map<int, int> result = await CommunityService().getCntOfComment(communityProvider.getBoardSeqList);
      communityProvider.setCntOfComment = result;
      Future.microtask(() => communityProvider.callNotify());
      FocusManager.instance.primaryFocus?.unfocus();
    }

  }
}

