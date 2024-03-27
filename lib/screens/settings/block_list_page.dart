import 'package:flutter/material.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/member/member_alert.dart';
import 'package:provider/provider.dart';
import '../../models/member/block_dto.dart';
import '../../models/member/block_provider.dart';

class BlockListPage extends StatelessWidget {
  const BlockListPage({super.key});

  @override
  Widget build(BuildContext context) {
    BlockProvider blockProvider = Provider.of<BlockProvider>(context, listen: false);
    MemberService memberService = MemberService();
    MemberAlert memberAlert = MemberAlert();
    CommonAlert commonAlert = CommonAlert();

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
            blockProvider.selectedItems.clear();
            blockProvider.callNotify();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              List<BlockDto> removeList = [];

              for (int selectedItemIndex in blockProvider.selectedItems) {
                removeList.add(blockProvider.getBlockDtoList[selectedItemIndex]);
              }

              bool result = await memberService.deleteBlockMember(removeList);

              if (result) {
                for (int i = 0; i < removeList.length; i++) {
                  blockProvider.removeBlockList(removeList[i]);
                }
                blockProvider.selectedItems.clear();
                blockProvider.callNotify();
                if (context.mounted) {
                  memberAlert.successUnBlockMember(context);
                }
              } else {
                  if (context.mounted) {
                    commonAlert.errorAlert(context);
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
      (blockProvider.getBlockDtoList.isEmpty) ?
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
      Consumer<BlockProvider>(
        builder: (context, provider, _) {
          return ListView.builder(
            itemCount: blockProvider.getBlockDtoList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  Padding(
                    key: ValueKey<int>(index),
                    padding: const EdgeInsets.all(10),
                    child: CheckboxListTile(
                      title: Text(
                        blockProvider.getBlockDtoList[index].blockMemberNickname,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      value: blockProvider.selectedItems.contains(index),
                      onChanged: (value) {
                        if (value != null && value) {
                          blockProvider.selectedItems.add(index);
                          blockProvider.callNotify();
                        } else {
                          blockProvider.selectedItems.remove(index);
                          blockProvider.callNotify();
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

