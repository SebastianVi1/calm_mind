import 'package:flutter/material.dart';

// Key for unique scaffold key in all pages
final GlobalKey<ScaffoldState> globalScaffoldKey = GlobalKey<ScaffoldState>();

// Function for global drawer
void openGlobalEndDrawer(BuildContext context) {
  if (globalScaffoldKey.currentState?.isEndDrawerOpen == false) {
    globalScaffoldKey.currentState?.openEndDrawer();
  }
}
