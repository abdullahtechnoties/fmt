// app/modules/onboarding/views/onboarding_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);

    // Force light status bar icons over dark image
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // ── PageView fills entire screen ─────────────────────────
          Container(
            decoration:  BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),

            padding:  EdgeInsets.only(top:MediaQuery.of(context).size.height * 0.2),
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              physics: const BouncingScrollPhysics(),
              itemCount: controller.totalSlides,
              itemBuilder: (context, index) {
                return _OnboardingPage(slide: controller.slides[index]);
              },
            ),
          ),

          // ── Overlay UI (counter + skip + bottom nav) ─────────────
          Obx(
            () => _OnboardingOverlay(
              currentIndex: controller.currentIndex.value,
              totalSlides: controller.totalSlides,
              isFirst: controller.isFirst,
              isLast: controller.isLast,
              onSkip: controller.skip,
              onNext: controller.goNext,
              onPrev: controller.goPrev,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Single onboarding page
// ─────────────────────────────────────────────────────────────
class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;
    final imageHeight = screenH * 0.37;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top image section ──────────────────────────────────────
        SizedBox(
          width: screenW,
          height: imageHeight,
          child: Center(
            child: Image.asset(
              slide.imagePath,
              width: screenW,
              height: imageHeight,
              fit: BoxFit.contain,
              // Bottom radius already baked into the asset per design
              // No ClipRRect needed per requirements
            ),
          ),
        ),

        // ── Text section ───────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: R.w(24),
              vertical: R.h(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Title
                Text(
                  slide.titleKey.trns(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(30),
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: R.h(16)),

                // Description
                Text(
                  slide.descKey.trns(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w500,
                    color: AppColors.mediumGrey,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Space for bottom nav bar (avoid content overlap)
        SizedBox(height: R.h(80)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Overlay: counter + skip (top) + nav (bottom)
// ─────────────────────────────────────────────────────────────
class _OnboardingOverlay extends StatelessWidget {
  const _OnboardingOverlay({
    required this.currentIndex,
    required this.totalSlides,
    required this.isFirst,
    required this.isLast,
    required this.onSkip,
    required this.onNext,
    required this.onPrev,
  });

  final int currentIndex;
  final int totalSlides;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Column(
      children: [
        // ── Top row: page counter + Skip ────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            top: safeTop + R.h(16),
            left: R.w(24),
            right: R.w(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Page counter: "1/3"
              Text(
                '${currentIndex + 1}/$totalSlides',
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                ),
              ),

              // Skip button
              GestureDetector(
                onTap: onSkip,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.w(4),
                    vertical: R.h(4),
                  ),
                  child: Text(
                    'onboarding.skip'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(17),
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),

        // ── Bottom row: Prev + dots + Next/Get Started ───────────────
        Padding(
          padding: EdgeInsets.only(
            left: R.w(24),
            right: R.w(24),
            bottom: safeBottom + R.h(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Prev button (hidden on first slide)
              SizedBox(
                width: R.w(60),
                child: isFirst
                    ? const SizedBox.shrink()
                    : GestureDetector(
                        onTap: onPrev,
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          'onboarding.prev'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(16),
                            fontWeight: FontWeight.w500,
                            color: AppColors.mediumGrey,
                          ),
                        ),
                      ),
              ),

              // Dots indicator
              _DotsIndicator(count: totalSlides, currentIndex: currentIndex),

              // Next / Get Started button
              SizedBox(
                width: R.w(100),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: onNext,
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      isLast
                          ? 'onboarding.get_started'.trns()
                          : 'onboarding.next'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Dots indicator — animated active pill + inactive circle dots
// ─────────────────────────────────────────────────────────────
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          margin: EdgeInsets.symmetric(horizontal: R.w(4)),
          width: isActive ? R.w(28) : R.w(8),
          height: R.h(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.lightGrey,
            borderRadius: BorderRadius.circular(R.w(8)),
          ),
        );
      }),
    );
  }
}
