import 'package:flutter/material.dart';
import 'package:nogari/services/member_service.dart';
import 'package:provider/provider.dart';

import '../../models/member/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final MemberService memberService = MemberService();

  @override
  Widget build(BuildContext context) {
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '알림',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: FutureBuilder(
              future: memberService.getNotification(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: CircularProgressIndicator(color: Color(0xff33D679),))
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
                  notificationProvider.setNotificationList = snapshot.data;

                  return Container(
                    // height: MediaQuery.of(context).size.height * 1.0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: notificationProvider.getNotificationList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Material(
                                  // color: Colors.grey,
                                  child: InkWell(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.1,
                                      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Row(
                                              children: [
                                                Text('$index.', style: Theme.of(context).textTheme.bodyMedium,),
                                                const SizedBox(width: 10.0),
                                                Text(notificationProvider.getNotificationList[index].message, style: Theme.of(context).textTheme.bodyMedium,),
                                              ],
                                            ),
                                            // color: Colors.grey,
                                          ),
                                          const SizedBox(height: 5,),
                                          Container(
                                            width: double.infinity,
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text(
                                              notificationProvider.getNotificationList[index].regDt.substring(0, 10),
                                              style: Theme.of(context).textTheme.bodyMedium,
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    onTap: () {
                                      // Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityDetailPage(community: _manHourProvider.getCommunityList[index])));
                                    },
                                  ),
                                ),
                                Container(
                                  height: 1.0,
                                  color: Colors.grey,
                                )
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          );
        }
      )
    );
  }
}
