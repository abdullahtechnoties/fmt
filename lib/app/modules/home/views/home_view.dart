import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/home/controllers/home_controller.dart';
import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/models/store_model.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/branch_selector.dart';
import 'package:fmt/widgets/home_components.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  StoreService get _storeService => Get.find<StoreService>();

  Future<void> _onBranchChosen(StoreModel store) async {
    final cartRepo = CartRepository();
    final cart = await cartRepo.fetchCart();
    final notEmpty = cartRepo.itemCount(cart.data) > 0;
    final switched = await _storeService.selectStore(
      store,
      cartNotEmpty: notEmpty,
      onClearCart: () async {
        final cleared = await cartRepo.clear();
        if (cleared.isError) throw Exception('clear-failed');
      },
    );
    if (switched) controller.refreshHome();
  }

  @override
  Widget build(BuildContext context) {
    R.init(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: Container(
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
          child: Obx(() {
            if (controller.isLoading.value) return _buildShimmerLoading();
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refreshHome,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.only(bottom: R.h(30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header ---
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(20), vertical: R.h(10)),
                      child: Column(
                        children: [
                          HomeTopHeader(
                            profileImageUrl: controller.userAvatar,
                            onSearchTap: () => ProductsController.open(
                              title: 'home.search_title'.trns(),
                              autofocusSearch: true,
                            ),
                            onMenuTap: () =>
                                Get.find<BottomnavController>().openDrawer(),
                          ),
                          SizedBox(height: R.h(10)),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: BranchSelector(onChanged: _onBranchChosen),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: R.h(12)),

                    // --- Promo Banner ---
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                      child: const PromoBanner(),
                    ),
                    SizedBox(height: R.h(24)),

                    // --- Categories Section ---
                    if (controller.categories.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                        child: SectionTitle(
                          title: 'home.categories'.trns(),
                          onViewAll: controller.openAllCategories,
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
                            final category = controller.categories[index];
                            return CategoryCard(
                              category: category,
                              onBrowse: () => controller.openCategory(category),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: R.h(28)),
                    ],

                    // --- Featured Products Section ---
                    if (controller.featuredProducts.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                        child: SectionTitle(
                          title: 'home.featured_products'.trns(),
                          onViewAll: controller.openFeatured,
                        ),
                      ),
                      SizedBox(height: R.h(16)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: R.w(16),
                            mainAxisSpacing: R.h(16),
                            childAspectRatio: 0.68,
                          ),
                          itemCount: controller.featuredProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                controller.featuredProducts[index];
                            return ProductCard(
                              product: product,
                              onAddTap: () =>
                                  controller.onAddToCart(product),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: R.h(28)),
                    ],

                    // --- Special Products Section ---
                    if (controller.specialProducts.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                        child: SectionTitle(
                          title: 'home.special_products'.trns(),
                          onViewAll: controller.openSpecial,
                        ),
                      ),
                      SizedBox(height: R.h(16)),
                      SizedBox(
                        height: R.h(260),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          padding:
                              EdgeInsets.symmetric(horizontal: R.w(20)),
                          itemCount: controller.specialProducts.length,
                          itemBuilder: (context, index) {
                            final product =
                                controller.specialProducts[index];
                            return Padding(
                              padding: EdgeInsets.only(right: R.w(16)),
                              child: ProductCard(
                                width: R.w(170),
                                product: product,
                                onAddTap: () =>
                                    controller.onAddToCart(product),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    SizedBox(height: R.h(78)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: R.w(120), height: R.h(40)),
                ShimmerBox(width: R.w(80), height: R.h(40), borderRadius: 30),
              ],
            ),
            SizedBox(height: R.h(12)),
            ShimmerBox(width: R.w(180), height: R.h(34), borderRadius: 20),
            SizedBox(height: R.h(24)),
            ShimmerBox(width: double.infinity, height: R.h(170), borderRadius: 16),
            SizedBox(height: R.h(24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: R.w(120), height: R.h(24)),
                ShimmerBox(width: R.w(80), height: R.h(30), borderRadius: 20),
              ],
            ),
            SizedBox(height: R.h(16)),
            Row(
              children: [
                ShimmerBox(width: R.w(280), height: R.h(150), borderRadius: 16),
                SizedBox(width: R.w(16)),
                ShimmerBox(width: R.w(50), height: R.h(150), borderRadius: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
