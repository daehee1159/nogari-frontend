import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour_dto.dart';
import '../../models/man_hour/man_hour_provider.dart';
import '../../services/man_hour_service.dart';
import '../../widgets/common/common_alert.dart';
import '../../widgets/common/custom.divider.dart';
import '../../widgets/man_hour/man_hour_alert.dart';

class ManHourUpdate extends StatefulWidget {
  final List<dynamic> eventsOnTheDate;
  final DateTime date;
  const ManHourUpdate({required this.eventsOnTheDate, required this.date, super.key});

  @override
  State<ManHourUpdate> createState() => _ManHourUpdateState();
}

class _ManHourUpdateState extends State<ManHourUpdate> {
  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    final ManHourAlert manHourAlert = ManHourAlert();
    final CommonAlert commonAlert = CommonAlert();

    manHourProvider.manHourSeq = widget.eventsOnTheDate[0].manHourSeq;

    manHourProvider.manHourAmount = widget.eventsOnTheDate[0].manHour;
    manHourProvider.unitPriceAmount = widget.eventsOnTheDate[0].unitPrice;
    manHourProvider.etcPriceAmount = widget.eventsOnTheDate[0].etcPrice;
    manHourProvider.memo = widget.eventsOnTheDate[0].memo.toString();

    manHourProvider.totalAmount = (manHourProvider.manHourAmount * manHourProvider.unitPriceAmount) + manHourProvider.etcPriceAmount;
    // manHourProvider.addTotalAmount();

    TextEditingController manHourController = TextEditingController(text: manHourProvider.manHourAmount.toString());
    TextEditingController unitPriceController = TextEditingController(text: manHourProvider.unitPriceAmount.toString());
    TextEditingController etcPriceController = TextEditingController(text: manHourProvider.etcPriceAmount.toString());
    TextEditingController memoController = TextEditingController(text: manHourProvider.memo.toString());

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
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
                                        manHourController.text = manHourProvider.manHourAmount.toStringAsFixed(1);
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
                                        manHourController.text = manHourProvider.manHourAmount.toStringAsFixed(1);
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
                              const CustomDivider(height: 1, color: Colors.grey),
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    child: Text(
                                      '수정',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    onPressed: () async {
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      var memberSeq = pref.getInt(Glob.memberSeq);
                                      List<ManHourDto> manHourDtoList = [];

                                      if (manHourProvider.getManHourAmount == 0 && context.mounted) {
                                        return manHourAlert.validateManHour(context, 'manHour');
                                      } else if (manHourProvider.getUnitPriceAmount == 0 && context.mounted) {
                                        return manHourAlert.validateManHour(context, 'unitPrice');
                                      } else {
                                        ManHourDto manHourDto = ManHourDto(
                                            manHourSeq: manHourProvider.getManHourSeq,
                                            memberSeq: memberSeq!.toInt(),
                                            startDt: widget.date.toString().substring(0, 10), endDt: widget.date.toString().substring(0, 10),
                                            totalAmount: manHourProvider.getTotalAmount, manHour: manHourProvider.getManHourAmount, unitPrice: manHourProvider.getUnitPriceAmount, etcPrice: manHourProvider.getEtcPriceAmount, memo: manHourProvider.getMemo.toString(),
                                            isHoliday: 'N'
                                        );
                                        manHourDtoList.add(manHourDto);

                                        /// api 호출
                                        bool result = await ManHourService().updateManHour(manHourDto);

                                        if (result) {
                                          /// final 필드라서 바로 수정은 불가하고 removeWhere 로 지우고 새로운 데이터 넣어줌
                                          manHourProvider.events.removeWhere((dto) => dto.manHourSeq == manHourProvider.getManHourSeq);
                                          // 리스트를 불러와서 현재 manHourSeq 에 맞는 애를 찾아서 변경된 값으로 바꿔주면 됨
                                          // manHourDto 여기에 있는 데이터로 변경해주면 됨
                                          manHourProvider.addEvent(manHourDto);

                                          manHourProvider.currentFetchData(manHourDtoList);
                                          manHourProvider.initData();
                                          manHourProvider.initDateList();
                                          Future.microtask(() => manHourProvider.callNotify());
                                          if (context.mounted) {
                                            commonAlert.setRegistration(context);
                                          }
                                        } else {
                                          // 실패 alert
                                          if (context.mounted) {
                                            commonAlert.errorAlert(context);
                                          }
                                        }

                                      }

                                    },
                                  ),
                                  TextButton(
                                    child: Text(
                                      '삭제',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    onPressed: () async {
                                      SharedPreferences pref = await SharedPreferences.getInstance();
                                      var memberSeq = pref.getInt(Glob.memberSeq);
                                      List<ManHourDto> manHourDtoList = [];

                                      // 삭제할땐 어떤 값이 0 이어도 상관없음
                                      ManHourDto manHourDto = ManHourDto(
                                        manHourSeq: manHourProvider.getManHourSeq,
                                        memberSeq: memberSeq!.toInt(),
                                        startDt: widget.date.toString().substring(0, 10), endDt: widget.date.toString().substring(0, 10),
                                        totalAmount: manHourProvider.getTotalAmount, manHour: manHourProvider.getManHourAmount, unitPrice: manHourProvider.getUnitPriceAmount, etcPrice: manHourProvider.getEtcPriceAmount, memo: manHourProvider.getMemo.toString(),
                                        isHoliday: 'N'
                                      );

                                      manHourDtoList.add(manHourDto);

                                      // api 호출
                                      bool result = await ManHourService().deleteManHour(manHourDtoList);

                                      if (result) {
                                        // 성공이면 현재 provider 의 리스트에서 빼줌
                                        manHourProvider.events.removeWhere((dto) => dto.manHourSeq == manHourProvider.getManHourSeq);

                                        ManHourDto minusManHourDto = ManHourDto(
                                          manHourSeq: manHourProvider.getManHourSeq,
                                          memberSeq: memberSeq,
                                          startDt: widget.date.toString().substring(0, 10), endDt: widget.date.toString().substring(0, 10),
                                          totalAmount: -manHourProvider.getTotalAmount, manHour: -manHourProvider.getManHourAmount, unitPrice: -manHourProvider.getUnitPriceAmount, etcPrice: -manHourProvider.getEtcPriceAmount, memo: manHourProvider.getMemo.toString(),
                                          isHoliday: 'N'
                                        );

                                        // minusManHourDto 를 넣기위해 초기화
                                        manHourDtoList = [];
                                        manHourDtoList.add(minusManHourDto);

                                        manHourProvider.currentFetchData(manHourDtoList);
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
