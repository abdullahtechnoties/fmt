import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/home/controllers/home_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/home_components.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/r.dart';
// import 'package:fmt/widgets/shimmer_box.dart';
// import 'package:fmt/app/modules/home/controllers/home_controller.dart';
// import 'package:fmt/widgets/home_components.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context); // Ensure R is initialized

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Container(
        // The very light cyan gradient background at the top as per design
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment(0.0, -0.5),
            colors: [
              Color(0xFFCCF7F4),
              AppColors.scaffoldBg,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom: R.h(30)),
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildShimmerLoading();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Header ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(10)),
                    child: HomeTopHeader(
                      profileImageUrl: controller.userProfileImage,
                      onSearchTap: () {},
                      onMenuTap: () => Get.find<BottomnavController>().openDrawer(),
                    ),
                  ),
                  SizedBox(height: R.h(16)),

                  // --- Promo Banner ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: const PromoBanner(),
                  ),
                  SizedBox(height: R.h(24)),

                  // --- Categories Section ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: SectionTitle(
                      title: 'home.categories'.trns(),
                      onViewAll: () {},
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  SizedBox(
                    height: R.h(160),
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        return CategoryCard(category: controller.categories[index]);
                      },
                    ),
                  ),
                  SizedBox(height: R.h(28)),

                  // --- Featured Products Section ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: SectionTitle(
                      title: 'home.featured_products'.trns(),
                      onViewAll: () {},
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: R.w(16),
                        mainAxisSpacing: R.h(16),
                        childAspectRatio: 0.68, // Adjusted to match design aspect ratio
                      ),
                      itemCount: controller.featuredProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.featuredProducts[index];
                        return ProductCard(
                          product: product,
                          onAddTap: () => controller.onAddToCart(product),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: R.h(28)),

                  // --- Special Products Section ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                    child: SectionTitle(
                      title: 'home.special_products'.trns(),
                      onViewAll: () {},
                    ),
                  ),
                  SizedBox(height: R.h(16)),
                  SizedBox(
                    height: R.h(260), // Match GridView item height approx
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                      itemCount: controller.specialProducts.length,
                      itemBuilder: (context, index) {
                        final product = controller.specialProducts[index];
                        return Padding(
                          padding: EdgeInsets.only(right: R.w(16)),
                          child: ProductCard(
                            width: R.w(170), // Fixed width for horizontal list items
                            product: product,
                            onAddTap: () => controller.onAddToCart(product),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: R.h(78)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // Graceful Shimmer Loading State
  Widget _buildShimmerLoading() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: R.w(120), height: R.h(40)),
              ShimmerBox(width: R.w(80), height: R.h(40), borderRadius: 30),
            ],
          ),
          SizedBox(height: R.h(24)),
          // Banner Shimmer
          ShimmerBox(width: double.infinity, height: R.h(170), borderRadius: 16),
          SizedBox(height: R.h(24)),
          // Title Shimmer
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
                ShimmerBox(width: R.w(120), height: R.h(24)),
                ShimmerBox(width: R.w(80), height: R.h(30), borderRadius: 20),
             ],
          ),
          SizedBox(height: R.h(16)),
          // Horizontal List Shimmer
          Row(
            children: [
              ShimmerBox(width: R.w(280), height: R.h(150), borderRadius: 16),
              SizedBox(width: R.w(16)),
              ShimmerBox(width: R.w(50), height: R.h(150), borderRadius: 16), // cut off
            ],
          ),
        ],
      ),
    );
  }
}