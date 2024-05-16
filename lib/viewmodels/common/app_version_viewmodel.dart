import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nogari/models/common/app_version.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../repositories/common/common_repository.dart';
import '../../repositories/common/common_repository_impl.dart';

class AppVersionViewModel extends ChangeNotifier {
  final CommonRepository _repository = CommonRepositoryImpl();

  AppVersion? appVersion;
  String? currentAppVersion;
  String? dbAppVersion;


  AppVersion? get getAppVersion => appVersion;
  String? get getCurrentAppVersion => currentAppVersion;
  String? get getDBAppVersion => dbAppVersion;

  set setAppVersion(AppVersion appVersion) {
    appVersion = appVersion;
    notifyListeners();
  }

  set setCurrentAppVersion(String appVersion) {
    currentAppVersion = appVersion;
    notifyListeners();
  }

  set setDBAppVersion(String version) {
    dbAppVersion = version;
    notifyListeners();
  }

  Future<void> initAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setCurrentAppVersion = packageInfo.version;
    AppVersion appVersion = await _repository.getAppVersion();
    setDBAppVersion = (Platform.isAndroid) ? appVersion.android : appVersion.ios;
    notifyListeners();
  }
}
