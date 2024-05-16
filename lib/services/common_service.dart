import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:nogari/models/common/news.dart';
import 'package:nogari/models/member/member_info.dart';
import 'package:nogari/repositories/common/common_repository.dart';
import 'package:nogari/repositories/common/common_repository_impl.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository.dart';
import 'package:nogari/repositories/man_hour/man_hour_repository_impl.dart';
import 'package:nogari/repositories/member/member_repository.dart';
import 'package:nogari/repositories/member/member_repository_impl.dart';
import 'package:nogari/services/man_hour_service.dart';
import 'package:nogari/services/member_service.dart';
import 'package:nogari/viewmodels/common/app_version_viewmodel.dart';
import 'package:nogari/viewmodels/common/news_viewmodel.dart';
import 'package:nogari/viewmodels/man_hour/man_hour_viewmodel.dart';
import 'package:nogari/viewmodels/member/block_viewmodel.dart';
import 'package:nogari/viewmodels/member/level_viewmodel.dart';
import 'package:nogari/viewmodels/member/member_viewmodel.dart';
import 'package:nogari/viewmodels/member/notification_viewmodel.dart';
import 'package:nogari/viewmodels/member/point_history_viewmodel.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/search_condition.dart';
import '../models/common/app_version.dart';
import '../models/global/global_variable.dart';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../models/man_hour/man_hour.dart';
import '../models/man_hour/tax_info.dart';
import '../models/member/block.dart';
import '../models/member/level.dart';
import '../models/member/notification_data.dart';
import '../models/member/point_history.dart';

import '../models/common/temp_nogari.dart';
import '../views/home.dart';

class CommonService {
  Timer? _debounce;
  final MemberService memberService = MemberService();
  final MemberRepository _memberRepository = MemberRepositoryImpl();
  final CommonRepository _commonRepository = CommonRepositoryImpl();
  final ManHourService manHourService = ManHourService();
  final ManHourRepository _manHourRepository = ManHourRepositoryImpl();
  InterstitialAd? _interstitialAd;

