import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:nogari/models/common/app_version_provider.dart';
import 'package:nogari/models/common/news_provider.dart';
import 'package:nogari/models/community/comment_provider.dart';
import 'package:nogari/models/community/community_provider.dart';
import 'package:nogari/models/man_hour/man_hour_provider.dart';
import 'package:nogari/models/member/block_provider.dart';
import 'package:nogari/models/member/member_info_provider.dart';
import 'package:nogari/models/member/my_profile_provider.dart';
import 'package:nogari/models/member/notification_provider.dart';
import 'package:nogari/models/member/level_provider.dart';
import 'package:nogari/models/member/point_history_provider.dart';
import 'package:nogari/models/review/review_comment_provider.dart';
import 'package:nogari/models/review/review_provider.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/models/common/temp_nogari.dart';
import 'package:nogari/screens/login/login.dart';
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
  KakaoSdk.init(nativeAppKey: Platform.environment['KAKAO_NATIVE_APP_KEY'], javaScriptAppKey: Platform.environment['KAKAO_JAVASCRIPT_APP_KEY']);
  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (BuildContext context) => TempNogari(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ManHourProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => CommunityProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => CommentProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ReviewProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => ReviewCommentProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => MemberInfoProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => MyProfileProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => NotificationProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => LevelProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => PointHistoryProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => AppVersionProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => NewsProvider(),
          ),
          ChangeNotifierProvider(
            create: (BuildContext context) => BlockProvider(),
          ),
        ],
        child: const MyApp(),
      )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
        future: MemberService().loginCheck(),
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
