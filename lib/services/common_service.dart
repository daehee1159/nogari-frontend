import 'dart:async';
import 'dart:io';

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nogari/enums/board_type.dart';
import 'package:nogari/enums/report_reason.dart';
import 'package:nogari/models/common/app_version_dto.dart';
import 'package:nogari/models/common/app_version_provider.dart';
import 'package:nogari/models/common/news_dto.dart';
import 'package:nogari/models/common/news_provider.dart';
import 'package:nogari/models/common/report_board.dto.dart';
import 'package:nogari/models/man_hour/man_hour_provider.dart';
import 'package:nogari/models/member/block_dto.dart';
import 'package:nogari/models/member/block_provider.dart';
import 'package:nogari/models/member/notification_dto.dart';
import 'package:nogari/models/member/notification_provider.dart';
import 'package:nogari/models/member/member_info_dto.dart';
import 'package:nogari/models/member/member_info_provider.dart';
import 'package:nogari/models/member/level_provider.dart';
import 'package:nogari/models/member/point_history_provider.dart';
import 'package:nogari/services/man_hour_service.dart';
import 'package:nogari/services/member_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:recase/recase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../models/global/global_variable.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../models/man_hour/man_hour_dto.dart';
import '../models/man_hour/tax_info_dto.dart';
import '../models/member/level_dto.dart';
import '../models/member/point_history_dto.dart';

import '../models/common/temp_nogari.dart';
import '../screens/home.dart';

class CommonService {
  Timer? _debounce;
  final MemberService memberService = MemberService();
  final ManHourService manHourService = ManHourService();
  InterstitialAd? _interstitialAd;

  getAppVersion() async {
    var url = Uri.parse('${Glob.commonUrl}/app/version');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
        url,
        headers: headers,
    );

    AppVersionDto appVersionDto = AppVersionDto.fromJson(jsonDecode(response.body));

