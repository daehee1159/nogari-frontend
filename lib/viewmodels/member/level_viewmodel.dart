import 'package:flutter/material.dart';

class LevelViewModel extends ChangeNotifier {
  int? levelSeq;
  int? level;
  int point = 0;

  int? get getLevelSeq => levelSeq;
  int? get getLevel => level;
  int get getPoint => point;

  set setLevelSeq(int? value) {
    levelSeq = value;
    notifyListeners();
  }

  set setLevel(int? value) {
    level = value;
    notifyListeners();
  }

  set setPoint(int value) {
    point = value;
    notifyListeners();
  }
}
