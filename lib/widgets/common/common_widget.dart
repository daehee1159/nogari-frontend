import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../screens/home.dart';

class CommonWidget {
  Widget arrow() {
    return const Icon(
      Icons.arrow_forward_ios,
      size: 20.0,
    );
  }

  saveSuccessAlert(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      title: TextButton.icon(
        label: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Text(
            "저장 성공",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.circleCheck,
          color: Color(0xff33D679),
        ),
        onPressed: () {},
      ),
      content: Text(
        '저장에 성공했어요.',
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      }
    );
  }

  updateSuccessAlert(BuildContext context) {
    AlertDialog alertDialog = AlertDialog(
      title: TextButton.icon(
        label: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Text(
            "수정 성공",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.circleCheck,
          color: Color(0xff33D679),
        ),
        onPressed: () {},
      ),
      content: Text(
        '수정에 성공했어요.',
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
            /// 수정페이지, 해당 alert 까지 두개 닫아야함
            Navigator.of(context).pop();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 1,)));
          },
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      }
    );
  }
}
