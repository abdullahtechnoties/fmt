import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? prefs;

  static Future<SharedPreferences> getPrefs() async {
    prefs ??= await SharedPreferences.getInstance();
    return prefs!;
  }
}