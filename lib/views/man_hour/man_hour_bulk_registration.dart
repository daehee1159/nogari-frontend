import 'package:flutter/material.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository_impl.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:nogari/widgets/common/custom.divider.dart';
import 'package:nogari/widgets/man_hour/man_hour_alert.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour.dart';
import '../../widgets/man_hour/man_hour_checkbox.dart';

class ManHourBulkRegistration extends StatefulWidget {
  const ManHourBulkRegistration({super.key});

  @override
  State<ManHourBulkRegistration> createState() => _ManHourBulkRegistrationState();
}

class _ManHourBulkRegistrationState extends State<ManHourBulkRegistration> {
  final ManHourRepository _manHourRepository = ManHourRepositoryImpl();
  final ManHourAlert _manHourAlert = ManHourAlert();
  final CommonAlert _commonAlert = CommonAlert();
  final CommonService _commonService = CommonService();
  @override
  Widget build(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);

    TextEditingController manHourController = TextEditingController(text: manHourViewModel.getManHourAmount.toString());
    TextEditingController unitPriceController = TextEditingController(text: manHourViewModel.unitPriceAmount.toString());
    TextEditingController etcPriceController = TextEditingController(text: manHourViewModel.etcPriceAmount.toString());
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
        ),
      ),
      body: SingleChildScrollView(
        child: Consumer<ManHourViewModel>(
          builder: (context, viewModel, _) {
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
                                      viewModel.setManHourAmount = -1;
                                      viewModel.addTotalAmount();
                                      manHourController.text = viewModel.manHourAmount.toString();
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
                                        viewModel.manHourAmount = parsedValue;
                                        viewModel.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      viewModel.setManHourAmount = 1;
                                      viewModel.addTotalAmount();
                                      manHourController.text = viewModel.manHourAmount.toString();
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
                                      viewModel.setUnitPriceAmount = -10000;
                                      viewModel.addTotalAmount();
                                      unitPriceController.text = viewModel.unitPriceAmount.toString();
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
                                        viewModel.unitPriceAmount = parsedValue;
                                        viewModel.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      viewModel.setUnitPriceAmount = 10000;
                                      viewModel.addTotalAmount();
                                      unitPriceController.text = viewModel.unitPriceAmount.toString();
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
                                      viewModel.setEtcPriceAmount = -10000;
                                      viewModel.addTotalAmount();
                                      etcPriceController.text = viewModel.etcPriceAmount.toString();
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
                                        viewModel.etcPriceAmount = parsedValue;
                                        viewModel.addTotalAmount();
                                      }
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () {
                                      viewModel.setEtcPriceAmount = 10000;
                                      viewModel.addTotalAmount();
                                      etcPriceController.text = viewModel.etcPriceAmount.toString();
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
                                  child: Consumer<ManHourViewModel>(
                                    builder: (context, viewModel, _) {
                                      return Text(
                                        viewModel.totalAmount.round().toString(),
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: (viewModel.totalAmount == 0.0) ? Colors.grey : Colors.black),
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
                                  child: Consumer<ManHourViewModel>(
                                    builder: (context, viewModel, _) {
                                      return Text(
                                        viewModel.period,
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
                                        String period = viewModel.dateTimeToPeriod('date', pickedDate, pickedDate);
                                        viewModel.setStartDt = pickedDate;
                                        viewModel.setEndDt = pickedDate;
                                        if (!viewModel.getDateList.contains(datetime)) {
                                          viewModel.setDateList = [];
                                          viewModel.addDataList(datetime);
                                        }
                                        viewModel.setSelectedPeriod = 'date';
                                        viewModel.setPeriod = period;
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
                                        String period = viewModel.dateTimeToPeriod('period', startDate, endDate);
                                        viewModel.setStartDt = startDate;
                                        viewModel.setEndDt = endDate;
                                        for (int i = 0; i < daysInBetweenList.length; i++) {
                                          String toStringDateTime = daysInBetweenList[i].toString().substring(0, 10);
                                          if (!toStringList.contains(toStringDateTime)) {
                                            toStringList.add(toStringDateTime);
                                          }
                                        }
                                        viewModel.setDateList = [];
                                        viewModel.setDateList = toStringList;
                                        viewModel.setSelectedPeriod = 'period';
                                        viewModel.setPeriod = period;
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
                                    List<ManHour> manHourList = [];

                                    bool hasMatchingStartDt = viewModel.events.any((event) => viewModel.getDateList.any((date) => event.startDt.substring(0, 10) == date && event.isHoliday == 'N'));

                                    if (hasMatchingStartDt) {
                                      List<String> duplicatedStartDtList = viewModel.events
                                          .where((event) => viewModel.getDateList
                                          .any((date) => event.startDt.substring(0, 10) == date && event.isHoliday == 'N'))
                                          .map((event) => event.startDt.substring(0, 10))
                                          .toList();
                                      if (context.mounted) {
                                        viewModel.setDateList = [];
                                        return _manHourAlert.dateAlreadyRegistered(context, duplicatedStartDtList);
                                      }
                                    } else {
                                      // 중복 없음
                                    }

                                    // 공수0 아니고 단가0 아니고 기간 선택했을 경우만 등록
                                    if (viewModel.getManHourAmount == 0 && context.mounted) {
                                      return _manHourAlert.validateManHour(context, 'manHour');
                                    } else if (viewModel.getUnitPriceAmount == 0 && context.mounted) {
                                      return _manHourAlert.validateManHour(context, 'unitPrice');
                                    } else if (viewModel.getSelectedPeriod == null && context.mounted) {
                                      return _manHourAlert.validateManHour(context, 'date');
                                    } else {
                                      // 토,일,공휴일 제외 옵션 확인
                                      List<String> resultDateList = viewModel.getDateList;

                                      if (viewModel.getExceptSat) {
                                        for (int i = 0; i < viewModel.getDateList.length; i++) {
                                          DateTime date = DateTime.parse(viewModel.getDateList[i]);
                                          if (date.toLocal().weekday == DateTime.saturday) {
                                            resultDateList.removeWhere((element) => element == viewModel.getDateList[i]);
                                          }
                                        }
                                      }

                                      if (viewModel.getExceptSun) {
                                        for (int i = 0; i < viewModel.getDateList.length; i++) {
                                          DateTime date = DateTime.parse(viewModel.getDateList[i]);
                                          if (date.toLocal().weekday == DateTime.sunday) {
                                            resultDateList.removeWhere((element) => element == viewModel.getDateList[i]);
                                          }
                                        }
                                      }

                                      if (viewModel.getExceptHol) {
                                        List<String> holidayList = [];
                                        for (int i = 0; i < viewModel.events.length; i++) {
                                          if (viewModel.events[i].isHoliday == 'Y') {
                                            holidayList.add(viewModel.events[i].startDt);
                                          }
                                        }

                                        for (int i = 0; i < holidayList.length; i++) {
                                          for (int j = 0; j < viewModel.getDateList.length; j++) {
                                            if (holidayList[i].substring(0, 10) == viewModel.getDateList[j]) {
                                              resultDateList.removeWhere((element) => element == viewModel.getDateList[j]);
                                            }
                                          }
                                        }
                                      }

                                      viewModel.setDateList = resultDateList;

                                      // 여기서 이제 등록 api 진행
                                      for (int i = 0; i < viewModel.getDateList.length; i++) {
                                        ManHour manHour = ManHour(
                                          // 어짜피 백엔드에서 set 할 때 manHourSeq 는 mapper에서 알아서 빼서 AI 함
                                            manHourSeq: 0,
                                            memberSeq: memberSeq!.toInt(),
                                            startDt: viewModel.getDateList[i], endDt: viewModel.getDateList[i],
                                            totalAmount: viewModel.getTotalAmount, manHour: viewModel.getManHourAmount, unitPrice: viewModel.getUnitPriceAmount, etcPrice: viewModel.getEtcPriceAmount, memo: viewModel.getMemo.toString(),
                                            isHoliday: 'N'
                                        );

                                        if (!manHourList.contains(manHour)) {
                                          manHourList.add(manHour);
                                        }
                                      }
                                    }

                                    bool result = await _manHourRepository.setManHour(manHourList);

                                    if (result) {
                                      // 성공 후 현재 events 에 넣어줘야함
                                      for (int i = 0; i < manHourList.length; i++) {
                                        viewModel.addEvent(manHourList[i]);
                                      }

                                      String period = viewModel.dateTimeToPeriod('init', null, null);
                                      viewModel.setPeriod = period;
                                      viewModel.setSelectedPeriod = null;
                                      viewModel.initData();
                                      viewModel.initDateList();
                                      Future.microtask(() => viewModel.callNotify());

                                      if (manHourList.length == 1 && context.mounted) {
                                        viewModel.currentFetchData(manHourList);
                                        return _commonAlert.setRegistration(context);
                                      } else {
                                        if (context.mounted) {
                                          return _commonAlert.setPeriodRegistration(context);
                                        }
                                      }
                                    } else {
                                      // 실패 alert
                                      if (context.mounted) {
                                        return _commonAlert.errorAlert(context);
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
                                    viewModel.initData();
                                    viewModel.initDateList();

                                    String period = viewModel.dateTimeToPeriod('init', null, null);
                                    viewModel.setPeriod = period;
                                    viewModel.setSelectedPeriod = null;

                                    viewModel.setExceptSat = false;
                                    viewModel.setExceptSun = false;
                                    viewModel.setExceptHol = false;

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
