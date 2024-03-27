import 'package:flutter/material.dart';
import 'package:nogari/models/man_hour/man_hour_dto.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/services/man_hour_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour_provider.dart';

class ManHourAlert {
  final CommonAlert commonAlert = CommonAlert();
  final CommonService commonService = CommonService();
  final ManHourService manHourService = ManHourService();

  void bulkDeleteManHour(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '공수 달력 삭제',
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        content: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_outlined,
                      color: Colors.red,
                      size: 30,
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      '삭제 후 복구는 불가능합니다.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
                const SizedBox(height: 10,),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextButton.icon(
                        icon: const Icon(Icons.calendar_month, color: Colors.black,),
                        label: Text(
                          '기간선택',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        onPressed: () async {
                          String datetime = "";
                          List<dynamic> selectList = [];
                          List<String> toStringList = [];
                          List<dynamic> eatSignalList = [];
                          DateTime currentDate = DateTime.now();
                          bool isCanceled = true;

                          Future<void> selectDate(BuildContext context) async {
                            final DateTimeRange? pickedDate = await showDateRangePicker(
                              context: context,
                              currentDate: DateTime.now(),
                              locale: const Locale('ko'),
                              helpText: "",
                              firstDate: DateTime(2022),
                              lastDate: DateTime(2050),
                              saveText: "선택",
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xff33D679),
                                      onPrimary: Colors.black,
                                    ),
                                    dialogBackgroundColor:Colors.white,
                                  ),
                                  child: child as Widget,
                                );
                              },
                            );
                            /// (pickedDate == null) = 취소 버튼 누름
                            if (pickedDate == null) {
                              isCanceled = false;
                            } else {
                              datetime = pickedDate.toString().substring(0, 10);

                              DateTime startDate = DateTime(pickedDate.start.year, pickedDate.start.month, pickedDate.start.day);
                              DateTime endDate = DateTime(pickedDate.end.year, pickedDate.end.month, pickedDate.end.day);

                              List<DateTime> daysInBetweenList = commonService.getDaysInBetween(startDate, endDate);

                              /// 초기화
                              selectList = [];
                              toStringList = [];

                              for (var i = 0; i < eatSignalList.length; i++) {
                                DateTime diff = DateTime.parse(eatSignalList[i].regDt.toString().substring(0, 10));
                                for (var j = 0; j < daysInBetweenList.length; j++) {
                                  if (diff == daysInBetweenList[j]) {
                                    selectList.add(eatSignalList[i]);
                                  }
                                }
                              }
                              String period = manHourProvider.dateTimeToPeriod('period', startDate, endDate);
                              manHourProvider.setStartDt = startDate;
                              manHourProvider.setEndDt = endDate;
                              for (int i = 0; i < daysInBetweenList.length; i++) {
                                String toStringDateTime = daysInBetweenList[i].toString().substring(0, 10);
                                if (!toStringList.contains(toStringDateTime)) {
                                  toStringList.add(toStringDateTime);
                                }
                              }
                              manHourProvider.setDateList = [];
                              manHourProvider.setDateList = toStringList;
                              manHourProvider.setSelectedPeriod = 'period';
                              manHourProvider.setPeriod = period;
                            }
                          }
                          await selectDate(context);
                          // setState(() {
                          //   _tabController.index = 3;
                          // });
                        },
                      )
                    ),
                    Expanded(
                      flex: 5,
                      child: Consumer<ManHourProvider>(
                        builder: (context, provider, _) {
                          return Text(
                            manHourProvider.period,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: (manHourProvider.period == '미선택') ? Colors.grey : Colors.black),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              '삭제',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () async {
              SharedPreferences pref = await SharedPreferences.getInstance();
              var memberSeq = pref.getInt(Glob.memberSeq);

              /// 선택된 날짜에서 현재 리스트와 날짜가 같은것을 분류
              List<ManHourDto> manHourDtoList = manHourProvider.events.where((event) {
                return manHourProvider.getDateList.contains(event.startDt.substring(0, 10)) &&
                    event.isHoliday == 'N';
              }).toList();

              // 삭제 api 호출
              bool result = await manHourService.deleteManHour(manHourDtoList);

              if (result) {
                // api 성공 시 현재 리스트에서 삭제 리스트 제외
                manHourProvider.events.removeWhere((event) {
                  return manHourDtoList.any((manHourDto) => event.manHourSeq == manHourDto.manHourSeq);
                });

                List<ManHourDto> minusList = [];

                for (int i = 0; i < manHourDtoList.length; i++) {
                  /// manHourDtoList 의 각 객체 변수들은 final 이라서 바로 변경 불가
                  ManHourDto manHourDto = ManHourDto(
                    manHourSeq: manHourProvider.getManHourSeq,
                    memberSeq: memberSeq!.toInt(),
                    startDt: manHourDtoList[i].startDt.substring(0, 10), endDt: manHourDtoList[i].endDt.substring(0, 10),
                    totalAmount: -manHourDtoList[i].totalAmount, manHour: -manHourDtoList[i].manHour, unitPrice: -manHourDtoList[i].unitPrice, etcPrice: -manHourDtoList[i].etcPrice, memo: manHourDtoList[i].memo,
                    isHoliday: 'N'
                  );
                  minusList.add(manHourDto);
                }

                manHourProvider.currentFetchData(minusList);
                String period = manHourProvider.dateTimeToPeriod('init', null, null);
                manHourProvider.setPeriod = period;
                manHourProvider.setSelectedPeriod = null;
                manHourProvider.initData();
                manHourProvider.initDateList();
                Future.microtask(() => manHourProvider.callNotify());
                if (context.mounted) {
                  commonAlert.deleteComplete(context);
                }
              } else {
                // 실패 alert
                if (context.mounted) {
                  commonAlert.errorAlert(context);
                }
              }
            },
          ),
          TextButton(
            child: Text(
              '취소',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onPressed: () {
              manHourProvider.initData();
              manHourProvider.initDateList();

              String period = manHourProvider.dateTimeToPeriod('init', null, null);
              manHourProvider.setPeriod = period;
              manHourProvider.setSelectedPeriod = null;

              manHourProvider.setExceptSat = false;
              manHourProvider.setExceptSun = false;
              manHourProvider.setExceptHol = false;

              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }

  void dateAlreadyRegistered(BuildContext context, List<String> dateList) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이미 등록된 날짜가 포함되어 있습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SingleChildScrollView(
                child: Column(
                  children: dateList.map((date) => Text(date)).toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(
                '확인',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  void validateManHour(BuildContext context, String text) {
    switch (text) {
      case 'manHour':
        text = '공수를 입력해주세요.';
        break;
      case 'unitPrice':
        text = '단가를 입력해주세요.';
        break;
      case 'date':
        text = '날짜를 선택해주세요.';
        break;
    }

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            text,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                '확인',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

}
