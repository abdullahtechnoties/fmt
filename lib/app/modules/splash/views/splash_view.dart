import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // fullscreen image background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.logoOpacity.value,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeIn,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.8,
                        end: controller.logoOpacity.value == 1.0 ? 1.0 : 0.8,
                      ),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOutBack,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Animated Tagline
                // Obx(
                //   () => AnimatedOpacity(
                //     opacity: controller.taglineOpacity.value,
                //     duration: const Duration(milliseconds: 600),
                //     curve: Curves.easeIn,
                //     child: Column(
                //       children: [
                //         Text(
                //           'Aroosi',
                //           style: TextStyle(
                //             fontSize: 32,
                //             fontWeight: FontWeight.bold,
                //             color: AppColors.primary,
                //             letterSpacing: 1.2,
                //           ),
                //         ),
                //         const SizedBox(height: 8),
                //         Text(
                //           'Your Wedding, Your Way',
                //           style: TextStyle(
                //             fontSize: 14,
                //             color: AppColors.onboardingMuted,
                //             letterSpacing: 0.5,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
