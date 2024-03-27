import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nogari/enums/report_reason.dart';
import 'package:nogari/services/common_service.dart';
import 'package:nogari/widgets/common/common_alert.dart';

import '../../enums/board_type.dart';

class ReportButton extends StatefulWidget {
  final BoardType boardType;
  final int boardSeq;
  final int reportedMemberSeq;
  const ReportButton({required this.boardType, required this.boardSeq, required this.reportedMemberSeq, super.key});

  @override
  State<ReportButton> createState() => _ReportButtonState();
}

class _ReportButtonState extends State<ReportButton> {
  final CommonService commonService = CommonService();
  final CommonAlert commonAlert = CommonAlert();
  String selectedOption = '';

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero, // 텍스트 및 아이콘 사이의 여백을 없애기 위해 padding 설정
      child: (widget.boardType == BoardType.community || widget.boardType == BoardType.review) ?
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red,),
            const SizedBox(width: 5.0),
            Text(
              '신고하기',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ): const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.red, size: 20,),
      onPressed: () {
        showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) => CupertinoActionSheet(
            title: Text(
              '신고 사유를 선택해주세요\n'
              '사유가 맞지 않을 경우 해당 신고는 처리되지 않습니다.\n'
              '일정 횟수의 신고를 받은 유저는 글 작성이 제한됩니다.',
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
            actions: ReportReason.values
                .map(
                  (reason) => CupertinoActionSheetAction(
                onPressed: () async {
                  String description = reason.description;
                  // 여기에서 선택된 신고 사유에 대한 처리를 추가할 수 있습니다.
                  print('Reported: $description');
                  ReportReason reportReason = ReportReasonExtension.fromDescription(description);
                  print('Reported Enum: $reportReason');
                  bool result = await commonService.reportBoard(widget.boardType, widget.boardSeq, reportReason, widget.reportedMemberSeq);

                  if (result) {
                    if (mounted) {
                      commonAlert.successReport(context);
                    }
                  } else {
                    if (mounted) {
                      commonAlert.errorAlert(context);
                    }
                  }
                },
                child: Text(reason.description, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),),
              ),
            )
                .toList(),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context); // 취소 버튼을 누르면 팝업을 닫습니다.
              },
              child: Text(
                '취소',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        );
      },
    );
  }
}
