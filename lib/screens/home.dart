import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:nogari/models/common/app_version_provider.dart';
import 'package:nogari/models/global/global_variable.dart';
import 'package:nogari/screens/community/paging_community.dart';
import 'package:nogari/screens/home/home_page.dart';
import 'package:nogari/screens/home/man_hour_main.dart';
import 'package:nogari/screens/home/notification_page.dart';
import 'package:nogari/screens/review/paging_review.dart';
import 'package:nogari/screens/settings/settings.dart';
import 'package:nogari/widgets/common/drawer.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/community/community_provider.dart';

final getIt = GetIt.instance;

class Home extends StatefulWidget {
  final int currentIndex;
  const Home({required this.currentIndex, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late int _currentIndex;
  // 페이지 리스트
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pages = [
      const HomePage(),
      const PagingCommunity(),
      const ManHourMain(),
      const PagingReview(),
      const Settings(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    CommunityProvider communityProvider = Provider.of<CommunityProvider>(context, listen: false);
    AppVersionProvider appVersionProvider = Provider.of<AppVersionProvider>(context, listen: false);

    /// 앱 버전 체크
    Future.microtask(() async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      if(mounted && appVersionProvider.getAppVersion!.android != packageInfo.version) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Icon(
                Icons.warning_amber_outlined,
                color: Colors.red,
                size: 50,
              ),
              content: Text(
                '앱 버전 업데이트가\n필요합니다.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  child: Text(
                    '확인',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  onPressed: () async {
                    String uri = '';

                    if (Platform.isIOS) {
                      uri = Glob.appStoreUrl;
                    } else {
                      uri = Glob.playStoreUrl;
                    }

                    if (await canLaunchUrl(Uri.parse(uri))) {
                      await launchUrl(Uri.parse(uri));
                    } else {
                      throw 'Could not launch url';
                    }

                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            )
        );
      }
    });

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        return;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Image.asset(
              'images/nogari_icon_kr_width.png',
              height: MediaQuery.of(context).size.height * 0.15,
              fit: BoxFit.contain,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                FontAwesomeIcons.bell,
                size: 24,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
              },
            )
          ],
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.keyboard),
              label: '커뮤니티',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: '공수달력',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star),
              label: '업체리뷰',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
          selectedItemColor: const Color(0xff33D679),
          // 액티브 시 색상 설정
          onTap: (index) {
            communityProvider.initPageData();
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        drawer: const CommonDrawer(),
      ),
    );
  }
}
