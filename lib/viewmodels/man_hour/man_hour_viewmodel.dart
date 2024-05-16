import 'package:flutter/material.dart';

import '../../models/man_hour/man_hour.dart';
import '../../models/man_hour/man_hour_bar_chart.dart';
import '../../models/man_hour/man_hour_column_chart.dart';
import '../../models/man_hour/tax_info.dart';

class ManHourViewModel extends ChangeNotifier {
  List<ManHour> _events = [];
  List<ManHour> _searchList = [];

  int manHourSeq = 0;

  double totalAmount = 0;
  double manHourAmount = 0;
  int unitPriceAmount = 0;
  int etcPriceAmount = 0;
  String? memo;

  // 캘린더 하단의 이번달 내용 보여주는거 + man_hour_history.dart
  DateTime? date;
  double totalMonthlyAmount = 0;
  double totalMonthlyManHour = 0;
  double avgMonthlyUnitPrice = 0;
  int totalMonthlyEtcPrice = 0;

  // man_hour_alert.dart

  DateTime? startDt;
  DateTime? endDt;
  List<String> dateList = [];
  String period = '미선택';
  String? selectedPeriod;

  // man_hour.checkbox.dart
  bool exceptSat = false;
  bool exceptSun = false;
  bool exceptHol = false;

  // man_hour_history.dart
  int selectYear = DateTime.now().year;
  int selectMonth = 0;
  List<ManHour> historyList = [];
  List<ManHourColumnChart> columnChartList = [];
  List<ManHourBarChart> barChartList = [];

  // 세금 정보
  TaxInfo taxInfo = TaxInfo();
  // 4대보험 가입 여부
  bool insuranceStatus = true;

  List<ManHour> get events => _events;
  List<ManHour> get getSearchList => _searchList;

  int get getManHourSeq => manHourSeq;

  DateTime? get getDate => date;
  double get getTotalAmount => totalAmount;
  double get getManHourAmount => manHourAmount;
  int get getUnitPriceAmount => unitPriceAmount;
  int get getEtcPriceAmount => etcPriceAmount;
  String? get getMemo => memo;

  double get getTotalMonthlyAmount => totalMonthlyAmount;
  double get getTotalMonthlyManHour => totalMonthlyManHour;
  double get getAvgMonthlyUnitPrice => avgMonthlyUnitPrice;
  int get getTotalMonthlyEtcPrice => totalMonthlyEtcPrice;

  DateTime? get getStartDt => startDt;
  DateTime? get getEndDt => endDt;

  List<String> get getDateList => dateList;
  String get getPeriod => period;
  String? get getSelectedPeriod => selectedPeriod;
  bool get getExceptSat => exceptSat;
  bool get getExceptSun => exceptSun;
  bool get getExceptHol => exceptHol;

  List<ManHour> get getHistoryList => historyList;
  List<ManHourColumnChart> get getColumnChartList => columnChartList;
  List<ManHourBarChart> get getBarChartList => barChartList;

  TaxInfo get getTaxInfoDto => taxInfo;
  bool get getInsuranceStatus => insuranceStatus;

  void initManHour() {
    _events = [];
    notifyListeners();
  }

  void initSearchManHour() {
    _searchList = [];
    notifyListeners();
  }

  void initDateList() {
    dateList = [];
    notifyListeners();
  }

  void initData() {
    manHourSeq = 0;

    totalAmount = 0;
    manHourAmount = 0;
    unitPriceAmount = 0;
    etcPriceAmount = 0;
    memo = null;

    startDt = null;
    endDt = null;
    notifyListeners();
  }

  void addEvent(ManHour manHour) {
    _events.add(manHour);
    notifyListeners();
  }

  void addSearchList(ManHour manHour) {
    _searchList.add(manHour);
    notifyListeners();
  }

  void addDataList(String value) {
    dateList.add(value);
    notifyListeners();
  }

  void addTotalAmount() {
    totalAmount = (manHourAmount * unitPriceAmount) + etcPriceAmount;
    notifyListeners();
  }

  /// 공수 달력 추가 수정 삭제 후 현재 보고있는 월의 캘린더 데이터 수정
  void currentFetchData(List<ManHour> manHourList) {
    double totalMonthlyAmount = getTotalMonthlyAmount;
    double totalMonthlyManHour = getTotalMonthlyManHour;
    double avgMonthlyUnitPrice = getAvgMonthlyUnitPrice;
    int totalMonthlyEtcPrice = getTotalMonthlyEtcPrice;

    for (int i = 0; i < manHourList.length; i++) {
      totalMonthlyAmount = totalMonthlyAmount + manHourList[i].totalAmount;
      totalMonthlyManHour = totalMonthlyManHour + manHourList[i].manHour;
      avgMonthlyUnitPrice = avgMonthlyUnitPrice + manHourList[i].unitPrice;
      totalMonthlyEtcPrice = totalMonthlyEtcPrice + manHourList[i].etcPrice;
    }

    DateTime now = DateTime.parse(manHourList[0].startDt);

    int count = events.where((element) => DateTime.parse(element.startDt).year == now.year && DateTime.parse(element.startDt).month == now.month && element.isHoliday == 'N').length;

    setTotalMonthlyAmount = totalMonthlyAmount;
    setTotalMonthlyManHour = totalMonthlyManHour;
    setAvgMonthlyUnitPrice = count != 0 ? (avgMonthlyUnitPrice / count).toDouble() : 0.0;
    setTotalMonthlyEtcPrice = totalMonthlyEtcPrice;
  }

