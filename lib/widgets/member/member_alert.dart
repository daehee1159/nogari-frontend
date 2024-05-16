import 'package:flutter/material.dart';
import 'package:nogari/views/login/login.dart';

class MemberAlert {
  void withdrawalAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          '노가리',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.green
          ),
        ),
        content: Text(
          '완료되었습니다.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            child: Text('확인', style: Theme.of(context).textTheme.bodyMedium,),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
          )
        ],
      )
    );
  }

  void successBlockMember(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Icon(
          Icons.check_circle,
          size: 50,
          color: Color(0xff33D679),
        ),
        content: Text(
          '차단이 완료되었습니다.',
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

  void successUnBlockMember(BuildContext context) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Icon(
            Icons.check_circle,
            size: 50,
            color: Color(0xff33D679),
          ),
          content: Text(
            '차단이 해제되었습니다.',
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
}
