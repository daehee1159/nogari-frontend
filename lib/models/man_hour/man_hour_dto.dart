import 'package:flutter/material.dart';
import 'package:cell_calendar/cell_calendar.dart';

import '../../services/common_service.dart';

class ManHourDto extends CalendarEvent {
  final int manHourSeq;
  final int memberSeq;
  final String startDt;
  final String endDt;
  final double totalAmount;
  final double manHour;
  final int unitPrice;
  final int etcPrice;
  final String memo;
  final String isHoliday;

  final TextStyle? textStyle;
  final Color? backGroundColor;

  ManHourDto({
    required this.manHourSeq,
    required this.memberSeq,
    required this.startDt,
    required this.endDt,
    required this.totalAmount,
    required this.manHour,
    required this.unitPrice,
    required this.etcPrice,
    required this.memo,
    required this.isHoliday,
    this.textStyle,
    this.backGroundColor
  }) : super (eventName: (isHoliday == 'Y') ? memo : CommonService().formatNumberWithCommas(totalAmount.toInt()).toString(), eventDate: DateTime.parse(startDt), eventTextStyle: textStyle ?? const TextStyle(fontSize: 10, color: Colors.white), eventBackgroundColor: backGroundColor ?? const Color(0xff33D679));
  // 굳이 이렇게 하는 이유는 CalendarEvent 클래스를 상속해야하고 DTO의 역할을 하려면 DTO 역할때는 textStyle 과 backGroundColor 가 필요 없기 때문에 어쩔수없이

  ManHourDto copyWith({
    int? manHourSeq,
    int? memberSeq,
    String? startDt,
    String? endDt,
    double? totalAmount,
    double? manHour,
    int? unitPrice,
    int? etcPrice,
    String? memo,
    String? isHoliday,
    TextStyle? textStyle,
    Color? backGroundColor,
  }) {
    return ManHourDto(
      manHourSeq: manHourSeq ?? this.manHourSeq,
      memberSeq: memberSeq ?? this.memberSeq,
      startDt: startDt ?? this.startDt,
      endDt: endDt ?? this.endDt,
      totalAmount: totalAmount ?? this.totalAmount,
      manHour: manHour ?? this.manHour,
      unitPrice: unitPrice ?? this.unitPrice,
      etcPrice: etcPrice ?? this.etcPrice,
      memo: memo ?? this.memo,
      isHoliday: isHoliday ?? this.isHoliday,
      textStyle: textStyle ?? this.textStyle,
      backGroundColor: backGroundColor ?? this.backGroundColor,
    );
  }

  factory ManHourDto.fromJson(Map<String, dynamic> json) {
    return ManHourDto(
      manHourSeq: json['manHourSeq'] as int,
      memberSeq: json['memberSeq'] as int,
      startDt: json['startDt'] as String,
      endDt: json['endDt'] as String,
      totalAmount: json['totalAmount'] as double,
      manHour: json['manHour'] as double,
      unitPrice: json['unitPrice'] as int,
      etcPrice: json['etcPrice'] as int,
      memo: json['memo'] as String,
      isHoliday: json['isHoliday'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'manHourSeq': manHourSeq,
      'memberSeq': memberSeq,
      'startDt': startDt,
      'endDt': endDt,
      'totalAmount': totalAmount,
      'manHour': manHour,
      'unitPrice': unitPrice,
      'etcPrice': etcPrice,
      'memo': memo,
      'isHoliday': isHoliday,
    };
  }

  static List<Map<String, dynamic>> listToJson(List<ManHourDto> manHourList) {
    return manHourList.map((manHourDto) => manHourDto.toJson()).toList();
  }
}

