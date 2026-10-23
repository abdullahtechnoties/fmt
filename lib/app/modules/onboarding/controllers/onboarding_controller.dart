// app/modules/onboarding/controllers/onboarding_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/network/service/auth_service.dart';

class OnboardingSlide {
  final String titleKey;
  final String descKey;
  final String imagePath;

  const OnboardingSlide({
    required this.titleKey,
    required this.descKey,
    required this.imagePath,
  });
}

class OnboardingController extends GetxController {
  late PageController pageController;

  final RxInt currentIndex = 0.obs;

  final List<OnboardingSlide> slides = const [
    OnboardingSlide(
      titleKey: 'onboarding.slide_1_title',
      descKey: 'onboarding.slide_1_desc',
      imagePath: 'assets/images/on1.png',
    ),
    OnboardingSlide(
      titleKey: 'onboarding.slide_2_title',
      descKey: 'onboarding.slide_2_desc',
      imagePath: 'assets/images/on2.png',
    ),
    OnboardingSlide(
      titleKey: 'onboarding.slide_3_title',
      descKey: 'onboarding.slide_3_desc',
      imagePath: 'assets/images/on3.png',
    ),
  ];

  int get totalSlides => slides.length;
  bool get isFirst => currentIndex.value == 0;
  bool get isLast => currentIndex.value == totalSlides - 1;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void goNext() {
    if (isLast) {
      _completeOnboarding();
      return;
    }
    pageController.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void goPrev() {
    if (isFirst) return;
    pageController.previousPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeInOutCubic,
    );
  }

  void skip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    // await LocalStorageService.prefs?.setBool('onboarding_done', true);
    await AuthService.firstTimeCompleted();
    Get.toNamed(Routes.LOGIN);
  }
}