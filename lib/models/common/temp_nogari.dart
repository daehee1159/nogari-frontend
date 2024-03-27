import 'package:flutter/material.dart';

class TempNogari extends ChangeNotifier {
  late bool _isWatchingAd = false;
  // set setIsWatchingAd(newValue) {
  //   _isWatchingAd = newValue;
  //   notifyListeners();
  // }
  bool get getIsWatchingAd => _isWatchingAd;

  ValueNotifier<bool> _isWatchingAdNotifier = ValueNotifier<bool>(false);

  ValueNotifier<bool> get isWatchingAdNotifier => _isWatchingAdNotifier;

  // 다른 곳에서 _isWatchingAdNotifier 값을 변경하는 메서드 또는 함수
  void setIsWatchingAd(bool value) {
    _isWatchingAdNotifier.value = value;
    // notifyListeners(); // 변경을 감지하도록 알림
  }

  /// SplashScreen 으로 이동 시 이 값을 true 설정 후 route 해야함
  bool _isIntentional = false;
  set setIsIntentional(newValue) {
    _isIntentional = newValue;
    notifyListeners();
  }
  bool get getIsIntentional => _isIntentional;

  void callNotify() {
    notifyListeners();
  }
}
