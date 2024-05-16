import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/views/home.dart';
import 'package:nogari/views/login/create_nickname.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/models/common/temp_nogari.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nogari/widgets/common/common_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/global/global_variable.dart';
import '../../widgets/common/splash_screen.dart';

class LoginResult extends StatefulWidget {
  const LoginResult({super.key});

  @override
  State<LoginResult> createState() => _LoginResultState();
}

class _LoginResultState extends State<LoginResult> {
  final _provider = getIt.get<TempNogari>();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final MemberService _memberService = MemberService();
  String _accountEmail = 'None';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // _initText();
  }

  _initText() async {
    final User user = await UserApi.instance.me();
    _accountEmail = user.kakaoAccount!.email.toString();

    return _accountEmail;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        leading: Container(),
      ),
      body: FutureBuilder(
        future: _initText(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // initText()는 단순 이메일 가져오는 작업이므로 done 되어야 함
          if (snapshot.connectionState == ConnectionState.done) {
            return FutureBuilder(
                future: _memberRepository.getMemberStatus(snapshot.data.toString(), Platform.isAndroid ? 'Android' : 'iOS', null),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Color(0xff33D679),)
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  } else if (snapshot.data == 'UNSUBSCRIBED') {
                    return SafeArea(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, MediaQuery.of(context).size.height * 0.05),
                                child: Image.asset(
                                  'images/nogari_icon_big.png',
                                  height: MediaQuery.of(context).size.height * 0.2,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Text(
                                '성공적으로 인증되었어요.',
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center,
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 3, 0, MediaQuery.of(context).size.height * 0.05),
                                child: Text(
                                  '닉네임 설정 후 가입이 완료됩니다.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  textAlign: TextAlign.center,
                                ),
                              ),

                              TextButton(
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  backgroundColor: const Color(0xff33D679),
                                ),
                                onPressed: () async {
                                  bool result = await _memberService.setEmail(_accountEmail);

                                  if (result == true && mounted) {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateNickName()));
                                  } else {
                                    if (mounted) {
                                      CommonAlert().errorAlert(context);
                                    }
                                  }
                                },
                                child: Text(
                                  '닉네임 만들기',
                                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 18.0, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.data == 'INACTIVE') {
                    return Column(
                      children: [
                        Center(
                          child: Text(
                            '휴면 상태 회원',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        )
                      ],
                    );
                  } else if (snapshot.data == 'WITHDRAWAL') {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "탈퇴 후 30일이 지나지 않았어요.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          "회원 복구가 가능해요.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: const Color(0xffFE9BE6)
                          ),
                          onPressed: () async {
                            var url = Uri.parse('${Glob.memberUrl}/delete/restore/$_accountEmail');

                            Map<String, String> headers = {
                              'Content-Type': 'application/json',
                            };

                            http.Response response = await http.get(
                              url,
                              headers: headers,
                            );

                            bool result = json.decode(response.body);

                            if (result && mounted) {
                              _setKeyAndRoutePage(context, _accountEmail);
                            } else {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => BeforeRegistrationErrorPage()));
                            }
                          },
                          child: Text(
                            "복구하기",
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                          ),
                        )
                      ],
                    );
                  } else {
                    /// 여기까지 온 경우는 이미 가입된 회원이 로그인을 시도하는 경우임
                    /// 이미 가입된 회원이 로그인을 시도한다 = 기기가 변경되었다
                    return FutureBuilder(
                        future: _changedLoginInfo(_accountEmail),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData && snapshot.data.toString() == "true") {
                            final provider = getIt.get<TempNogari>();
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "로그인 정보가 변경되었어요.\n 버튼을 클릭하여 홈으로 이동해주세요!",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 10.0,),
                                TextButton(
                                  style: TextButton.styleFrom(
                                      backgroundColor: const Color(0xff33D679),
                                      minimumSize: Size(MediaQuery.of(context).size.width * 0.5, 45)
                                  ),
                                  onPressed: () async {
                                    bool result = await _setKey(_accountEmail);
                                    if (result) {
                                      bool updateResult = await _memberRepository.changeDeviceToken(_accountEmail);
                                      provider.setIsIntentional = true;
                                      // update member info
                                      if (updateResult) {
                                        if (mounted) {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SplashScreen()));
                                        }
                                      } else {
                                        if (mounted) {
                                          CommonAlert().errorAlert(context);
                                        }
                                      }
                                    } else {
                                      if (mounted) {
                                        CommonAlert().errorAlert(context);
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Home",
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                                  ),
                                )
                              ],
                            );
                          } else if (snapshot.hasData && snapshot.data.toString() == "false") {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    "알 수 없는 오류가 발생했어요.",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    "앱을 종료 후 다시 시도해주세요.",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                )
                              ],
                            );
                          } else {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Color(0xff33D679),)
                                  ],
                                ),
                              ),
                            );
                          }
                        }
                    );
                  }
                }
            );
          } if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xff33D679),)
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Error: ${snapshot.error}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            );
          } else {
            return SizedBox(
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xff33D679),)
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
  void _setEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Glob.email, email);
  }

  Future<bool> _setKey(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('registration', true);
    pref.setString(Glob.email, email);

    var url = Uri.parse('${Glob.memberUrl}/email');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    final saveData = jsonEncode({
      'email': email,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    int memberSeq = int.parse(response.body);

    await pref.setInt(Glob.memberSeq, memberSeq);

    if (pref.getInt(Glob.memberSeq) == null) {
      return false;
    } else {
      return true;
    }
  }

  _setKeyAndRoutePage(BuildContext context, String email) async {
    bool result = await _setKey(email);
    if (result) {
      _provider.setIsIntentional = true;
      // Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          '알 수 없는 오류',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }
  }

  hasLoginApp() {
    return FutureBuilder(
      future: _setKey(_accountEmail.toString()),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff33D679),)
                ],
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Error: ${snapshot.error}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        } else if (snapshot.data) {
          return const Home(currentIndex: 0,);

        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '알 수 없는 오류',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
      },
    );
  }

  Future<bool> _changedDeviceToken(String email) async {
    String? tokenData = await FirebaseMessaging.instance.getToken();
    if (tokenData == null) {
      return false;
    }

    var url = Uri.parse('${Glob.memberUrl}/device');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    var postData = jsonEncode({
      "email": email,
      'device': Platform.isIOS ? 'iOS' : 'Android',
      "deviceToken": tokenData.toString(),
    });

    http.Response response = await http.patch(
        url,
        headers: headers,
        body: postData
    );

    bool result = jsonDecode(response.body);

    if (result) {
      return true;
    } else {
      return false;
    }
  }

  _changedLoginInfo(String email) async {
    bool result = await _changedDeviceToken(email);
    return result;
  }
}
