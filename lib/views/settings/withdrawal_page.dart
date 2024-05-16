import 'package:flutter/material.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/widgets/member/member_alert.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final MemberService _memberService = MemberService();
  final MemberAlert _memberAlert = MemberAlert();
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '회원탈퇴',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: InkWell(
        highlightColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const SizedBox(height: 10,),
              Center(
                child: Text(
                  '더 나은 서비스를 위해 탈퇴 사유를 적어주세요.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10,),
              Container(
                height: MediaQuery.of(context).size.height * 0.2,
                // height: 500,
                child: TextField(
                  // 이게 최선이 아님; 화면마다 어떻게 될 줄 알고;;
                  // textAlignVertical: TextAlignVertical(y: -0.5),
                  controller: textEditingController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 10,
                  decoration: const InputDecoration(
                    hintText: '탈퇴 사유를 입력해주세요.',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0)
                  ),
                  onChanged: (String value) {
                  },
                ),
              ),
              const SizedBox(height: 10,),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xff33D679),
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1)
                ),
                onPressed: () async {
                  bool result = await _memberRepository.withdrawalMember(textEditingController.text);
                  bool prefResult = await _memberService.withdrawalMemberPref();

                  if (mounted) {
                    _memberAlert.withdrawalAlert(context);
                  }
                },
                child: Text(
                  '탈퇴하기',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }
}
