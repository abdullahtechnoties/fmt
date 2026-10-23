
import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/services/translation_service.dart';
import 'package:fmt/utilities/theme/dark_theme.dart';
import 'package:fmt/utilities/theme/light_theme.dart';
import 'package:fmt/utilities/theme/theme_controller.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';



class Fmtapp extends StatelessWidget {
  const Fmtapp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Obx(() {
      final locale = TranslationService.to.currentLocale.value;
      return GetMaterialApp(
        title: "app.name".trns(),
        initialRoute: AppPages.INITIAL,
        debugShowCheckedModeBanner: false,
        getPages: AppPages.routes,
        defaultTransition: Transition.fade,
        transitionDuration: const Duration(milliseconds: 300),
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        theme: LightTheme().lightTheme(context),
        darkTheme: DarkTheme().darkTheme(context),
        locale: Locale(locale),
        fallbackLocale: const Locale('en'),
      //   builder: (context, child) {
      //   return MediaQuery(
      //     data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(
      //        0.75,
      //     )),
      //     child: child!,
      //   );
      // },
      );
    });
  }
}
