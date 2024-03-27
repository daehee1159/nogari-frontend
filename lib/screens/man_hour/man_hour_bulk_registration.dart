import 'package:flutter/material.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/man_hour/man_hour_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour_dto.dart';
import '../../models/man_hour/man_hour_provider.dart';
import '../../services/man_hour_service.dart';
import '../../widgets/man_hour/man_hour_checkbox.dart';

class ManHourBulkRegistration extends StatefulWidget {
  const ManHourBulkRegistration({super.key});

  @override
  State<ManHourBulkRegistration> createState() => _ManHourBulkRegistrationState();
}

class _ManHourBulkRegistrationState extends State<ManHourBulkRegistration> {
  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    final ManHourAlert manHourAlert = ManHourAlert();
    final CommonAlert commonAlert = CommonAlert();
    final CommonService commonService = CommonService();

    TextEditingController manHourController = TextEditingController(text: manHourProvider.getManHourAmount.toString());
    TextEditingController unitPriceController = TextEditingController(text: manHourProvider.unitPriceAmount.toString());
    TextEditingController etcPriceController = TextEditingController(text: manHourProvider.etcPriceAmount.toString());
    TextEditingController memoController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '공수 달력 등록',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
        ),
      ),
      body: SingleChildScrollView(
        child: Consumer<ManHourProvider>(
          builder: (context, provider, _) {
            return GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SingleChildScrollView(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.transparent,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '공수',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      manHourProvider.setManHourAmount = -1;
                                      manHourProvider.addTotalAmount();
                                      manHourController.text = manHourProvider.manHourAmount.toString();
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: manHourController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    // inputFormatters: [
                                    //   FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                                    // ],
                                    onChanged: (value) {
                                      if (double.tryParse(value) != null) {
                                        double parsedValue = double.tryParse(value) ?? 0.0;
                                        manHourProvider.manHourAmount = parsedValue;
                                        manHourProvider.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      manHourProvider.setManHourAmount = 1;
                                      manHourProvider.addTotalAmount();
                                      manHourController.text = manHourProvider.manHourAmount.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '단가',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      manHourProvider.setUnitPriceAmount = -10000;
                                      manHourProvider.addTotalAmount();
                                      unitPriceController.text = manHourProvider.unitPriceAmount.toString();
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: unitPriceController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (int.tryParse(value) != null) {
                                        int parsedValue = int.tryParse(value) ?? 0;
                                        manHourProvider.unitPriceAmount = parsedValue;
                                        manHourProvider.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      manHourProvider.setUnitPriceAmount = 10000;
                                      manHourProvider.addTotalAmount();
                                      unitPriceController.text = manHourProvider.unitPriceAmount.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '식비 등 기타 비용',
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      manHourProvider.setEtcPriceAmount = -10000;
                                      manHourProvider.addTotalAmount();
                                      etcPriceController.text = manHourProvider.etcPriceAmount.toString();
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: etcPriceController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) {
                                      if (int.tryParse(value) != null) {
                                        int parsedValue = int.tryParse(value) ?? 0;
                                        manHourProvider.etcPriceAmount = parsedValue;
                                        manHourProvider.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      manHourProvider.setEtcPriceAmount = 10000;
                                      manHourProvider.addTotalAmount();
                                      etcPriceController.text = manHourProvider.etcPriceAmount.toString();
                                    },
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: memoController,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                  label: Text(
                                    '메모',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  contentPadding: EdgeInsets.zero,
                                  border: const UnderlineInputBorder()
                              ),
                              onChanged: (value) {
                              },
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '총액',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Consumer<ManHourProvider>(
                                    builder: (context, provider, _) {
                                      return Text(
                                        manHourProvider.totalAmount.round().toString(),
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: (manHourProvider.totalAmount == 0.0) ? Colors.grey : Colors.black),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ),
                                const Expanded(
                                    flex: 1,
                                    child: SizedBox()
                                )
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '기간',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Consumer<ManHourProvider>(
                                    builder: (context, provider, _) {
                                      return Text(
                                        manHourProvider.period,
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      );
                                    },
                                  ),
                                ),
                                const Expanded(flex: 1, child: SizedBox()),
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.calendar_month, color: Colors.black,),
                                  label: Text(
                                    '일자별',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  onPressed: () async {
                                    String datetime = "";
                                    DateTime currentDate = DateTime.now();
                                    bool isCanceled = true;

                                    Future<void> selectDate(BuildContext context) async {
                                      final DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: currentDate,
                                        locale: const Locale('ko'),
                                        helpText: '',
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2050),
                                        builder: (BuildContext context, Widget? child) {
                                          return Theme(
                                            data: ThemeData(
                                              colorScheme: const ColorScheme.light(
                                                brightness: Brightness.light,
                                                onBackground: Colors.white,
                                                primary: Colors.black,
                                                onPrimary: Colors.white,
                                                onSecondary: Colors.black,
                                                background: Colors.white,
                                              ),
                                              dialogBackgroundColor:Colors.white,
                                              shadowColor: Colors.white,
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
                                        String period = manHourProvider.dateTimeToPeriod('date', pickedDate, pickedDate);
                                        manHourProvider.setStartDt = pickedDate;
                                        manHourProvider.setEndDt = pickedDate;
                                        if (!manHourProvider.getDateList.contains(datetime)) {
                                          manHourProvider.setDateList = [];
                                          manHourProvider.addDataList(datetime);
                                        }
                                        manHourProvider.setSelectedPeriod = 'date';
                                        manHourProvider.setPeriod = period;
                                      }
                                    }
                                    await selectDate(context);
                                    // if (isCanceled) {
                                    //   setState(() {
                                    //
                                    //   });
                                    // }
                                  },
                                ),
                                const SizedBox(width: 10,),
                                TextButton.icon(
                                  icon: const Icon(Icons.calendar_month, color: Colors.black,),
                                  label: Text(
                                    '기간별',
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
                                        helpText: '',
                                        firstDate: DateTime(2022),
                                        lastDate: DateTime(2050),
                                        saveText: '선택',
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
                                ),
                              ],
                            ),
                            const SizedBox(height: 10.0,),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Text(
                                '제외 요일',
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ManHourCheckBox(type: 'exceptSat'),
                                ManHourCheckBox(type: 'exceptSun'),
                                ManHourCheckBox(type: 'exceptHol'),
                              ],
                            ),
                            const CustomDivider(height: 1, color: Colors.grey),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    SharedPreferences pref = await SharedPreferences.getInstance();
                                    var memberSeq = pref.getInt(Glob.memberSeq);
                                    List<ManHourDto> manHourDtoList = [];

                                    bool hasMatchingStartDt = manHourProvider.events.any((event) => manHourProvider.getDateList.any((date) => event.startDt.substring(0, 10) == date && event.isHoliday == 'N'));

                                    if (hasMatchingStartDt) {
                                      List<String> duplicatedStartDtList = manHourProvider.events
                                          .where((event) => manHourProvider.getDateList
                                          .any((date) => event.startDt.substring(0, 10) == date && event.isHoliday == 'N'))
                                          .map((event) => event.startDt.substring(0, 10))
                                          .toList();
                                      if (context.mounted) {
                                        manHourProvider.setDateList = [];
                                        return manHourAlert.dateAlreadyRegistered(context, duplicatedStartDtList);
                                      }
                                    } else {
                                      // 중복 없음
                                    }

                                    // 공수0 아니고 단가0 아니고 기간 선택했을 경우만 등록
                                    if (manHourProvider.getManHourAmount == 0 && context.mounted) {
                                      return manHourAlert.validateManHour(context, 'manHour');
                                    } else if (manHourProvider.getUnitPriceAmount == 0 && context.mounted) {
                                      return manHourAlert.validateManHour(context, 'unitPrice');
                                    } else if (manHourProvider.getSelectedPeriod == null && context.mounted) {
                                      return manHourAlert.validateManHour(context, 'date');
                                    } else {
                                      // 토,일,공휴일 제외 옵션 확인
                                      List<String> resultDateList = manHourProvider.getDateList;

                                      if (manHourProvider.getExceptSat) {
                                        for (int i = 0; i < manHourProvider.getDateList.length; i++) {
                                          DateTime date = DateTime.parse(manHourProvider.getDateList[i]);
                                          if (date.toLocal().weekday == DateTime.saturday) {
                                            resultDateList.removeWhere((element) => element == manHourProvider.getDateList[i]);
                                          }
                                        }
                                      }

                                      if (manHourProvider.getExceptSun) {
                                        for (int i = 0; i < manHourProvider.getDateList.length; i++) {
                                          DateTime date = DateTime.parse(manHourProvider.getDateList[i]);
                                          if (date.toLocal().weekday == DateTime.sunday) {
                                            resultDateList.removeWhere((element) => element == manHourProvider.getDateList[i]);
                                          }
                                        }
                                      }

                                      if (manHourProvider.getExceptHol) {
                                        List<String> holidayList = [];
                                        for (int i = 0; i < manHourProvider.events.length; i++) {
                                          if (manHourProvider.events[i].isHoliday == 'Y') {
                                            holidayList.add(manHourProvider.events[i].startDt);
                                          }
                                        }

                                        for (int i = 0; i < holidayList.length; i++) {
                                          for (int j = 0; j < manHourProvider.getDateList.length; j++) {
                                            if (holidayList[i].substring(0, 10) == manHourProvider.getDateList[j]) {
                                              resultDateList.removeWhere((element) => element == manHourProvider.getDateList[j]);
                                            }
                                          }
                                        }
                                      }

                                      manHourProvider.setDateList = resultDateList;

                                      // 여기서 이제 등록 api 진행
                                      for (int i = 0; i < manHourProvider.getDateList.length; i++) {
                                        ManHourDto manHourDto = ManHourDto(
                                          // 어짜피 백엔드에서 set 할 때 manHourSeq 는 mapper에서 알아서 빼서 AI 함
                                            manHourSeq: 0,
                                            memberSeq: memberSeq!.toInt(),
                                            startDt: manHourProvider.getDateList[i], endDt: manHourProvider.getDateList[i],
                                            totalAmount: manHourProvider.getTotalAmount, manHour: manHourProvider.getManHourAmount, unitPrice: manHourProvider.getUnitPriceAmount, etcPrice: manHourProvider.getEtcPriceAmount, memo: manHourProvider.getMemo.toString(),
                                            isHoliday: 'N'
                                        );

                                        if (!manHourDtoList.contains(manHourDto)) {
                                          manHourDtoList.add(manHourDto);
                                        }
                                      }
                                    }

                                    bool result = await ManHourService().setManHour(manHourDtoList);

                                    if (result) {
                                      // 성공 후 현재 events 에 넣어줘야함
                                      for (int i = 0; i < manHourDtoList.length; i++) {
                                        manHourProvider.addEvent(manHourDtoList[i]);
                                      }

                                      String period = manHourProvider.dateTimeToPeriod('init', null, null);
                                      manHourProvider.setPeriod = period;
                                      manHourProvider.setSelectedPeriod = null;
                                      manHourProvider.initData();
                                      manHourProvider.initDateList();
                                      Future.microtask(() => manHourProvider.callNotify());

                                      if (manHourDtoList.length == 1 && context.mounted) {
                                        manHourProvider.currentFetchData(manHourDtoList);
                                        return commonAlert.setRegistration(context);
                                      } else {
                                        if (context.mounted) {
                                          return commonAlert.setPeriodRegistration(context);
                                        }
                                      }
                                    } else {
                                      // 실패 alert
                                      if (context.mounted) {
                                        return commonAlert.errorAlert(context);
                                      }
                                    }
                                  },
                                  child: Text(
                                    '등록',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 10,),
                                TextButton(
                                  child: Text(
                                    '취소',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
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
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
            );
          },
        ),
      )
    );
  }
}
