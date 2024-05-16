import 'package:flutter/material.dart';
import 'package:korean_profanity_filter/korean_profanity_filter.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:provider/provider.dart';

import '../../services/member_service.dart';


bool _isNicknameAvailable = false; // 닉네임 중복 여부 상태
Color _checkErrorColor = Colors.black;
bool _isFirstTime = true;
bool _isDuplicate = false;
String? tempNickName;

class ChangeNickName extends StatefulWidget {
  const ChangeNickName({super.key});

  @override
  State<ChangeNickName> createState() => _ChangeNickNameState();
}

class _ChangeNickNameState extends State<ChangeNickName> {
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  TextEditingController nickNameController = TextEditingController();

  @override
  void initState() {
    _isNicknameAvailable = false;
    _isFirstTime = true;
    _isDuplicate = false;
    tempNickName = null;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    nickNameController.text = Provider.of<MemberViewModel>(context, listen: false).getNickName.toString();
  }

  @override
  Widget build(BuildContext context) {
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '닉네임 변경',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return GestureDetector(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              width: double.infinity,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: viewportConstraints.maxHeight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Image.asset(
                        'images/nogari_icon_big.png',
                        height: MediaQuery.of(context).size.height * 0.2,
                        // color: const Color(0xffFE9BE6),
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      Text(
                        '닉네임을 설정해주세요.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.08,),
                      TextFormField(
                        controller: nickNameController,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 18.0),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white70,
                          hintText: '닉네임을 입력해주세요.',
                          hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 17.0, color: Colors.grey),
                          contentPadding: const EdgeInsets.all(15),
                          focusedBorder: _customBorder(2, Colors.green),
                          enabledBorder: _isNicknameAvailable ? _customBorder(2, Colors.green) : _customBorder(2, Colors.black),
                          errorBorder: _customBorder(2, Colors.red),
                          // focusedErrorBorder: _customBorder(4, Colors.red),
                          disabledBorder: _customBorder(2, Colors.yellow),
                          errorText: checkErrorText(),
                          errorStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: _checkErrorColor),
                          errorMaxLines: 1,
                        ),
                        autovalidateMode: AutovalidateMode.always,
                        validator: (value) {
                          // return checkErrorText();
                          _isDuplicate = false;
                        },
                        onChanged: (value) {
                          // 입력값이 변경될 때마다 중복 체크
                          setState(() {
                          });
                        },
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05,),
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          padding: const EdgeInsets.all(15),
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () async {
                          /// 닉네임을 입력하지 않은 경우 alert
                          String currentNickName = nickNameController.text;

                          if (!_isNicknameAvailable) {

                          } else {
                            // api 호출 후 false 일때
                            if (tempNickName == currentNickName) {
                              // 여기서는 api를 굳이 호출하지 않고 상태만 똑같이 변경해줌
                              setState(() {
                                _isDuplicate = true;
                                checkErrorText();
                              });
                            } else {
                              // 이제 여기서 api 다시 호출
                              tempNickName = currentNickName;
                              String type = 'nickName';
                              bool result = await _memberRepository.isDuplicate(type, currentNickName);
                              // result == true 닉네임 중복임
                              if (result) {
                                setState(() {
                                  _isDuplicate = true;
                                  checkErrorText();
                                });
                              } else {
                                // 중복이 아니므로 가입 완료
                                bool result = await _memberRepository.updateNickName(currentNickName);

                                if (result) {
                                  // 성공
                                  memberViewModel.setNickName = currentNickName;
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  // 실패
                                  if (mounted) {
                                    CommonAlert().errorAlert(context);
                                  }
                                }
                              }
                            }
                          }
                        },
                        child: Text(
                          '완료',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTap: () {
              // 키보드 밖 클릭 시 키보드 닫기
              FocusManager.instance.primaryFocus?.unfocus();
            },
          );
        }
      ),
    );
  }

  // return null 이면 error로 인식하지 않음
  String? checkErrorText() {
    // 2글자 이상 정규식
    RegExp twoOrMoreCharacters = RegExp(r'^.{2,}$');
    // 특수문자 금지 정규식
    RegExp noSpecialCharacters = RegExp(r'[^\wㄱ-ㅎㅏ-ㅣ가-힣]+');
    // 특수문자에 자꾸 언더바가 빠지길래 하나 더 만듬
    RegExp underscoreRegex = RegExp(r'_');
    // 띄어쓰기 금지 정규식
    RegExp noWhitespace = RegExp(r'^\S+$');

    String text = nickNameController.text;
    bool twoMore = twoOrMoreCharacters.hasMatch(text);
    bool noSpecial = noSpecialCharacters.hasMatch(text);
    bool noUnderScore = underscoreRegex.hasMatch(text);
    bool noSpace = noWhitespace.hasMatch(text);
    bool hasFWord = text.containsBadWords;

    if (nickNameController.text.isEmpty && _isFirstTime) {
      _isNicknameAvailable = false;
      _isFirstTime = false;
      return null;
    } else if (nickNameController.text.isEmpty && !_isFirstTime) {
      _checkErrorColor = Colors.red;
      _isNicknameAvailable = false;
      return '닉네임을 입력해주세요';
    } else if (text == '') {
      _isNicknameAvailable = false;
    } else if (!twoMore) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      return '2글자 이상 입력해주세요';
    } else if (noSpecial) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      return '특수문자는 사용할 수 없습니다';
    } else if (noUnderScore) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      return '특수문자는 사용할 수 없습니다.';
    } else if (!noSpace) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      return '띄어쓰기는 사용할 수 없습니다';
    } else if (hasFWord) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      return '비속어 사용은 불가합니다.';
    } else if (_isDuplicate) {
      _isNicknameAvailable = false;
      _checkErrorColor = Colors.red;
      // _isDuplicate = false;
      return '중복된 닉네임입니다';
    } else {
      String type = 'email';

      // bool result = await MemberService().isDuplicate(type, text);
      _checkErrorColor = Colors.green;
      _isNicknameAvailable = true;
      return null;
    }
  }

  InputBorder _customBorder(double width, Color color) {
    return UnderlineInputBorder(
        borderSide: BorderSide(
          width: width,
          color: color,
        )
    );
  }
}
