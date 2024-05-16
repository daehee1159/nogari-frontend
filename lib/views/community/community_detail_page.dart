import 'package:flutter/material.dart';
import 'package:nogari/models/community/comment.dart';
import 'package:nogari/repositories/community/community_comment_repository.dart';
import 'package:nogari/repositories/community/community_comment_repository_impl.dart';
import 'package:nogari/viewmodels/community/comment_viewmodel.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/community/post_detail_widget.dart';
import 'package:provider/provider.dart';

import '../../models/community/community_data.dart';
import 'community_form_page.dart';

class CommunityDetailPage extends StatelessWidget {
  final Community community;
  final CommunityCommentRepository _communityCommentRepository = CommunityCommentRepositoryImpl();
  CommunityDetailPage({required this.community, super.key});

  @override
  Widget build(BuildContext context) {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    final commentViewModel = Provider.of<CommentViewModel>(context, listen: false);

    // boardSeq 현재꺼 필터링
    List<Community> communityList = communityViewModel.getCommunityList.where((dto) => dto.boardSeq != community.boardSeq).toList();
    // 이후 10개 항목
    List<Community> next10Board = communityList.skipWhile((board) => board.boardSeq <= community.boardSeq).take(10).toList();

    communityViewModel.setNext10CommunityList = next10Board;
    Future.microtask(() => communityViewModel.callNotify());

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
          child: Image.asset(
            'images/nogari_icon_kr_width.png',
            height: MediaQueryData.fromView(View.of(context)).size.height * 0.15,
            fit: BoxFit.contain,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: FutureBuilder(
        future: _communityCommentRepository.getCommentList(community.boardSeq),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQueryData.fromView(View.of(context)).size.height,
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
            // 여기서 snapshot.data 는 댓글이며 댓글을 성공적으로 가져왔다면 대댓글도 가져와야함
            // 만약 댓글의 length == 0 이면 대댓글도 있을수가 없으니 FutureBuilder 할 필요가 없음

            List<Comment> commentList = snapshot.data;
            commentViewModel.setCommentList = commentList;

            Future.microtask(() => communityViewModel.callNotify());
            return GestureDetector(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10,),
                    PostDetailWidget(postDetail: community),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: CustomDivider(height: 1, color: Colors.grey,),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: communityViewModel.getNext10CommunityList.length,
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
                                                      communityViewModel.getNext10CommunityList[index].title,
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
                                                        'Lv.${communityViewModel.getNext10CommunityList[index].level} ${communityViewModel.getNext10CommunityList[index].nickname}',
                                                        style: Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        communityViewModel.getNext10CommunityList[index].regDt.toString().substring(0, 10),
                                                        style: Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '조회 ${communityViewModel.getNext10CommunityList[index].viewCnt}',
                                                        style: Theme.of(context).textTheme.bodySmall,
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '추천 ${communityViewModel.getNext10CommunityList[index].likeCnt}',
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
                                              communityViewModel.getCntOfComment[communityViewModel.getNext10CommunityList[index].boardSeq].toString(),
                                              style: Theme.of(context).textTheme.bodyMedium,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () async {
                                  int idx = 0;
                                  // 여기서는 _manHourProvider.getNext10CommunityList 이걸 주면 안되고 기존 데이터에서 _manHourProvider.getNext10CommunityList이거와 맞는걸 찾아서 줘야함
                                  for (int i = 0; i < communityViewModel.getCommunityList.length; i++) {
                                    if (communityViewModel.getNext10CommunityList[index].boardSeq == communityViewModel.getCommunityList[i].boardSeq) {
                                      idx = i;
                                    }
                                  }
                                  // 여기서 이 전 창을 닫고가야 provider가 꼬이는 일이 없음
                                  Navigator.of(context).pop();
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: communityViewModel.getCommunityList[idx])));
                                },
                              ),
                            ),
                            const CustomDivider(height: 1.0, color: Colors.grey,),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 10.0,),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
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

                              },
                              child: Text(
                                '목록',
                                style: Theme.of(context).textTheme.bodyMedium,
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
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                // 키보드 밖 클릭 시 키보드 닫기
                FocusManager.instance.primaryFocus?.unfocus();
              },
            );
          }
        },
      ),
    );
  }
}