  // SplashScreen fetchData
  fetchData(BuildContext context) async {
    final memberViewModel = Provider.of<MemberViewModel>(context, listen: false);
    final notificationViewModel = Provider.of<NotificationViewModel>(context, listen: false);
    final levelViewModel = Provider.of<LevelViewModel>(context, listen: false);
    final pointHistoryViewModel = Provider.of<PointHistoryViewModel>(context, listen: false);
    final manHourViewModel = Provider.of<ManHourViewModel>(context, listen: false);
    final appVersionViewModel = Provider.of<AppVersionViewModel>(context, listen: false);
    final newsViewModel = Provider.of<NewsViewModel>(context, listen: false);
    final blockViewModel = Provider.of<BlockViewModel>(context, listen: false);

    /// 필요한 데이터 목록
    /// manHour
    /// member info
    /// notification
    /// point
    try {
      /// MemberInfo
      SharedPreferences pref = await SharedPreferences.getInstance();
      int memberSeq = int.parse(pref.getInt(Glob.memberSeq).toString());

      MemberInfo memberInfo = await _memberRepository.getMemberInfo(memberSeq);

      memberViewModel.setMemberSeq = memberInfo.memberSeq;
      memberViewModel.setNickName = memberInfo.nickName;
      memberViewModel.setDevice = memberInfo.device;
      memberViewModel.setDeviceToken = memberInfo.deviceToken;
      memberViewModel.setStatus = memberInfo.status;
      // 여기서는 DateTime 으로 바꿔줄 필요는 있다
      memberViewModel.setRegDt = memberInfo.regDt;

      /// notification
      List<NotificationData> notiResponse = await _memberRepository.getNotification();
      notificationViewModel.setNotificationList = notiResponse;

      /// level, point
      Level level = await _memberRepository.getLevelAndPoint(memberSeq);
      levelViewModel.setLevelSeq = level.levelSeq;
      levelViewModel.setLevel = level.level;
      levelViewModel.setPoint = level.point;

      /// PointHistoryToday
      List<PointHistory> pointHistoryList = await _memberRepository.getPointHistoryToday();
      pointHistoryViewModel.setPointHistoryList = pointHistoryList;

      /// Block Member List
      List<Block> blockList = await _memberRepository.getBlockMember();
      blockViewModel.setBlockDtoList = blockList;

      /// News
      List<News> newsList = await _commonRepository.getNews();
      newsViewModel.setNewsList = newsList;
      newsViewModel.setRandomNewsList = newsList;

      /// 출석체크
      bool containsAttendance = pointHistoryList.any((pointHistory) => pointHistory.pointHistory == 'ATTENDANCE');
      if (!containsAttendance) {
        await _memberRepository.setPoint('ATTENDANCE');
        pointHistoryViewModel.addAttendance();
      }

      /// 공수달력
      List<ManHour> manHourList = await _manHourRepository.getManHourList();
      manHourViewModel.setManHourList = manHourList;
      Future.microtask(() => manHourViewModel.callNotify());

      /// 4대보험 가입여부
      bool insuranceStatus = pref.getBool(Glob.insuranceStatus) ?? true;
      manHourViewModel.setInsuranceStatus = insuranceStatus;

      /// App Version
      AppVersion appVersion = await _commonRepository.getAppVersion();
      appVersionViewModel.setAppVersion = appVersion;
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersionViewModel.setCurrentAppVersion = packageInfo.version;
      appVersionViewModel.setDBAppVersion = (Platform.isAndroid) ? appVersion.android : appVersion.ios;

      Map<String, Function()> pointHistoryActions = {
        'ATTENDANCE': () => pointHistoryViewModel.addAttendance(),
        'COMMUNITY_WRITING': () => pointHistoryViewModel.addCommunityWriting(),
        'REVIEW_WRITING': () => pointHistoryViewModel.addReviewWriting(),
        'COMMUNITY_COMMENT': () => pointHistoryViewModel.addCommunityComment(),
        'REVIEW_COMMENT': () => pointHistoryViewModel.addReviewComment(),
        'WATCH_5SEC_AD': () => pointHistoryViewModel.addWatch5SecAd(),
        'WATCH_30SEC_AD': () => pointHistoryViewModel.addWatch30SecAd(),
      };

      for (int i = 0; i < pointHistoryViewModel.getPointHistoryList.length; i++) {
        String currentHistory = pointHistoryViewModel.getPointHistoryList[i].pointHistory;
        if (pointHistoryActions.containsKey(currentHistory)) {
          pointHistoryActions[currentHistory]!();
        }
      }

      /// 세금 정보 가져오기
      TaxInfo taxInfo = await _commonRepository.getTaxInfo(DateTime.now().year.toString());
      manHourViewModel.setTaxInfo = taxInfo;


      /// FCM Token 만료 체크 및 교체
      String? myDeviceToken;
      await FirebaseMessaging.instance.getToken().then((value) {
        myDeviceToken = value;
      });

      String dbToken = await _memberRepository.getDeviceToken();

      /// FCM 토큰이 DB 와 다를 경우 update
      if (myDeviceToken.toString() != "" && myDeviceToken.toString() != dbToken) {
        bool result = await _memberRepository.changeDeviceToken(myDeviceToken.toString());
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

  Future<InterstitialAd?> getInterstitialAd() async {
    final provider = getIt.get<TempNogari>();

    await InterstitialAd.load(
      adUnitId: Glob.testInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (ad) {

            },
            onAdImpression: (ad) {
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
            },
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
            },
            onAdClicked: (ad) {
            },
          );

          _interstitialAd = ad;
          _interstitialAd!.show();
          provider.setIsWatchingAd(true);
          Future.microtask(() => provider.callNotify());
        },
        onAdFailedToLoad: (LoadAdError error) {
        },
      ),
    );
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

  String getConditionLabel(SearchCondition condition) {
    switch (condition) {
      case SearchCondition.title:
        return '제목';
      case SearchCondition.titleContent:
        return '제목 + 내용';
      case SearchCondition.content:
        return '내용';
      case SearchCondition.nickname:
        return '닉네임';
    }
  }


}