    return appVersionDto;
  }

  // SplashScreen fetchData
  fetchData(BuildContext context) async {
    MemberInfoProvider memberInfoProvider = Provider.of<MemberInfoProvider>(context, listen: false);
    NotificationProvider notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    LevelProvider levelProvider = Provider.of<LevelProvider>(context, listen: false);
    PointHistoryProvider pointHistoryProvider = Provider.of<PointHistoryProvider>(context, listen: false);
    ManHourProvider manHourProvider = Provider.of<ManHourProvider>(context, listen: false);
    AppVersionProvider appVersionProvider = Provider.of<AppVersionProvider>(context, listen: false);
    NewsProvider newsProvider = Provider.of<NewsProvider>(context, listen: false);
    BlockProvider blockProvider = Provider.of<BlockProvider>(context, listen: false);

    /// 필요한 데이터 목록
    /// manHour
    /// member info
    /// notification
    /// point
    try {
      /// Member Info
      SharedPreferences pref = await SharedPreferences.getInstance();
      int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());

      Map<String, dynamic> responseData = await memberService.getMemberInfo(memberSeq);
      MemberInfoDto memberInfoDto = MemberInfoDto.fromJson(responseData);
      memberInfoProvider.setMemberSeq = memberInfoDto.memberSeq;
      memberInfoProvider.setNickName = memberInfoDto.nickName;
      memberInfoProvider.setDevice = memberInfoDto.device;
      memberInfoProvider.setDeviceToken = memberInfoDto.deviceToken;
      memberInfoProvider.setStatus = memberInfoDto.status;
      // 여기서는 DateTime 으로 바꿔줄 필요는 있다
      memberInfoProvider.setRegDt = memberInfoDto.regDt;

      /// notification
      List<NotificationDto> notiResponse = await memberService.getNotification();
      notificationProvider.setNotificationList = notiResponse;

      /// level, point
      Map<String, dynamic> rankResponse = await memberService.getLevelAndPoint(memberSeq);
      LevelDto levelDto = LevelDto.fromJson(rankResponse);
      levelProvider.setLevelSeq = levelDto.levelSeq;
      levelProvider.setLevel = levelDto.level;
      levelProvider.setPoint = levelDto.point;

      /// PointHistoryToday
      List<PointHistoryDto> pointHistoryList = await memberService.getPointHistoryToday();
      pointHistoryProvider.setPointHistoryList = pointHistoryList;

      /// Block Member List
      List<BlockDto> blockDtoList = await memberService.getBlockMember();
      blockProvider.setBlockDtoList = blockDtoList;

      /// News
      List<NewsDto> newsList = await getNews();
      newsProvider.setNewsList = newsList;
      newsProvider.setRandomNewsList = newsList;

      /// 출석체크
      bool containsAttendance = pointHistoryList.any((pointHistory) => pointHistory.pointHistory == 'ATTENDANCE');
      if (!containsAttendance) {
        await memberService.setAttendance();
        pointHistoryProvider.addAttendance();
      }

      /// 공수달력
      List<ManHourDto> manHourDtoList = await manHourService.getManHourList();
      manHourProvider.setManHourList = manHourDtoList;
      Future.microtask(() => manHourProvider.callNotify());

      /// 4대보험 가입여부
      bool insuranceStatus = pref.getBool(Glob.insuranceStatus) ?? true;
      manHourProvider.setInsuranceStatus = insuranceStatus;

      /// App Version
      AppVersionDto appVersionDto = await getAppVersion();
      appVersionProvider.setAppVersion = appVersionDto;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersionProvider.setCurrentAppVersion = packageInfo.version;
      appVersionProvider.setDBAppVersion = (Platform.isAndroid) ? appVersionDto.android : appVersionDto.ios;

      Map<String, Function()> pointHistoryActions = {
        'ATTENDANCE': () => pointHistoryProvider.addAttendance(),
        'COMMUNITY_WRITING': () => pointHistoryProvider.addCommunityWriting(),
        'REVIEW_WRITING': () => pointHistoryProvider.addReviewWriting(),
        'COMMUNITY_COMMENT': () => pointHistoryProvider.addCommunityComment(),
        'REVIEW_COMMENT': () => pointHistoryProvider.addReviewComment(),
        'WATCH_5SEC_AD': () => pointHistoryProvider.addWatch5SecAd(),
        'WATCH_30SEC_AD': () => pointHistoryProvider.addWatch30SecAd(),
      };

      for (int i = 0; i < pointHistoryProvider.getPointHistoryList.length; i++) {
        String currentHistory = pointHistoryProvider.getPointHistoryList[i].pointHistory;
        if (pointHistoryActions.containsKey(currentHistory)) {
          pointHistoryActions[currentHistory]!();
        }
      }

      /// 세금 정보 가져오기
      TaxInfoDto taxInfoDto = await getTaxInfo(DateTime.now().year.toString());
      manHourProvider.setTaxInfo = taxInfoDto;


      /// FCM Token 만료 체크 및 교체
      String? myDeviceToken;
      await FirebaseMessaging.instance.getToken().then((value) {
        myDeviceToken = value;
      });

      String dbToken = await memberService.getDeviceToken();

      /// FCM 토큰이 DB 와 다를 경우 update
      if (myDeviceToken.toString() != "" && myDeviceToken.toString() != dbToken) {
        bool result = await memberService.changeDeviceToken(myDeviceToken.toString());
        if (result == false) {
          // GlobalFunc().setErrorLog("changedDeviceToken function Error");
        }
      }

      return true;
    } catch(e) {
      // GlobalFunc().setErrorLog("SplashScreen _fetchData catch Error log = $e");
      rethrow;
    }
  }

  getNews() async {
    final Uri uri = Uri.parse('${Glob.commonUrl}/data/news');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    List<NewsDto> fetchData =((json.decode(response.body) as List).map((e) => NewsDto.fromJson(e)).toList());

    return fetchData;
  }

  // 대문자 스네이크 케이스 -> 파스칼 케이스
  String snakeToPascalCase(String snakeCase) {
    List<String> parts = snakeCase.split('_');
    String pascalCase = '';
    for (var part in parts) {
      pascalCase += part.substring(0, 1).toUpperCase() + part.substring(1).toLowerCase();
    }
    return pascalCase;
  }

  // string to int
  int stringToInt(String str) {
    try {
      int result = int.parse(str);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  // 숫자 콤마 찍기
  String formatNumberWithCommas(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // 파일 업로드
  final firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  Future<bool> uploadFile(String filePath, String fileName, String uploadPath) async {
    try {
      firebase_storage.Reference reference = storage.ref().child(uploadPath).child(fileName);
      firebase_storage.UploadTask uploadTask = reference.putFile(File(filePath));
      await uploadTask.whenComplete(() async {
        String filePath = await reference.getDownloadURL();
      });
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<firebase_storage.ListResult> listFiles(String uploadPath) async {
    firebase_storage.ListResult results = await storage.ref(uploadPath).listAll();

    return results;
  }

  Future<String> downloadURL(String imageName, String uploadPath) async {
    try {
      if (imageName == "" || imageName == "null") {
        String downloadURL = "null";
        return downloadURL;
      } else {
        String downloadURL = await storage.ref('$uploadPath/$imageName').getDownloadURL();
        return downloadURL;
      }
    } catch(e) {
      return "null";
    }

  }

  Future<bool> deleteFile(List<String> imageList, String uploadPath) async {
    try {
      for (int i = 0; i < imageList.length; i++) {
        firebase_storage.Reference reference = storage.ref().child(uploadPath).child(imageList[i]);
        await reference.delete();
      }
      return true;
    } catch(e) {
      return false;
    }
  }

  // 글 작성 시 1초동안 아무 움직임이 없다면 해당 내용 provider 에 저장하기 위한 Timer
  void debounce(Function() callback) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      callback();
    });
  }

  // 세금 정보 가져오기
  Future<TaxInfoDto> getTaxInfo(String standardDt) async {
    final Uri uri = Uri.parse('${Glob.commonUrl}/tax/$standardDt');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    TaxInfoDto taxInfoDto = TaxInfoDto.fromJson(json.decode(response.body));

    return taxInfoDto;
  }

  Future<InterstitialAd?> getInterstitialAd() async {
    final provider = getIt.get<TempNogari>();

    await InterstitialAd.load(
      adUnitId: Glob.testInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {

              // print('Interstitial Ad Showed Full Screen Content');
            },
            onAdImpression: (ad) {
              // print('Interstitial Ad Impression Recorded');
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdClicked: (ad) {
              // print('Interstitial Ad Clicked');
            },
          );

          _interstitialAd = ad;
          _interstitialAd!.show();
          provider.setIsWatchingAd(true);
          Future.microtask(() => provider.callNotify());
        },
        onAdFailedToLoad: (LoadAdError error) {
          // print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  // 게시글 신고하기
  reportBoard(BoardType boardType, int boardSeq, ReportReason reportReason, int reportedMemberSeq) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());
    var url = Uri.parse('${Glob.commonUrl}/report');

    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    print('뭐가문제');
    print(boardType.toJson());
    print(reportReason.toJson());

    var saveData = jsonEncode({
      'boardType': ReCase(boardType.toString().split('.').last).constantCase,
      'boardSeq': boardSeq,
      'reportReason': ReCase(reportReason.toString().split('.').last).constantCase,
      'reporterMemberSeq': memberSeq,
      'reportedMemberSeq': reportedMemberSeq,
    });

    http.Response response = await http.post(
        url,
        headers: headers,
        body: saveData
    );

    return jsonDecode(response.body);
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    String realMonth = "";
    String realDay = "";

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      DateTime date = startDate.add(Duration(days: i));

      if (date.month < 10) {
        realMonth = "0${date.month}";
      } else {
        realMonth = date.month.toString();
      }

      if ((date.day) < 10) {
        realDay = "0${date.day}";
      } else {
        realDay = (date.day).toString();
      }

      days.add(DateTime.parse("${date.year}-$realMonth-$realDay"));
    }
    return days;
  }
}
