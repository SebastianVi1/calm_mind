import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  int _currentPageIndex = 0;
  int get currentPageIndex => _currentPageIndex;

  void changePageIndex(int index) {
    _currentPageIndex = index;
    notifyListeners();
  }
}
