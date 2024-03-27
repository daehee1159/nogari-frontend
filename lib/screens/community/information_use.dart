import 'package:flutter/material.dart';
import 'package:nogari/widgets/community/copyright_and_liability.dart';
import 'package:nogari/widgets/community/delete_board.dart';

class InformationUse extends StatefulWidget {
  const InformationUse({super.key});

  @override
  State<InformationUse> createState() => _InformationUseState();
}

class _InformationUseState extends State<InformationUse> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '이용안내',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xff33D679),
              unselectedLabelColor: Colors.grey,
              unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
              labelStyle: Theme.of(context).textTheme.bodyMedium,
              onTap: (int index) {

              },
              tabs: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "저작권 및 책임",
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: const Text(
                    "게시물 삭제",
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                SingleChildScrollView(child: _buildTabContent(context, 0),),
                SingleChildScrollView(child: _buildTabContent(context, 1),),
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
        return const CopyrightAndLiability();
      case 1:
        return const DeleteBoard();
      default:
        return Container();
    }
  }
}
