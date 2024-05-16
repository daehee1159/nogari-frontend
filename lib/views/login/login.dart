import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk_auth.dart';
import 'package:kakao_flutter_sdk_auth/kakao_flutter_sdk_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/views/login/create_nickname.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/models/common/temp_nogari.dart';
import 'package:nogari/views/login/login_result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/global/global_variable.dart';
import '../../widgets/common/splash_screen.dart';
import '../home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final MemberService _memberService = MemberService();
  bool _isKakaoTalkInstalled = false;

  @override
  void initState() {
    super.initState();
    _initKakaoTalkInstalled();
  }

  _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();
    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  _loginWithKakao() async {
    try {
      // 이거 자기 알아서 toeknmanager 에 저장해서 관리함 토큰 매니저에 저장할 필요도 없고 코드 받아서 토큰 발급받는 절차 생략이 가능함
      OAuthToken oAuthToken = await UserApi.instance.loginWithKakaoAccount();
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginResult(),));
      }
    } catch (e) {
      // 카카오 웹 로그인 실패
      // print(e.toString());
    }
  }

  _loginWithTalk() async {
    try {
      OAuthToken oAuthToken = await UserApi.instance.loginWithKakaoTalk();
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginResult(),));
      }
    } catch (e) {
      // 카톡으로 로그인 실패
      // print(e.toString());
    }
  }

  _bottomSheet() {
    return Container(
      height: 40,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      alignment: FractionalOffset.bottomCenter,
      child: Text(
       '기존 가입 회원은 인증 후 자동 로그인됩니다.',
        style: Theme.of(context).textTheme.bodyMedium
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: _bottomSheet(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'images/nogari_icon.png',
              height: MediaQuery.of(context).size.height * 0.25,
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Text(
              '우리들의 노가다 이야기',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
              child: Text(
                '간편 로그인 후 노가리를 시작해보세요!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.07,),
          Center(
            child: InkWell(
              onTap: () => _isKakaoTalkInstalled ? _loginWithTalk() : _loginWithKakao(),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.yellow
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(5, 2, 5, 4),
                      child: Icon(FontAwesomeIcons.solidComment, color: Colors.black,),
                    ),
                    const SizedBox(width: 10,),
                    Text(
                      '카카오로 시작하기',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: (Platform.isIOS) ? 10.0 : 0.0,),
          (Platform.isIOS) ? Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.1),
            child: SignInWithAppleButton(
              text: 'Apple로 시작하기',
              height: MediaQuery.of(context).size.height * 0.07,
              onPressed: () async {
                String email = '';
                String identifier = '';
                bool loginAvailable = await SignInWithApple.isAvailable();

                if (loginAvailable) {
                  final credential = await SignInWithApple.getAppleIDCredential(
                    scopes: [
                      AppleIDAuthorizationScopes.email,
                    ],
                  );
                  final provider = getIt.get<TempNogari>();
                  // 애플 로그인 시 노가리 email 허용을 하지 않은 경우
                  if (credential.email.toString() == '' || credential.email.toString() == 'null') {
                    // email 허용을 하지 않아서 identifier를 가져와야함, email 필드는 identifier 로 채움
                    email = credential.userIdentifier.toString();
                  } else {
                    // 애플 로그인 시 이메일 허용 한 경우
                    email = credential.email.toString();
                  }

                  if (credential.userIdentifier != null && credential.userIdentifier.toString() != '' && credential.userIdentifier.toString() != 'null') {
                    identifier = credential.userIdentifier.toString();
                  }

                  String memberStatus = await _memberRepository.getMemberStatus(email, 'iOS', identifier);

                  switch (memberStatus) {
                  // UNIDENTIFIED 가 나오면 오류임
                    case 'UNIDENTIFIED':
                      break;
                    case 'UNSUBSCRIBED':
                    /// 미가입 상태
                      bool setEmailResult = await _memberService.setEmail(email);
                      bool setIdentifier = await _memberService.setIdentifier(identifier);
                      // _setAppleEmail(email);

                      if (setEmailResult && setIdentifier) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CreateNickName()));
                      } else {
                      }
                      break;
                    case 'INACTIVE':
                    /// 휴면 회원 해제 로직 필요
                      break;
                    case 'WITHDRAWAL':
                      // restoreMember(context, email);
                      break;
                    default:
                      bool result = await _memberRepository.changeDeviceToken(email);
                      if (result) {
                        int memberSeq = await _memberRepository.getMemberSeqByEmail(email);
                        bool setMemberSeq = await _memberService.setMemberSeq(memberSeq);

                        provider.setIsIntentional = true;
                        bool setEmailResult = await _memberService.setEmail(email);
                        bool setIdentifier = await _memberService.setIdentifier(identifier);
                        // await _setKey(email);
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
                      } else {
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => SignInAppleErrorPage()));
                      }
                      break;
                  }
                }
              },
            ),
          ) :
          const SizedBox()
        ],
      ),
    );
  }
  Future<UserCredential> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  appleLoginError(BuildContext context) async {
    AlertDialog alertDialog = AlertDialog(
      title: TextButton.icon(
        label: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Text(
            "오류 발생",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.circleExclamation,
          color: Colors.red,
        ),
        onPressed: () {},
      ),
      content: Text(
        '알 수 없는 오류가 발생했어요.\n앱을 삭제 후 다시 시도해주세요.',
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

  _setAppleEmail(String email) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Glob.email, email);
  }

  restoreMember(BuildContext context, String email) async {
    AlertDialog alertDialog = AlertDialog(
      title: TextButton.icon(
        label: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Text(
            "회원 복구",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.circleExclamation,
          color: Colors.green,
        ),
        onPressed: () {},
      ),
      content: Text(
        '탈퇴 후 30일 미만 계정이에요.\n복구하시겠어요?',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          child: Text(
            '복구',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onPressed: () async {
            var url = Uri.parse('${Glob.memberUrl}/delete/restore/$email');

            Map<String, String> headers = {
              'Content-Type': 'application/json',
            };

            http.Response response = await http.get(
              url,
              headers: headers,
            );

            bool result = json.decode(response.body);

            if (result) {
              await _setKey(email);
              await _setKeyAndRoutePage(context, email);
            } else {
              // Navigator.push(context, MaterialPageRoute(builder: (context) => BeforeRegistrationErrorPage()));
            }
          },
        ),
        TextButton(
          child: Text(
            '취소',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onPressed: () {
            Navigator.of(context).pop();
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

  _setKeyAndRoutePage(BuildContext context, String email) async {
    bool result = await _setAppleEmail(email);
    if (result && mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 0,)));
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

  changeDeviceAlert(BuildContext context, String email) async {
    AlertDialog alertDialog = AlertDialog(
      title: TextButton.icon(
        label: Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
          child: Text(
            "로그인 정보 변경",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        icon: const Icon(
          FontAwesomeIcons.circleExclamation,
          color: Colors.blue,
        ),
        onPressed: () {},
      ),
      content: Text(
        '로그인 정보가 변경되었어요.\n확인을 눌러 홈으로 이동해주세요.',
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          child: Text(
            '확인',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          onPressed: () async {
            Navigator.of(context).pop();
            bool result = await _setAppleEmail(email);
            if (result && mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Home(currentIndex: 0,)));
            } else {
              // GlobalAlert().globErrorAlert(context);
            }
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
