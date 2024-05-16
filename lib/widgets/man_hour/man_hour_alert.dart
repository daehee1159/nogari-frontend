import 'package:flutter/material.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository_impl.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour.dart';

class ManHourAlert {
  final CommonAlert _commonAlert = CommonAlert();
  final CommonService _commonService = CommonService();
  final ManHourRepository _manHourRepository = ManHourRepositoryImpl();

  void bulkDeleteManHour(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);

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

                              List<DateTime> daysInBetweenList = _commonService.getDaysInBetween(startDate, endDate);

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
                              String period = manHourViewModel.dateTimeToPeriod('period', startDate, endDate);
                              manHourViewModel.setStartDt = startDate;
                              manHourViewModel.setEndDt = endDate;
                              for (int i = 0; i < daysInBetweenList.length; i++) {
                                String toStringDateTime = daysInBetweenList[i].toString().substring(0, 10);
                                if (!toStringList.contains(toStringDateTime)) {
                                  toStringList.add(toStringDateTime);
                                }
                              }
                              manHourViewModel.setDateList = [];
                              manHourViewModel.setDateList = toStringList;
                              manHourViewModel.setSelectedPeriod = 'period';
                              manHourViewModel.setPeriod = period;
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
                      child: Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            viewModel.period,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: (viewModel.period == '미선택') ? Colors.grey : Colors.black),
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
              List<ManHour> manHourList = manHourViewModel.events.where((event) {
                return manHourViewModel.getDateList.contains(event.startDt.substring(0, 10)) &&
                    event.isHoliday == 'N';
              }).toList();

              // 삭제 api 호출
              bool result = await _manHourRepository.deleteManHour(manHourList);

              if (result) {
                // api 성공 시 현재 리스트에서 삭제 리스트 제외
                manHourViewModel.events.removeWhere((event) {
                  return manHourList.any((manHourDto) => event.manHourSeq == manHourDto.manHourSeq);
                });

                List<ManHour> minusList = [];

                for (int i = 0; i < manHourList.length; i++) {
                  /// manHourDtoList 의 각 객체 변수들은 final 이라서 바로 변경 불가
                  ManHour manHour = ManHour(
                    manHourSeq: manHourViewModel.getManHourSeq,
                    memberSeq: memberSeq!.toInt(),
                    startDt: manHourList[i].startDt.substring(0, 10), endDt: manHourList[i].endDt.substring(0, 10),
                    totalAmount: -manHourList[i].totalAmount, manHour: -manHourList[i].manHour, unitPrice: -manHourList[i].unitPrice, etcPrice: -manHourList[i].etcPrice, memo: manHourList[i].memo,
                    isHoliday: 'N'
                  );
                  minusList.add(manHour);
                }

                manHourViewModel.currentFetchData(minusList);
                String period = manHourViewModel.dateTimeToPeriod('init', null, null);
                manHourViewModel.setPeriod = period;
                manHourViewModel.setSelectedPeriod = null;
                manHourViewModel.initData();
                manHourViewModel.initDateList();
                Future.microtask(() => manHourViewModel.callNotify());
                if (context.mounted) {
                  _commonAlert.deleteComplete(context);
                }
              } else {
                // 실패 alert
                if (context.mounted) {
                  _commonAlert.errorAlert(context);
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
              manHourViewModel.initData();
              manHourViewModel.initDateList();

              String period = manHourViewModel.dateTimeToPeriod('init', null, null);
              manHourViewModel.setPeriod = period;
              manHourViewModel.setSelectedPeriod = null;

              manHourViewModel.setExceptSat = false;
              manHourViewModel.setExceptSun = false;
              manHourViewModel.setExceptHol = false;

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
