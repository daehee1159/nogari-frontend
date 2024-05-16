import 'package:flutter/material.dart';
import 'package:nogari/viewmodels/common/app_version_viewmodel.dart';
import 'package:provider/provider.dart';

class AppVersion extends StatelessWidget {
  const AppVersion({super.key});

  @override
  Widget build(BuildContext context) {
    final appVersionViewModel = Provider.of<AppVersionViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '버전 정보',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'images/nogari_icon_big.png',
              height: MediaQuery.of(context).size.height * 0.2,
              // color: const Color(0xffFE9BE6),
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Center(
              child: Text(
                'v${appVersionViewModel.getCurrentAppVersion}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          Center(
            child: Text(
              (appVersionViewModel.getCurrentAppVersion! == appVersionViewModel.getDBAppVersion) ? '최신 버전입니다.' : '업데이트가 필요합니다.',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          )
        ],
      ),
    );
  }
}
