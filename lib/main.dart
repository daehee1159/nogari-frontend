import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/models/common/temp_nogari.dart';
import 'package:nogari/views/login/login.dart';
import 'package:nogari/viewmodels/common/app_version_viewmodel.dart';
import 'package:nogari/viewmodels/common/news_viewmodel.dart';
import 'package:nogari/viewmodels/community/comment_viewmodel.dart';
import 'package:nogari/viewmodels/community/community_viewmodel.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/viewmodels/member/block_viewmodel.dart';
import 'package:nogari/viewmodels/member/level_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/my_profile_viewmodel.dart';
import 'package:nogari/viewmodels/member/notification_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_comment_viewmodel.dart';
import 'package:nogari/viewmodels/review/review_viewmodel.dart';
import 'package:nogari/widgets/common/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_core/firebase_core.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerSingleton(TempNogari());
}

Future<void> main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  // env load
  await dotenv.load(fileName: 'development.env');
  // await dotenv.load(fileName: 'production.env');
  KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'), javaScriptAppKey: dotenv.get('KAKAO_JAVASCRIPT_KEY'));
  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => TempNogari(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => AppVersionViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => NewsViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => CommunityViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => CommentViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ManHourViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => BlockViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => LevelViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => MemberViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => MyProfileViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => NotificationViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => PointHistoryViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ReviewViewModel(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ReviewCommentViewModel(),
          ),
        ],
        child: MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final MemberRepository _memberRepository = MemberRepositoryImpl();

  @override
  Widget build(BuildContext context) {
    /// 화면 세로 고정
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: '노가리',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('ko', 'KO'),
        // Locale('en', 'US')
      ],
      theme: ThemeData(
          useMaterial3: true,
          dialogTheme: const DialogTheme(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              iconColor: Color(0xff33D679),
              shadowColor: Colors.black
          ),
          cardTheme: const CardTheme(
            surfaceTintColor: Colors.white,
            color: Colors.white,
          ),
          appBarTheme: const AppBarTheme(
              surfaceTintColor: Color(0xffF0FEEE)
          ),
          // datePickerTheme: DatePickerThemeData(
          //   backgroundColor: Colors.white,
          //   headerForegroundColor: Colors.white
          // ),
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(fontSize: 26.0, fontFamily: 'NotoSansKR-Medium'),
            headlineMedium: TextStyle(fontSize: 24.0, fontFamily: 'NotoSansKR-Medium'),
            headlineSmall: TextStyle(fontSize: 22.0, fontFamily: 'NotoSansKR-Medium'), // 기본
            bodyLarge: TextStyle(fontSize: 16.0, fontFamily: 'NotoSansKR-Regular'),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'NotoSansKR-Regular'), // 기본
            bodySmall: TextStyle(fontSize: 12.0, fontFamily: 'NotoSansKR-Regular'),
          )
      ),
      home: FutureBuilder(
        future: _memberRepository.loginCheck(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xff33D679),)
                ],
              ),
            );
          } else if (snapshot.data == true) {
            final provider = locator.get<TempNogari>();
            provider.setIsIntentional = true;
            return const SplashScreen();
          } else {
            return const Login();
          }
        },
      ),
    );
  }
}
