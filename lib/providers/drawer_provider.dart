import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerProvider extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  
  void openEndDrawer() {
    if (_scaffoldKey.currentState?.isEndDrawerOpen == false) {
      _scaffoldKey.currentState?.openEndDrawer();
    }
  }
} 