import 'package:cell_calendar/cell_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nogari/models/man_hour/man_hour_dto.dart';
import 'package:nogari/screens/man_hour/man_hour_bulk_registration.dart';
import 'package:nogari/screens/man_hour/man_hour_registration.dart';
import 'package:nogari/screens/man_hour/man_hour_update.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/services/man_hour_service.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/man_hour/man_hour_alert.dart';
import 'package:provider/provider.dart';

import '../../models/man_hour/man_hour_provider.dart';
import '../../widgets/man_hour/man_hour_statistics.dart';

class ManHourScreen extends StatefulWidget {
  const ManHourScreen({super.key});

  @override
  State<ManHourScreen> createState() => _ManHourScreenState();
}

class _ManHourScreenState extends State<ManHourScreen> {
  @override
  void initState() {
    super.initState();
  }
  bool extended = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          '공수 달력',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: ManHourService().getManHourList(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xff33D679),)
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
            List<ManHourDto> manHourDtoList = snapshot.data;
            manHourProvider.setManHourList = manHourDtoList;

            final cellCalendarPageController = CellCalendarPageController();

            double totalMonthlyAmount = 0.0;
            double totalMonthlyManHour = 0.0;
            int avgMonthlyUnitPrice = 0;
            int totalMonthlyEtcPrice = 0;

            DateTime now = DateTime.now();
            for (int i = 0; i < manHourProvider.events.length; i++) {
              if (DateTime.parse(manHourProvider.events[i].startDt).year == now.year && DateTime.parse(manHourProvider.events[i].startDt).month == now.month && manHourProvider.events[i].isHoliday == 'N') {
                totalMonthlyAmount = totalMonthlyAmount + manHourProvider.events[i].totalAmount;
                totalMonthlyManHour = totalMonthlyManHour + manHourProvider.events[i].manHour;
                avgMonthlyUnitPrice = avgMonthlyUnitPrice + manHourProvider.events[i].unitPrice;
                totalMonthlyEtcPrice = totalMonthlyEtcPrice + manHourProvider.events[i].etcPrice;
              }
            }
            int count = manHourProvider.events.where((element) => DateTime.parse(element.startDt).year == now.year && DateTime.parse(element.startDt).month == now.month && element.isHoliday == 'N').length;

            manHourProvider.setTotalMonthlyAmount = totalMonthlyAmount;
            manHourProvider.setTotalMonthlyManHour = totalMonthlyManHour;
            manHourProvider.setAvgMonthlyUnitPrice = count != 0 ? (avgMonthlyUnitPrice / count).toDouble() : 0.0;
            manHourProvider.setTotalMonthlyEtcPrice = totalMonthlyEtcPrice;

            Future.microtask(() => manHourProvider.callNotify());
            return Container(
              child: Column(
                children: [
                  Flexible(
                    flex: 7,
                    child: Consumer<ManHourProvider>(
                      builder: (context, provider, _) {
                        return CellCalendar(
                          cellCalendarPageController: cellCalendarPageController,
                          events: manHourProvider.events,
                          daysOfTheWeekBuilder: (dayIndex) {
                            final labels = ['일', '월', '화', '수', '목', '금', '토'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Text(
                                labels[dayIndex],
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: (labels[dayIndex] == '토') ? Colors.blue : (labels[dayIndex] == '일') ? Colors.red : Colors.black
                                ),
                                textAlign: TextAlign.center,
                              ),
                            );
                          },
                          monthYearLabelBuilder: (datetime) {
                            final year = datetime!.year.toString();
                            final month = datetime.month;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Text(
                                    "$year년 $month월",
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  TextButton.icon(
                                    icon: const Icon(Icons.add,color: Color(0xff33D679),),
                                    onPressed: () {
                                      /// 공수 달력 추가하기
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourBulkRegistration()));
                                    },
                                    label: Text(
                                      '등록',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.remove,color: Colors.red,),
                                    onPressed: () {
                                      /// 공수 달력 삭제하기
                                      ManHourAlert().bulkDeleteManHour(context);
                                    },
                                    label: Text(
                                      '삭제',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          onCellTapped: (date) {
                            final eventsOnTheDate = manHourProvider.events.where((event) {
                              final eventDate = DateTime.parse(event.startDt);
                              return eventDate.year == date.year &&
                                  eventDate.month == date.month &&
                                  eventDate.day == date.day &&
                                  // isHoliday 가 false 인 이벤트만 필터링
                                  event.isHoliday == 'N';
                            }).toList();

                            if (eventsOnTheDate.isNotEmpty) {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ManHourUpdate(eventsOnTheDate: eventsOnTheDate, date: date)));
                              // ManHourAlert().updateManHour(context, eventsOnTheDate, date);
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ManHourRegistration(eventsOnTheDate: eventsOnTheDate, date: date)));
                              // ManHourAlert().setOneManHour(context, eventsOnTheDate, date);
                            }
                          },
                          onPageChanged: (firstDate, lastDate) {
                            /// 여기는 한 페이지에 보여주는 전체 달의 기간을 말하는 것임 (전월의 뮤트 처리된 날짜부터 다음달의 뮤트 처리된 날짜까지)
                            DateTime middleDate = firstDate.add(Duration(days: (lastDate.difference(firstDate).inDays / 2).round()));

                            double totalMonthlyAmount = 0.0;
                            double totalMonthlyManHour = 0.0;
                            int avgMonthlyUnitPrice = 0;
                            int totalMonthlyEtcPrice = 0;

                            for (int i = 0; i < manHourProvider.events.length; i++) {
                              if (DateTime.parse(manHourProvider.events[i].startDt).year == middleDate.year && DateTime.parse(manHourProvider.events[i].startDt).month == middleDate.month && manHourProvider.events[i].isHoliday == 'N') {
                                totalMonthlyAmount = totalMonthlyAmount + manHourProvider.events[i].totalAmount.toInt();
                                totalMonthlyManHour = totalMonthlyManHour + manHourProvider.events[i].manHour;
                                avgMonthlyUnitPrice = avgMonthlyUnitPrice + manHourProvider.events[i].unitPrice;
                                totalMonthlyEtcPrice = totalMonthlyEtcPrice + manHourProvider.events[i].etcPrice;
                              }
                            }
                            int count = manHourProvider.events.where((element) => DateTime.parse(element.startDt).year == middleDate.year && DateTime.parse(element.startDt).month == middleDate.month && element.isHoliday == 'N').length;

                            manHourProvider.setTotalMonthlyAmount = totalMonthlyAmount;
                            manHourProvider.setTotalMonthlyManHour = totalMonthlyManHour;
                            manHourProvider.setAvgMonthlyUnitPrice = count != 0 ? (avgMonthlyUnitPrice / count).toDouble() : 0.0;
                            manHourProvider.setTotalMonthlyEtcPrice = totalMonthlyEtcPrice;

                            manHourProvider.callNotify();
                          },
                        );
                      },
                    ),
                  ),
                  const CustomDivider(height: 0.5, color: Colors.grey),
                  const Flexible(flex: 2, child: SizedBox())
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
          width: extended ? MediaQuery.of(context).size.width * 0.5 : 70,
          child: extendButton(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  FloatingActionButton extendButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              '이번 달 통계',
              textAlign: TextAlign.center,
            ),
            content: const ManHourStatistics(),
            actions: [
              TextButton(
                child: Text(
                  '확인',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          )
        );
      },
      label: const Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 3),
        child: Text(
          '이번 달 통계',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
            fontFamily: 'NotoSansKR-Medium'
          ),
        ),
      ),
      isExtended: extended,
      icon: const Icon(
        Icons.add,
        size: 30,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),

      /// 텍스트 컬러
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xff33D679),
    );
  }
}
