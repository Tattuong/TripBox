import 'package:flutter/material.dart';

class ShellProvider extends ChangeNotifier {
  int currentIndex = 1;

  void setIndex(int index) {
    if (currentIndex == index) return;
    currentIndex = index;
    notifyListeners();
  }
}
