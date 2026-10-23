import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';

class TranslationService extends GetxController {
  static TranslationService get to => Get.find();

  Map<String, dynamic> _translations = {};
  final RxString currentLocale = 'en'.obs;
  final RxBool isLoaded = false.obs;

  Future<void> loadTranslations(String languageCode) async {
    final jsonString = await rootBundle.loadString(
      'assets/translations/$languageCode.json',
    );
    _translations = jsonDecode(jsonString) as Map<String, dynamic>;
    currentLocale.value = languageCode;
    isLoaded.value = true;
    Get.updateLocale(Locale(languageCode));
  }

  String get(String key) {
    if (!isLoaded.value) return key;
    final parts = key.split('.');
    dynamic value = _translations;
    for (final part in parts) {
      if (value is Map && value.containsKey(part)) {
        value = value[part];
      } else {
        return key;
      }
    }
    return value is String ? value : key;
  }

  String format(String key, Map<String, dynamic> variables) {
    String text = get(key);
    variables.forEach((k, v) {
      text = text.replaceAll(':$k', v.toString());
    });
    return text;
  }
}
