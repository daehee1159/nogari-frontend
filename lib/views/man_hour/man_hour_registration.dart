import 'package:flutter/material.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository_impl.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/global/global_variable.dart';
import '../../models/man_hour/man_hour.dart';
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
  final ManHourRepository _manHourRepository = ManHourRepositoryImpl();
  final ManHourAlert _manHourAlert = ManHourAlert();
  final CommonAlert _commonAlert = CommonAlert();

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
            '${widget.date.year}년 ${widget.date.month}월 ${widget.date.day}일',
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

                                      // 공수0 아니고 단가0 아닌 경우만 등록
                                      if (viewModel.getManHourAmount == 0 && context.mounted) {
                                        return _manHourAlert.validateManHour(context, 'manHour');
                                      } else if (viewModel.getUnitPriceAmount == 0 && context.mounted) {
                                        return _manHourAlert.validateManHour(context, 'unitPrice');
                                      } else {
                                        ManHour manHourDto = ManHour(
                                          manHourSeq: 0,
                                          memberSeq: memberSeq!.toInt(),
                                          startDt: widget.date.toString().substring(0, 10), endDt: widget.date.toString().substring(0, 10),
                                          totalAmount: viewModel.getTotalAmount, manHour: viewModel.getManHourAmount, unitPrice: viewModel.getUnitPriceAmount, etcPrice: viewModel.getEtcPriceAmount, memo: viewModel.getMemo.toString(),
                                          isHoliday: 'N'
                                        );
                                        manHourList.add(manHourDto);

                                        // api 호출하면 끝
                                        bool result = await _manHourRepository.setManHour(manHourList);

                                        if (result) {
                                          // 성공 후 현재 events 에 넣어줘야함
                                          viewModel.addEvent(manHourDto);
                                          viewModel.currentFetchData(manHourList);
                                          viewModel.initData();
                                          viewModel.initDateList();
                                          Future.microtask(() => viewModel.callNotify());
                                          if (context.mounted) {
                                            _commonAlert.setRegistration(context);
                                          }
                                        } else {
                                          // 실패 alert
                                          if (context.mounted) {
                                            _commonAlert.errorAlert(context);
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
