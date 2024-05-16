import 'package:flutter/material.dart';
import 'package:nogari/views/settings/app_version.dart';
import 'package:nogari/views/settings/block_list_page.dart';
import 'package:nogari/views/settings/change_nickname.dart';
import 'package:nogari/views/settings/my_board_page.dart';
import 'package:nogari/views/settings/withdrawal_page.dart';
import 'package:nogari/viewmodels/common/app_version_viewmodel.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/widgets/common/common_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/global/global_variable.dart';
import '../../widgets/man_hour/insurance_status.dart';
import '../settings/item_card.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  Widget _arrow() {
    return const Icon(
      Icons.arrow_forward_ios,
      size: 20.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appVersionViewModel = Provider.of<AppVersionViewModel>(context, listen: false);
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);
    var brightness = MediaQuery.of(context).platformBrightness;
    return Scaffold(
      body: Container(
        color: const Color(0xFFF7F7F7),
        child: ListView(
          // physics: const NeverScrollableScrollPhysics(),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                color: const Color(0xFFF7F7F7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '내정보',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF999999))
                      ),
                    ),
                    const SizedBox(height: 20,),
                    ItemCard(
                      icon: const Icon(Icons.person),
                      title: '닉네임 변경',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangeNickName()));
                      },
                    ),
                    const SizedBox(height: 10,),
                    ItemCard(
                      icon: const Icon(Icons.keyboard),
                      title: '내가 쓴 글',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBoardPage()));
                      },
                    ),
                    const SizedBox(height: 10,),
                    ItemCard(
                      icon: const Icon(Icons.block),
                      title: '차단 목록',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BlockListPage()));
                      },
                    ),
                    const SizedBox(height: 10,),
                    ItemCard(
                      icon: const Icon(Icons.money),
                      title: '4대보험 가입여부',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: const InsuranceStatus(),
                      textColor: Colors.black,
                      callback: () async {
                        SharedPreferences pref = await SharedPreferences.getInstance();
                        manHourViewModel.toggleInsuranceStatus();
                        pref.setBool(Glob.insuranceStatus, manHourViewModel.getInsuranceStatus);
                      },
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '버전 정보',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF999999))
                      ),
                    ),
                    const SizedBox(height: 20,),
                    ItemCard(
                      icon: const Icon(Icons.check_circle),
                      title: 'version',
                      color: (brightness == Brightness.light) ? Colors.white  : Theme.of(context).scaffoldBackgroundColor,
                      textColor: Colors.black,
                      rightWidget: Center(
                        child: Text(appVersionViewModel.getCurrentAppVersion!,
                          style: Theme.of(context).textTheme.bodyMedium
                        ),
                      ),
                      callback: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AppVersion()));
                      },
                    ),
                    const SizedBox(height: 20,),
                    Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        '약관',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600, color: const Color(0xFF999999))
                      ),
                    ),
                    const SizedBox(height: 20,),
                    ItemCard(
                      icon: const Icon(Icons.file_present),
                      title: '이용약관',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: _arrow(),
                      textColor: Colors.black,
                      callback: () async {
                        if (await canLaunchUrl(Uri.parse(Glob.termsSiteUrl))) {
                        await launchUrl(Uri.parse(Glob.termsSiteUrl));
                        } else {
                        throw 'Could not launch url';
                        }
                      },
                    ),
                    const SizedBox(height: 10,),
                    ItemCard(
                      icon: const Icon(Icons.file_present),
                      title: '개인정보처리방침',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () async {
                        if (await canLaunchUrl(Uri.parse(Glob.privacySiteUrl))) {
                          await launchUrl(Uri.parse(Glob.privacySiteUrl));
                        } else {
                          throw 'Could not launch url';
                        }
                      },
                    ),
                    const SizedBox(height: 40,),
                    ItemCard(
                      icon: const Icon(Icons.question_answer),
                      title: '문의하기',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () {
                        showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(
                                '문의하기',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green
                                ),
                                textAlign: TextAlign.center,
                              ),
                              content: Text(
                                '아래 주소로 문의주세요.\nmsmbizdev@gmail.com',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                TextButton(
                                  child: Text('확인', style: Theme.of(context).textTheme.bodyMedium,),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            )
                        );
                      },
                    ),
                    const SizedBox(height: 10,),
                    ItemCard(
                      icon: const Icon(Icons.cancel),
                      title: '탈퇴하기',
                      color: (brightness == Brightness.light) ? Colors.white : Theme.of(context).scaffoldBackgroundColor,
                      rightWidget: CommonWidget().arrow(),
                      textColor: Colors.black,
                      callback: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const WithdrawalPage()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
