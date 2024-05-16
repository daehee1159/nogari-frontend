import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nogari/models/man_hour/man_hour_bar_chart.dart';
import 'package:nogari/models/man_hour/man_hour_column_chart.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/services/man_hour_service.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/man_hour/man_hour.dart';

class ManHourHistory extends StatefulWidget {
  const ManHourHistory({super.key});

  @override
  State<ManHourHistory> createState() => _ManHourHistoryState();
}

class _ManHourHistoryState extends State<ManHourHistory> {
  final ManHourService _manHourService = ManHourService();
  late List<ManHourColumnChart> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    super.initState();
    data = [
      ManHourColumnChart('1', 12),
      ManHourColumnChart('2', 15),
      ManHourColumnChart('3', 30),
      ManHourColumnChart('4', 6),
      ManHourColumnChart('5', 14),
      ManHourColumnChart('6', 14),
      ManHourColumnChart('7', 14),
      ManHourColumnChart('8', 10),
      ManHourColumnChart('9', 14),
      ManHourColumnChart('10', 20),
      ManHourColumnChart('11', 14),
      ManHourColumnChart('12', 22),
    ];
    _tooltip = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);

    double deviceHeight = MediaQuery.of(context).size.height;
    bool isSized1700 = deviceHeight > 1700;

    List<ManHour> list = [];
    double totalAmount = 0.0;
    double totalManHour = 0.0;
    int avgUnitPrice = 0;
    int totalEtcPrice = 0;

    // 초기 데이터 넣기 (초기 데이터는 무조건 해당년도 전체임)
    for (int i = 0; i < manHourViewModel.events.length; i++) {
      if (DateTime.parse(manHourViewModel.events[i].startDt.toString()).year == manHourViewModel.selectYear) {
        list.add(manHourViewModel.events[i]);
      }
    }

    manHourViewModel.setHistoryList = list;

    for (int i = 0; i < manHourViewModel.getHistoryList.length; i++) {
      totalAmount = totalAmount + manHourViewModel.getHistoryList[i].totalAmount;
      totalManHour = totalManHour + manHourViewModel.getHistoryList[i].manHour;
      avgUnitPrice = avgUnitPrice + manHourViewModel.getHistoryList[i].unitPrice;
      totalEtcPrice = totalEtcPrice + manHourViewModel.getHistoryList[i].etcPrice;
    }

    manHourViewModel.setTotalMonthlyManHour = totalManHour;
    manHourViewModel.setAvgMonthlyUnitPrice = (manHourViewModel.getHistoryList.isEmpty) ? 0.0 : (avgUnitPrice / manHourViewModel.getHistoryList.length);
    manHourViewModel.setTotalMonthlyEtcPrice = totalEtcPrice;
    manHourViewModel.setTotalMonthlyAmount = totalAmount;

    List<ManHourColumnChart> columnData = _manHourService.convertToChartData(manHourViewModel.getHistoryList);
    List<ManHourBarChart> barChartData = [];
    for (int i = 0; i < 5; i++) {
      ManHourBarChart manHourBarChart = ManHourBarChart('data$i', 1000+i.toDouble());
      barChartData.add(manHourBarChart);
    }

    manHourViewModel.setBarChartList = barChartData;
    manHourViewModel.setColumnChartList = columnData;

    Future.microtask(() => manHourViewModel.callNotify());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '공수달력 이력보기',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            manHourViewModel.selectYear = DateTime.now().year;
            manHourViewModel.selectMonth = 0;
            manHourViewModel.initData();
            manHourViewModel.callNotify();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child : Consumer<ManHourViewModel>(
            builder: (context, viewModel, _) {
              return Column(
                children: [
                  Row(
                    children: [
                      buildYearDropdown(context),
                      const SizedBox(width: 10,),
                      buildMonthDropdown(context),
                    ],
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: isSized1700 ? MediaQuery.of(context).size.height * 0.23 : MediaQuery.of(context).size.height * 0.22,
                    child: Card(
                      elevation: 0.0,
                      child: Container(
                        color: const Color(0xffF0FEEE),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Consumer<ManHourViewModel>(
                                builder: (context, viewModel, _) {
                                  return Text(
                                    '총 급여 : ${CommonService().formatNumberWithCommas(viewModel.getTotalMonthlyAmount.toInt())}원',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                  );
                                }
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Consumer<ManHourViewModel>(
                                builder: (context, viewModel, _) {
                                  return Text(
                                    (viewModel.getInsuranceStatus) ?
                                    '총 세금 : ${CommonService().formatNumberWithCommas(viewModel.totalTax(
                                        viewModel.getTotalMonthlyAmount,
                                        viewModel.getTaxInfoDto.nationalPension!,
                                        viewModel.getTaxInfoDto.healthInsurance!,
                                        viewModel.getTaxInfoDto.employmentInsurance!,
                                        viewModel.getIncomeTaxInfo(viewModel.getTotalMonthlyAmount)).toInt())}원'
                                    :
                                    '총 세금 : ${CommonService().formatNumberWithCommas(viewModel.freelancerInsurance(viewModel.getTotalMonthlyAmount).toInt())}',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                  );
                                }
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              child: Consumer<ManHourViewModel>(
                                builder: (context, viewModel, _) {
                                  return Text(
                                    (viewModel.getInsuranceStatus) ?
                                    '합계 : ${CommonService().formatNumberWithCommas((
                                        viewModel.getTotalMonthlyAmount - viewModel.totalTax(
                                            viewModel.getTotalMonthlyAmount,
                                            viewModel.getTaxInfoDto.nationalPension!,
                                            viewModel.getTaxInfoDto.healthInsurance!,
                                            viewModel.getTaxInfoDto.employmentInsurance!,
                                            viewModel.getIncomeTaxInfo(viewModel.getTotalMonthlyAmount))).toInt())}원'
                                    :
                                    '합계 : ${CommonService().formatNumberWithCommas((
                                        viewModel.getTotalMonthlyAmount - viewModel.freelancerInsurance(viewModel.getTotalMonthlyAmount)).toInt())}원',
                                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                                  );
                                }
                              ),
                            )
                          ],
                        ),
                      )
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            '${viewModel.selectYear}년',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                      ),
                      const SizedBox(width: 5,),
                      Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            (viewModel.selectMonth == 0) ? '전체' : '${viewModel.selectMonth}월',
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                      ),
                      const SizedBox(width: 5,),
                      Text(
                        '나의 기록',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),
                  const SizedBox(height: 10.0,),
                  Row(
                    children: [
                      Text(
                        '총 공수 : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            CommonService().formatNumberWithCommas(viewModel.getTotalMonthlyManHour.toInt()),
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '평균 단가 : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            CommonService().formatNumberWithCommas((viewModel.getAvgMonthlyUnitPrice).toInt()),
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '총 기타비용 : ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Consumer<ManHourViewModel>(
                        builder: (context, viewModel, _) {
                          return Text(
                            CommonService().formatNumberWithCommas(viewModel.getTotalMonthlyEtcPrice),
                            style: Theme.of(context).textTheme.bodyMedium,
                          );
                        }
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                  (viewModel.selectMonth == 0) ?
                  Consumer<ManHourViewModel>(
                    builder: (context, viewModel, _) {
                      return SfCartesianChart(
                        primaryXAxis: const CategoryAxis(interval: 1,),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          interval: 1000,
                          numberFormat: NumberFormat('#,###'),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries<ManHourColumnChart, String>>[
                          ColumnSeries<ManHourColumnChart, String>(
                            dataSource: viewModel.getColumnChartList,
                            xValueMapper: (ManHourColumnChart data, _) => data.x,
                            yValueMapper: (ManHourColumnChart data, _) => data.y,
                            name: 'Gold',
                            color: const Color(0xff33D679),
                          )
                        ],
                      );
                    }
                  ) :
                  Consumer<ManHourViewModel>(
                    builder: (context, viewModel, _) {
                      return SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          interval: 100,
                          numberFormat: NumberFormat('#,###'),
                        ),
                        series: <CartesianSeries<ManHourBarChart, String>>[
                          ColumnSeries<ManHourBarChart, String>(
                            dataSource: viewModel.getBarChartList,
                            xValueMapper: (ManHourBarChart data, _) => data.x,
                            yValueMapper: (ManHourBarChart data, _) => data.y,
                            name: '금액',
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                            color: const Color(0xff33D679),
                          )
                        ],
                      );
                    }
                  ),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget buildYearDropdown(BuildContext context) {
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);
    // 여기에는 모든 데이터의 년도가 필요하기 때문에 events를 넣어줌
    List<int> years = _manHourService.getYearsList(manHourViewModel.events);

    return Consumer<ManHourViewModel>(
      builder: (context, viewModel, _) {
        return DropdownButton<int>(
          value: viewModel.selectYear, // 초기 선택값
          onChanged: (int? newValue) {
            // 년도가 변경될 때 처리할 로직 추가
            if (newValue != null) {

              List<ManHour> list = [];
              double totalAmount = 0.0;
              double totalManHour = 0.0;
              int avgUnitPrice = 0;
              int totalEtcPrice = 0;


              /// 년도 선택, 월 선택의 유기적 변환을 위해
              if (viewModel.selectMonth == 0) {
                for (int i = 0; i < viewModel.events.length; i++) {
                  if (DateTime.parse(viewModel.events[i].startDt.toString()).year == newValue) {
                    list.add(viewModel.events[i]);
                  }
                }
              } else {
                for (int i = 0; i < viewModel.events.length; i++) {
                  if (DateTime.parse(viewModel.events[i].startDt.toString()).year == newValue && DateTime.parse(viewModel.events[i].startDt.toString()).month == viewModel.selectMonth) {
                    list.add(viewModel.events[i]);
                  }
                }

                List<ManHourBarChart> barChartData = [];

                barChartData.add(ManHourBarChart('총 공수', viewModel.getTotalMonthlyManHour));
                barChartData.add(ManHourBarChart('평균 단가', viewModel.getAvgMonthlyUnitPrice.toDouble()));
                barChartData.add(ManHourBarChart('총 기타금액', viewModel.getTotalMonthlyEtcPrice.toDouble()));
                barChartData.add(ManHourBarChart('세금', 0.0));

                viewModel.setBarChartList = barChartData;
              }

              if (list.isEmpty) {
                viewModel.setTotalMonthlyManHour = 0.0;
                viewModel.setAvgMonthlyUnitPrice = 0.0;
                viewModel.setTotalMonthlyEtcPrice = 0;
                viewModel.setTotalMonthlyAmount = 0.0;

                List<ManHourBarChart> barChartData = [];

                barChartData.add(ManHourBarChart('총 공수', 0));
                barChartData.add(ManHourBarChart('평균 단가', 0));
                barChartData.add(ManHourBarChart('총 기타금액', 0));
                barChartData.add(ManHourBarChart('세금', 0.0));

                viewModel.setBarChartList = barChartData;
              } else {
                viewModel.setHistoryList = list;

                for (int i = 0; i < viewModel.getHistoryList.length; i++) {
                  totalAmount = totalAmount + viewModel.getHistoryList[i].totalAmount;
                  totalManHour = totalManHour + viewModel.getHistoryList[i].manHour;
                  avgUnitPrice = avgUnitPrice + viewModel.getHistoryList[i].unitPrice;
                  totalEtcPrice = totalEtcPrice + viewModel.getHistoryList[i].etcPrice;
                }

                viewModel.setTotalMonthlyManHour = totalManHour;
                viewModel.setAvgMonthlyUnitPrice = (avgUnitPrice / viewModel.getHistoryList.length);
                viewModel.setTotalMonthlyEtcPrice = totalEtcPrice;
                viewModel.setTotalMonthlyAmount = totalAmount;
              }

              List<ManHourColumnChart> columnData = ManHourService().convertToChartData(viewModel.getHistoryList);

              viewModel.setColumnChartList = columnData;

              viewModel.selectYear = newValue;
              viewModel.callNotify();
            }
          },
          items: years.map((int year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text('$year 년'),
            );
          }).toList(),
        );
      }
    );
  }

  Widget buildMonthDropdown(BuildContext context) {
    List<int> months = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
    return Consumer<ManHourViewModel>(
      builder: (context, viewModel, _) {
        return DropdownButton<int>(
          value: viewModel.selectMonth, // 초기 선택값
          onChanged: (int? newValue) {
            // 월이 변경될 때 처리할 로직 추가
            if (newValue != null) {
              // 여기서 변경된 월로 데이터 변경해야함
              List<ManHour> list = [];
              double totalAmount = 0.0;
              double totalManHour = 0.0;
              int avgUnitPrice = 0;
              int totalEtcPrice = 0;

              if (newValue == 0) {
                // 0 = 전체 이기 때문에 list 수정을 년도 전체로 바꿔줘야함
                for (int i = 0; i < viewModel.events.length; i++) {
                  if (DateTime.parse(viewModel.events[i].startDt.toString()).year == viewModel.selectYear) {
                    list.add(viewModel.events[i]);
                  }
                }
              } else {
                for (int i = 0; i < viewModel.events.length; i++) {
                  if (DateTime.parse(viewModel.events[i].startDt.toString()).year == viewModel.selectYear && DateTime.parse(viewModel.events[i].startDt.toString()).month == newValue) {
                    list.add(viewModel.events[i]);
                  }
                }
              }

              if (list.isEmpty) {
                viewModel.setTotalMonthlyManHour = 0.0;
                viewModel.setAvgMonthlyUnitPrice = 0.0;
                viewModel.setTotalMonthlyEtcPrice = 0;
                viewModel.setTotalMonthlyAmount = 0.0;

                List<ManHourBarChart> barChartData = [];

                barChartData.add(ManHourBarChart('총 공수', 0));
                barChartData.add(ManHourBarChart('평균 단가', 0));
                barChartData.add(ManHourBarChart('총 기타금액', 0));
                // barChartData.add(ManHourBarChart('세금', 0.0));

                viewModel.setBarChartList = barChartData;
              } else {
                viewModel.setHistoryList = list;

                for (int i = 0; i < viewModel.getHistoryList.length; i++) {
                  totalAmount = totalAmount + viewModel.getHistoryList[i].totalAmount;
                  totalManHour = totalManHour + viewModel.getHistoryList[i].manHour;
                  avgUnitPrice = avgUnitPrice + viewModel.getHistoryList[i].unitPrice;
                  totalEtcPrice = totalEtcPrice + viewModel.getHistoryList[i].etcPrice;
                }

                viewModel.setTotalMonthlyManHour = totalManHour;
                viewModel.setAvgMonthlyUnitPrice = (avgUnitPrice / viewModel.getHistoryList.length);
                viewModel.setTotalMonthlyEtcPrice = totalEtcPrice;
                viewModel.setTotalMonthlyAmount = totalAmount;

                List<ManHourBarChart> barChartData = [];

                barChartData.add(ManHourBarChart('총 공수', viewModel.getTotalMonthlyManHour));
                barChartData.add(ManHourBarChart('평균 단가', viewModel.getAvgMonthlyUnitPrice.toDouble()));
                barChartData.add(ManHourBarChart('총 기타금액', viewModel.getTotalMonthlyEtcPrice.toDouble()));
                // barChartData.add(ManHourBarChart('세금', 0.0));

                viewModel.setBarChartList = barChartData;
              }

              List<ManHourColumnChart> columnData = ManHourService().convertToChartData(viewModel.getHistoryList);

              viewModel.setColumnChartList = columnData;

              viewModel.selectMonth = newValue;
              viewModel.callNotify();
            }
          },
          items: months.map((int month) {
            return DropdownMenuItem<int>(
              value: month,
              child: Text(
                (month == 0) ? '전체' : '$month월'
              )
            );
          }).toList(),
        );
      }
    );
  }
}
