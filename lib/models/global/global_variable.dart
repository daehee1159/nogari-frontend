import 'dart:io';

import 'package:flutter/material.dart';

class Glob {
  static const String serverUrlAndPort = '';

  static String serverUrl = 'http://${Platform.environment['SERVER_URL'] ?? '10.0.2.2:80'}';
  static String memberUrl = 'http://${Platform.environment['MEMBER_URL'] ?? '10.0.2.2:80'}/api/member';
  static String accessTokenUrl = 'http://${Platform.environment['ACCESS_TOKEN_URL'] ?? '10.0.2.2:80'}/authenticate';
  static String communityUrl = 'http://${Platform.environment['COMMUNITY_URL'] ?? '10.0.2.2:80'}/api/community';
  static String reviewUrl = 'http://${Platform.environment['REVIEW_URL'] ?? '10.0.2.2:80'}/api/review';
  static String manHourUrl = 'http://${Platform.environment['MAN_HOUR_URL'] ?? '10.0.2.2:80'}/api/man-hour';
  static String commonUrl = 'http://${Platform.environment['COMMON_URL'] ?? '10.0.2.2:80'}/api/common';
  static const String privacySiteUrl = 'https://sites.google.com/view/nogari-privacy';
  static const String termsSiteUrl = 'https://sites.google.com/view/nogari-terms';

  static String testAdmobBannerId = Platform.isIOS ? Platform.environment['IOS_AD_BANNER_ID'].toString() : Platform.environment['ANDROID_AD_BANNER_ID'].toString();
  static String admobBannerId = '';
  static String testInterstitialAdId = Platform.isIOS ? Platform.environment['IOS_AD_INTERSTITIAL_ID'].toString() : Platform.environment['ANDROID_AD_INTERSTITIAL_ID'].toString();
  static String interstitialAdId = '';

  static const String registration = 'registration';

  static const String email = 'email';
  static const String memberSeq = 'memberSeq';
  static const String insuranceStatus = 'insuranceStatus';

  static const String accessToken = "accessToken";
  static const String refreshToken = "refreshToken";

  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.msm.nogari';
  static const String appStoreUrl = 'https://apps.apple.com/kr/app/%EB%85%B8%EA%B0%80%EB%A6%AC/id6479215289';

  static const String kakaoAuthorization = '';
  static const String identifier = "identifier";
}
