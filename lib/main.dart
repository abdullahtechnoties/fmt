import 'package:flutter/material.dart';
import 'package:fmt/fmtapp.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:fmt/services/translation_service.dart';
import 'package:fmt/utilities/theme/theme_controller.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await _initializeServices();
  runApp(const Fmtapp());
}

Future<void> _initializeServices() async {
  await LocalStorageService.getPrefs();
  final authService = AuthService();
  Get.put(authService);
  await authService.ready;
  Get.put(ThemeController());
  Get.put(NetworkService());
  // await NotificationService.instance.init();
  // Stripe.publishableKey = PaymentConfig.stripePublishableKey;
  // await Stripe.instance.applySettings();

  // _configureUI();

  await _initializeTranslations();
}

Future<void> _initializeTranslations() async {
  Get.put(TranslationService());
  final savedLocale = await AuthService.getSavedLocale();
  final locale = savedLocale ?? 'en';
  await TranslationService.to.loadTranslations(locale);
}

// void _configureUI() {
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: AppColors.primary,
//       statusBarIconBrightness: Brightness.light,
//       statusBarBrightness: Brightness.dark,
//     ),
//   );

//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
// }
