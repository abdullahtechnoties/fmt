import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/categories/controllers/categories_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/vertical-category-card.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';

class CategoriesView extends GetView<CategoriesController> {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {

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
                    child: Icon(Icons.menu, size: R.sp(28), color: AppColors.darkGrey),
                  ),
                ],
              ),
              SizedBox(height: R.h(24)),

              // Search & Filter Row
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: R.h(58), 
                      child: InputField(
                        controller: controller.searchController,
                        hintText: 'categories.search_hint'.trns(),
                        prefixIcon: Icon(Icons.search, color: AppColors.lightGrey, size: R.sp(22)),
                        borderRadius: 12,
                        enabled: false, // Disable direct input
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(12)),
                  GestureDetector(
                    onTap: () {
                      // Handle filter action
                      Get.toNamed(Routes.FILTER);
                    },
                    child: Container(
                      height: R.h(55),
                      width: R.h(55),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                       
                        child: Icon(Icons.filter_alt_outlined, color: AppColors.white, size: R.sp(26)),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: R.h(24)),

              // Categories Grid
              Expanded(
                child: Obx(() => GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(bottom: R.h(24)),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: R.w(16),
                    mainAxisSpacing: R.h(16),
                    childAspectRatio: 0.72, // Adjust based on exact visual preference
                  ),
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final cat = controller.categories[index];
                    return VerticalCategoryCard(
                      title: cat['title'] as String,
                      productCount: cat['count'] as int,
                      imageUrl: cat['image'] as String,
                      onBrowse: () {
                        // Handle browse
                        Get.toNamed(Routes.PRODUCT_DETAILS,);
                      },
                    );
                  },
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}