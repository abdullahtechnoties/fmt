import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/categories/controllers/categories_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:fmt/widgets/vertical-category-card.dart';
import 'package:get/get.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          child: Column(
            children: [
              SizedBox(height: R.h(16)),

              // Custom Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'categories.title'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(26),
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.find<BottomnavController>().openDrawer();
                    },
                    child: Icon(Icons.menu,
                        size: R.sp(28), color: AppColors.darkGrey),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),

              // Search & Browse-all Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: R.h(58),
                      child: InputField(
                        onChanged: controller.onSearchChanged,
                        hintText: 'categories.search_hint'.trns(),
                        prefixIcon: Icon(Icons.search,
                            color: AppColors.lightGrey, size: R.sp(22)),
                        borderRadius: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  GestureDetector(
                    onTap: controller.browseAll,
                    child: Container(
                      height: R.h(55),
                      width: R.h(55),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.grid_view_rounded,
                            color: AppColors.white, size: R.sp(26)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: R.h(24)),

              // Categories Grid
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const _CategoriesShimmer();
                  }
                  if (controller.loadError.value != null &&
                      controller.visibleCategories.isEmpty) {
                    return _ErrorState(
                      message: controller.loadError.value!,
                      onRetry: controller.loadCategories,
                    );
                  }
                  if (controller.visibleCategories.isEmpty) {
                    return _EmptyState(query: controller.searchQuery.value);
                  }
                  final cats =
                      controller.flattened(controller.visibleCategories);
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: controller.refreshCategories,
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.only(bottom: R.h(24)),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: R.w(16),
                        mainAxisSpacing: R.h(16),
                        childAspectRatio: 0.72,
                      ),
                      itemCount: cats.length,
                      itemBuilder: (context, index) {
                        final cat = cats[index];
                        return VerticalCategoryCard(
                          title: cat.name,
                          productCount: cat.productsCount,
                          imageUrl: cat.image ?? '',
                          onBrowse: () => controller.openCategory(cat),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoriesShimmer extends StatelessWidget {
  const _CategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: R.h(24)),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: R.w(16),
        mainAxisSpacing: R.h(16),
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerBox(
                width: double.infinity, height: double.infinity,
                borderRadius: 16),
          ),
          SizedBox(height: R.h(10)),
          ShimmerBox(width: R.w(110), height: R.h(14), borderRadius: 6),
          SizedBox(height: R.h(6)),
          ShimmerBox(width: R.w(70), height: R.h(12), borderRadius: 6),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: SizedBox(
        height: R.h(420),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_outlined,
                  size: R.sp(52), color: AppColors.lightGrey),
              SizedBox(height: R.h(12)),
              Text(
                query.trim().isEmpty
                    ? 'categories.empty_title'.trns()
                    : 'categories.no_results'
                        .trnsFormat({'query': query.trim()}),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: R.sp(15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: R.sp(48), color: AppColors.lightGrey),
          SizedBox(height: R.h(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(32)),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: R.sp(14), color: AppColors.mediumGrey),
            ),
          ),
          SizedBox(height: R.h(16)),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.w(10)),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(24), vertical: R.h(12)),
            ),
            child: Text(
              'common.retry'.trns(),
              style: TextStyle(
                color: AppColors.white,
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
