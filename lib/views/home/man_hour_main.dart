import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository_impl.dart';
import 'package:nogari/views/man_hour/man_hour_history.dart';
import 'package:nogari/views/man_hour/man_hour_screen.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/widgets/common/banner_ad_widget.dart';
import 'package:provider/provider.dart';

import '../../models/man_hour/man_hour.dart';

class ManHourMain extends StatefulWidget {
  const ManHourMain({super.key});

  @override
  State<ManHourMain> createState() => _ManHourMainState();
}

class _ManHourMainState extends State<ManHourMain> {
  final ManHourRepository _manHourRepository = ManHourRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);

    double deviceHeight = MediaQuery.of(context).size.height;
    bool isSized1700 = deviceHeight > 1700;
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: isSized1700 ? MediaQuery.of(context).size.height * 0.23 : MediaQuery.of(context).size.height * 0.22,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 4.0,
                    child: Container(
                      color: const Color(0xffF0FEEE),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '공수달력',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: const Color(0xff33D679)),
                                  ),
                                  TextSpan(
                                    text: '을 통해 언제 어디서든',
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ]
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Text(
                              '손쉽게 공수계산을 해보세요!',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ],
            ),
            Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: isSized1700 ? MediaQuery.of(context).size.height * 0.23 : MediaQuery.of(context).size.height * 0.22,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 4.0,
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '공수달력 바로가기',
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                          const Icon(
                                            Icons.keyboard_arrow_right,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                        child: Text(
                                          '공수달력을 통해',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Text(
                                          '한눈에 확인해보세요.',
                                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Column(
                                        children: [
                                          IconButton(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 20),
                                            onPressed: () async {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourScreen()));
                                            },
                                            icon: SizedBox(
                                              width: MediaQuery.of(context).size.width * 0.3,
                                              height: MediaQuery.of(context).size.height * 0.12,
                                              child: OverflowBox(
                                                minHeight: MediaQuery.of(context).size.height * 0.12,
                                                maxHeight: MediaQuery.of(context).size.height * 0.12,
                                                minWidth: MediaQuery.of(context).size.width * 0.3,
                                                maxWidth: MediaQuery.of(context).size.width * 0.3,
                                                child: Icon(
                                                  Icons.calendar_month,
                                                  size: MediaQuery.of(context).size.height * 0.08,
                                                  color: const Color(0xff33D679),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              )
                            ],
                          )
                        ],
                      ),
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourScreen()));
                      },
                    )
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: isSized1700 ? MediaQuery.of(context).size.height * 0.23 : MediaQuery.of(context).size.height * 0.22,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    elevation: 4.0,
                    child: InkWell(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '공수달력 이력보기',
                                              style: Theme.of(context).textTheme.headlineSmall,
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Colors.black,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                                          child: Text(
                                            '등록한 공수 달력의',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                          child: Text(
                                            '이력을 확인해보세요.',
                                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            IconButton(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 20),
                                              onPressed: () async {
                                                List<ManHour> manHourDtoList = await _manHourRepository.getManHourList();
                                                manHourViewModel.setManHourList = manHourDtoList;
                                                Future.microtask(() => manHourViewModel.callNotify());
                                                if (mounted) {
                                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourHistory()));
                                                }
                                              },
                                              icon: SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.3,
                                                height: MediaQuery.of(context).size.height * 0.12,
                                                child: OverflowBox(
                                                  minHeight: MediaQuery.of(context).size.height * 0.12,
                                                  maxHeight: MediaQuery.of(context).size.height * 0.12,
                                                  minWidth: MediaQuery.of(context).size.width * 0.3,
                                                  maxWidth: MediaQuery.of(context).size.width * 0.3,
                                                  child: Icon(
                                                    FontAwesomeIcons.clockRotateLeft,
                                                    size: MediaQuery.of(context).size.height * 0.08,
                                                    color: const Color(0xff33D679),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                              )
                            ],
                          )
                        ],
                      ),
                      onTap: () async {
                        List<ManHour> manHourDtoList = await _manHourRepository.getManHourList();
                        manHourViewModel.setManHourList = manHourDtoList;
                        Future.microtask(() => manHourViewModel.callNotify());
                        if (mounted) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourHistory()));
                        }
                      },
                    )
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.03,),
                const BannerAdWidget(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
