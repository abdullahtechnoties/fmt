import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomnavController extends GetxController {
    var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();


  
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  void closeDrawer() {
    scaffoldKey.currentState?.closeDrawer();
  }

}