import 'package:flutter/material.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/viewmodels/member/block_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/member/member_alert.dart';
import 'package:provider/provider.dart';
import '../../models/member/block.dart';

class BlockListPage extends StatelessWidget {
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final MemberAlert _memberAlert = MemberAlert();
  final CommonAlert _commonAlert = CommonAlert();
  BlockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final blockViewModel = Provider.of<BlockViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '차단 목록',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            blockViewModel.selectedItems.clear();
            blockViewModel.callNotify();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              List<Block> removeList = [];

              for (int selectedItemIndex in blockViewModel.selectedItems) {
                removeList.add(blockViewModel.getBlockDtoList[selectedItemIndex]);
              }

              bool result = await _memberRepository.deleteBlockMember(removeList);

              if (result) {
                for (int i = 0; i < removeList.length; i++) {
                  blockViewModel.removeBlockList(removeList[i]);
                }
                blockViewModel.selectedItems.clear();
                blockViewModel.callNotify();
                if (context.mounted) {
                  _memberAlert.successUnBlockMember(context);
                }
              } else {
                  if (context.mounted) {
                    _commonAlert.errorAlert(context);
                  }
              }
            },
            child: Text(
              '삭제',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body:
      (blockViewModel.getBlockDtoList.isEmpty) ?
      SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                '차단된 유저가 없습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            )
          ],
        ),
      ):
      Consumer<BlockViewModel>(
        builder: (context, viewModel, _) {
          return ListView.builder(
            itemCount: viewModel.getBlockDtoList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    key: ValueKey<int>(index),
                    padding: const EdgeInsets.all(10),
                    child: CheckboxListTile(
                      title: Text(
                        viewModel.getBlockDtoList[index].blockMemberNickname,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: viewModel.selectedItems.contains(index),
                      onChanged: (value) {
                        if (value != null && value) {
                          viewModel.selectedItems.add(index);
                          viewModel.callNotify();
                        } else {
                          viewModel.selectedItems.remove(index);
                          viewModel.callNotify();
                        }
                      },
                      secondary: Text(
                        '닉네임 : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  const CustomDivider(height: 1, color: Colors.grey)
                ],
              );
            },
          );
        },
      ),
    );
  }
}

