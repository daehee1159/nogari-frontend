import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/global/global_variable.dart';

class AcceptEULAWidget extends StatefulWidget {
  const AcceptEULAWidget({super.key});

  @override
  State<AcceptEULAWidget> createState() => _AcceptEULAWidgetState();
}

class _AcceptEULAWidgetState extends State<AcceptEULAWidget> {
  bool _privacyPolicyChecked = false;
  bool _termsOfServiceChecked = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('이용약관 동의', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: _privacyPolicyChecked,
                activeColor: const Color(0xff33D679),
                onChanged: (value) {
                  setState(() {
                    _privacyPolicyChecked = value!;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(Glob.privacySiteUrl);
                },
                child: Text(
                  '개인정보 처리방침에 동의합니다.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.blue, decoration: TextDecoration.underline)
                ),
              ),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: _termsOfServiceChecked,
                activeColor: const Color(0xff33D679),
                onChanged: (value) {
                  setState(() {
                    _termsOfServiceChecked = value!;
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(Glob.termsSiteUrl);
                },
                child: Text(
                  '이용약관에 동의합니다.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.blue, decoration: TextDecoration.underline)
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_privacyPolicyChecked && _termsOfServiceChecked) {
              Navigator.of(context).pop(true); // 동의가 완료되었을 때 다이얼로그를 닫습니다.
            } else {
              _showSnackBar(context, '개인정보 처리방침과 이용약관에 동의해주세요.');
            }
          },
          child: Text('확인', style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch url';
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
      ),
    );
  }
}
