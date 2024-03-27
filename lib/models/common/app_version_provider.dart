import 'package:flutter/material.dart';
import 'package:nogari/models/common/app_version_dto.dart';

class AppVersionProvider extends ChangeNotifier {
  AppVersionDto? appVersion;
  String? currentAppVersion;
  String? dbAppVersion;

  AppVersionDto? get getAppVersion => appVersion;
  String? get getCurrentAppVersion => currentAppVersion;
  String? get getDBAppVersion => dbAppVersion;

  set setAppVersion(AppVersionDto appVersionDto) {
    appVersion = appVersionDto;
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
}