  // 소득세 반환
  double getIncomeTaxInfo(double amount) {
    double result = amount / 1000;
    /// amount 를 천원단위로 바꾸고 다시 리턴해줄때 정상단위로 줘야함
    for (int i = 0; i < taxInfo.incomeTaxDtoList!.length; i++) {
      if (result >= taxInfo.incomeTaxDtoList![i].more!.toInt() && result < taxInfo.incomeTaxDtoList![i].under!.toInt()) {
        result = taxInfo.incomeTaxDtoList![i].amount!.toDouble() * 1000;
        break;
      } else {
        result = 0;
      }
    }
    return result;
  }

  // 총 세금 합
  double totalTax(double amount, double nationalPension, double healthInsurance, double employmentInsurance, double incomeTax) {
    // 국민연금 (amount * nationalPension) / 100
    double nationalPensionResult = (amount * nationalPension) / 100;
    // 건강보험 (amount * healthInsurance) / 100
    double healthInsuranceResult =  (amount * healthInsurance) / 100;
    // 고용보험 (amount * employmentInsurance) / 100
    double employmentInsuranceResult =  (amount * employmentInsurance) / 100;
    // 소득세는 이미 계산되어 들어온 것
    // 합
    return nationalPensionResult + healthInsuranceResult + employmentInsuranceResult + incomeTax;
  }

  void toggleInsuranceStatus() {
    insuranceStatus = !insuranceStatus;
    notifyListeners();
  }

  double freelancerInsurance(double amount) {
    return (amount * 3.3) / 100;
  }

  set setManHourList(List<ManHour> list) {
    _events = [];
    _events = list;
    // notifyListeners();
  }

  set setSearchList(List<ManHour> list) {
    _searchList = [];
    _searchList = list;
    // notifyListeners();
  }

  set setManHourSeq(int value) {
    manHourSeq = value;
    notifyListeners();
  }

  set setManHourAmount(double value) {
    manHourAmount = manHourAmount + value;
    notifyListeners();
  }

  set setUnitPriceAmount(int value) {
    unitPriceAmount = unitPriceAmount + value;
    notifyListeners();
  }

  set setEtcPriceAmount(int value) {
    etcPriceAmount = etcPriceAmount + value;
    notifyListeners();
  }

  set setDateList(List<String> value) {
    dateList = value;
    notifyListeners();
  }

  set setPeriod(value) {
    period = value;
    notifyListeners();
  }

  set setSelectedPeriod(value) {
    selectedPeriod = value;
    notifyListeners();
  }

  set setMemo(value) {
    memo = value;
    notifyListeners();
  }

  set setDate(DateTime? value) {
    date = value;
    // notifyListeners();
  }

  set setTotalMonthlyAmount(value) {
    totalMonthlyAmount = value;
    // notifyListeners();
  }

  set setTotalMonthlyManHour(value) {
    totalMonthlyManHour = value;
    // notifyListeners();
  }

  set setAvgMonthlyUnitPrice(value) {
    avgMonthlyUnitPrice = value;
    // notifyListeners();
  }

  set setTotalMonthlyEtcPrice(value) {
    totalMonthlyEtcPrice = value;
    // notifyListeners();
  }

  set setStartDt(DateTime value) {
    startDt = value;
    notifyListeners();
  }

  set setEndDt(DateTime value) {
    endDt = value;
    notifyListeners();
  }

  set setExceptSat(bool value) {
    exceptSat = value;
    notifyListeners();
  }

  set setExceptSun(bool value) {
    exceptSun = value;
    notifyListeners();
  }

  set setExceptHol(bool value) {
    exceptHol = value;
    notifyListeners();
  }

  set setHistoryList(List<ManHour> list) {
    historyList = [];
    historyList = list;
    // notifyListeners();
  }

  set setColumnChartList(List<ManHourColumnChart> list) {
    columnChartList = [];
    columnChartList = list;
    // notifyListeners();
  }

  set setBarChartList(List<ManHourBarChart> list) {
    barChartList = [];
    barChartList = list;
    // notifyListeners();
  }

  set setTaxInfo(TaxInfo taxInfo) {
    taxInfo = taxInfo;
    notifyListeners();
  }

  set setInsuranceStatus(bool value) {
    insuranceStatus = value;
    notifyListeners();
  }

  // period 초기화, period set 할때 사용
  String dateTimeToPeriod(type, startDt, endDt) {
    switch (type) {
      case 'init':
        notifyListeners();
        return '미선택';
      case 'date':
        notifyListeners();
        return startDt.toString().substring(0, 10);
      case 'period':
        notifyListeners();
        return '${startDt.toString().substring(0, 10)} ~ ${endDt.toString().substring(0, 10)}';
      default:
        notifyListeners();
        return '미선택';
    }
  }

  void callNotify() {
    notifyListeners();
  }
}
