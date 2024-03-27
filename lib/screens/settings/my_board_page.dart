import 'package:flutter/material.dart';

import '../../widgets/common/board_card.dart';

class MyBoardPage extends StatefulWidget {
  const MyBoardPage({super.key});

  @override
  State<MyBoardPage> createState() => _MyBoardPageState();
}

class _MyBoardPageState extends State<MyBoardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '내가 쓴 글 보기',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: const [
            BoardCard(type: 'community', widgetTitle: '커뮤니티 게시판',),
            BoardCard(type: 'review', widgetTitle: '리뷰 게시판',),
          ],
        ),
      ),
    );
  }
}
