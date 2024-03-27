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

class ManHourRegistration extends StatefulWidget {
  final List<dynamic> eventsOnTheDate;
  final DateTime date;
  const ManHourRegistration({required this.eventsOnTheDate, required this.date, super.key});

  @override
  State<ManHourRegistration> createState() => _ManHourRegistrationState();
}

class _ManHourRegistrationState extends State<ManHourRegistration> {
  @override
  Widget build(BuildContext context) {
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    final ManHourAlert manHourAlert = ManHourAlert();
    final CommonAlert commonAlert = CommonAlert();

    TextEditingController manHourController = TextEditingController(text: manHourProvider.getManHourAmount.toString());
    TextEditingController unitPriceController = TextEditingController(text: manHourProvider.unitPriceAmount.toString());
    TextEditingController etcPriceController = TextEditingController(text: manHourProvider.etcPriceAmount.toString());
    TextEditingController memoController = TextEditingController();

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

                                      // 공수0 아니고 단가0 아닌 경우만 등록
                                      if (manHourProvider.getManHourAmount == 0 && context.mounted) {
                                        return manHourAlert.validateManHour(context, 'manHour');
                                      } else if (manHourProvider.getUnitPriceAmount == 0 && context.mounted) {
                                        return manHourAlert.validateManHour(context, 'unitPrice');
                                      } else {
                                        ManHourDto manHourDto = ManHourDto(
                                          manHourSeq: 0,
                                          memberSeq: memberSeq!.toInt(),
                                          startDt: widget.date.toString().substring(0, 10), endDt: widget.date.toString().substring(0, 10),
                                          totalAmount: manHourProvider.getTotalAmount, manHour: manHourProvider.getManHourAmount, unitPrice: manHourProvider.getUnitPriceAmount, etcPrice: manHourProvider.getEtcPriceAmount, memo: manHourProvider.getMemo.toString(),
                                          isHoliday: 'N'
                                        );
                                        manHourDtoList.add(manHourDto);

                                        // api 호출하면 끝
                                        bool result = await ManHourService().setManHour(manHourDtoList);

                                        if (result) {
                                          // 성공 후 현재 events 에 넣어줘야함
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
