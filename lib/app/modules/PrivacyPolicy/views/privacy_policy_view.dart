// app/modules/privacy_policy/views/privacy_policy_view.dart

import 'package:flutter/material.dart';
import 'package:fmt/app/modules/PrivacyPolicy/controllers/privacy_policy_controller.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:shimmer/shimmer.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Bar ───────────────────────────────────────────
            // AppTopBar(),
             CustomHeaderBar(
              title: 'profile.privacy_policy'.trns(),
              showmenu: false,
            ),

            // ─── Content ───────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _PrivacyPolicyShimmer();
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: R.w(20),
                    right: R.w(20),
                    bottom: R.h(32) + safeBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page Title ────────────────────────────────
                      Text(
                        'privacy_policy.title'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(32),
                          fontWeight: FontWeight.w800,
                          color: AppColors.black,
                          height: 1.15,
                        ),
                      ),

                      SizedBox(height: R.h(24)),

                      // ── Section Tabs ──────────────────────────────
                      Obx(() => _SectionTabs(
                            sections: controller.sections,
                            selectedIndex:
                                controller.selectedSectionIndex.value,
                            onSectionTap: controller.selectSection,
                          )),

                      SizedBox(height: R.h(24)),

                      // ── Policy Content ────────────────────────────
                      Obx(() {
                        final content =
                            controller.currentSection.content;
                        final paragraphs = content.split('\n\n');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: paragraphs.map((para) {
                            return Padding(
                              padding:
                                  EdgeInsets.only(bottom: R.h(16)),
                              child: Text(
                                para,
                                style: TextStyle(
                                  fontSize: R.sp(16),
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  height: 1.65,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Section Tabs — matches Figma list style
// ─────────────────────────────────────────────────────────────
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({
    required this.sections,
    required this.selectedIndex,
    required this.onSectionTap,
  });

  final List<PolicySection> sections;
  final int selectedIndex;
  final void Function(int) onSectionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(sections.length, (index) {
        final section = sections[index];
        final isSelected = selectedIndex == index;
        // final isFirst = index == 0;
        // final  isLast= index == sections.length - 1;

        return GestureDetector(
          onTap: () => onSectionTap(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: EdgeInsets.only(bottom: R.h(10)),
            padding: EdgeInsets.symmetric(
              horizontal: R.w(20),
              vertical: R.h(18),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.white,
              borderRadius: BorderRadius.circular(R.w(10)),
              border: isSelected
                  ? null
                  : Border.all(
                      color: AppColors.inputBorder,
                      width: 1,
                    ),
            ),
            child: Text(
              section.titleKey.trns(),
              style: TextStyle(
                fontSize: R.sp(15),
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.black,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Privacy Policy Shimmer
// ─────────────────────────────────────────────────────────────
class _PrivacyPolicyShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: R.w(20),
          vertical: R.h(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            ShimmerBox(
                width: R.w(220), height: R.h(36), borderRadius: 8),
            SizedBox(height: R.h(24)),

            // Section tabs shimmer
            ...List.generate(4, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: R.h(10)),
                child: ShimmerBox(
                  width: double.infinity,
                  height: R.h(56),
                  borderRadius: R.w(10),
                ),
              );
            }),

            SizedBox(height: R.h(24)),

            // Content shimmer
            ...List.generate(8, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: R.h(10)),
                child: ShimmerBox(
                  width: i % 3 == 2 ? R.w(240) : double.infinity,
                  height: R.h(14),
                  borderRadius: 4,
                ),
              );
            }),
            SizedBox(height: R.h(16)),
            ...List.generate(6, (i) {
              return Padding(
                padding: EdgeInsets.only(bottom: R.h(10)),
                child: ShimmerBox(
                  width: i % 4 == 3 ? R.w(200) : double.infinity,
                  height: R.h(14),
                  borderRadius: 4,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}