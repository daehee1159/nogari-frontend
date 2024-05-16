import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/common/app_version_viewmodel.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/viewmodels/member/level_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/man_hour/insurance_status.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../views/home/scientificCalCulator.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final levelViewModel = Provider.of<LevelViewModel>(context, listen: false);
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);
    final appVersionViewModel = Provider.of<AppVersionViewModel>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff33D679),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lv ${levelViewModel.getLevel}. ${memberViewModel.getNickName}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Point : ${levelViewModel.getPoint}P',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '다음 레벨까지 남은 포인트 : ${100 - levelViewModel.getPoint}P',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(
              '닉네임 변경하기',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Item 1을 선택하면 할 작업을 여기에 추가
            },
          ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
          ListTile(
            title: Text(
              '내가 쓴 글 보기',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              // Item 2를 선택하면 할 작업을 여기에 추가
            },
          ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
          ListTile(
            title: Text(
              '공학용 계산기',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ScientificCalculator()));
            },
          ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
          ListTile(
            title: Text(
              '4대보험 가입여부',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)
            ),
            trailing: const InsuranceStatus(),
            onTap: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              manHourViewModel.toggleInsuranceStatus();
              pref.setBool(Glob.insuranceStatus, manHourViewModel.getInsuranceStatus);
            },
          ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
          if (Platform.isAndroid)
            ListTile(
              title: Text('앱 버전', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
              trailing: (appVersionViewModel.getAppVersion!.android.toString() == appVersionViewModel.getCurrentAppVersion.toString()) ?
              Text('v${appVersionViewModel.getAppVersion!.android}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),) :
              Text('업데이트 필요', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),),
              onTap: () {
              },
            ),
          if (Platform.isIOS)
            ListTile(
              title: Text('앱 버전', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
              trailing: (appVersionViewModel.getAppVersion!.ios.toString() == appVersionViewModel.getCurrentAppVersion.toString()) ?
              Text('v${appVersionViewModel.getAppVersion!.ios}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),) :
              Text('업데이트 필요', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),),
              onTap: () {
              },
            ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
        ],
      ),
    );
  }
}
