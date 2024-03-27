import 'package:flutter/material.dart';

import '../../screens/man_hour/man_hour_screen.dart';

class CommonAlert {
  void errorAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            '오류 발생\n잠시 후 다시 시도해주세요.',
            style: Theme.of(context).textTheme.bodyMedium,
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
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  void duplicateAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Icon(
          Icons.warning_amber_outlined,
          color: Colors.red,
          size: 50,
        ),
        content: Text(
          '변경된 내용이 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium,
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

  void spaceError(BuildContext context, String type) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            '$type을(를) 입력해주세요.',
            style: Theme.of(context).textTheme.bodyMedium,
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

  void selectedImageError(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.warning_amber_outlined,
            color: Colors.red,
            size: 50,
          ),
          content: Text(
            '사진은 3개까지만 선택 가능합니다.',
            style: Theme.of(context).textTheme.bodyMedium,
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
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  void setRegistration(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Icon(
          Icons.check_circle,
          size: 50,
          color: Color(0xff33D679),
        ),
        content: Text(
          '등록이 완료되었습니다.',
          style: Theme.of(context).textTheme.bodyMedium,
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
              Navigator.of(context).pop();
            },
          )
        ],
      )
    );
  }

  void deleteComplete(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.check_circle,
            size: 50,
            color: Color(0xff33D679),
          ),
          content: Text(
            '삭제가 완료되었습니다.',
            style: Theme.of(context).textTheme.bodyMedium,
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
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }

  void setPeriodRegistration(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.check_circle,
            size: 50,
            color: Color(0xff33D679),
          ),
          content: Text(
            '등록이 완료되었습니다.',
            style: Theme.of(context).textTheme.bodyMedium,
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ManHourScreen()));
              },
            )
          ],
        )
    );
  }

  void successReport(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.check_circle,
            size: 50,
            color: Color(0xff33D679),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '신고가 완료되었습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              Text(
                '검토는 최대 24시간 소요됩니다.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
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
                Navigator.of(context).pop();
              },
            )
          ],
        )
    );
  }
}
