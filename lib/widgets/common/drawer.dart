import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/man_hour/insurance_status.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/common/app_version_provider.dart';
import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour_provider.dart';
import '../../models/member/member_info_provider.dart';
import '../../models/member/level_provider.dart';
import '../../screens/home/scientificCalCulator.dart';

class CommonDrawer extends StatelessWidget {
  const CommonDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    LevelProvider levelProvider = Provider.of<LevelProvider>(context, listen: false);
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    AppVersionProvider appVersionProvider = Provider.of<AppVersionProvider>(context, listen: false);

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
                    'Lv ${levelProvider.getLevel}. ${memberInfoProvider.getNickName}',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                    softWrap: true,
                    maxLines: 2,
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Point : ${levelProvider.getPoint}P',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '다음 레벨까지 남은 포인트 : ${100 - levelProvider.getPoint}P',
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
              manHourProvider.toggleInsuranceStatus();
              pref.setBool(Glob.insuranceStatus, manHourProvider.getInsuranceStatus);
            },
          ),
          const CustomDivider(height: 1.0, color: Colors.grey,),
          if (Platform.isAndroid)
            ListTile(
              title: Text('앱 버전', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
              trailing: (appVersionProvider.getAppVersion!.android.toString() == appVersionProvider.getCurrentAppVersion.toString()) ?
              Text('v${appVersionProvider.getAppVersion!.android}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),) :
              Text('업데이트 필요', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),),
              onTap: () {
              },
            ),
          if (Platform.isIOS)
            ListTile(
              title: Text('앱 버전', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold)),
              trailing: (appVersionProvider.getAppVersion!.ios.toString() == appVersionProvider.getCurrentAppVersion.toString()) ?
              Text('v${appVersionProvider.getAppVersion!.ios}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),) :
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
