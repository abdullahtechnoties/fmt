import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;
  static const String themeKey = 'is_dark_mode';

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool storedTheme = prefs.getBool(themeKey) ?? false;
    isDarkMode.value = storedTheme;
    Get.changeThemeMode(storedTheme ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDarkMode.value);
  }
}
