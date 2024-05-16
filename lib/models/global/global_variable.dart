import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Glob {
  static const String serverUrlAndPort = '';

  static String serverUrl = dotenv.get('SERVER_URL');
  static String memberUrl = dotenv.get('MEMBER_URL');
  static String accessTokenUrl = dotenv.get('ACCESS_TOKEN_URL');
  static String communityUrl = dotenv.get('COMMUNITY_URL');
  static String reviewUrl = dotenv.get('REVIEW_URL');
  static String manHourUrl = dotenv.get('MAN_HOUR_URL');
  static String commonUrl = dotenv.get('COMMON_URL');
  static String privacySiteUrl = dotenv.get('PRIVACY_SITE_URL');
  static String termsSiteUrl = dotenv.get('TERMS_SITE_URL');

  static String testAdmobBannerId = Platform.isIOS ? dotenv.get('ADMOB_BANNER_IOS_ID') : dotenv.get('ADMOB_BANNER_ANDROID_ID');
  static String admobBannerId = '';
  static String testInterstitialAdId = Platform.isIOS ? dotenv.get('INTERSTITIAL_AD_IOS_ID') : dotenv.get('INTERSTITIAL_AD_ANDROID_ID');
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
