import 'package:flutter/material.dart';
import 'package:fmt/app/modules/home/controllers/home_controller.dart';
import 'package:fmt/app/modules/productDetails/controllers/product_details_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/home_components.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    // Overriding background color to black to match the design inverted look
    return GradientScaffold(
      child: SingleChildScrollView(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- TOP WHITE CARD ---
              Container(
                padding: EdgeInsets.only(bottom: R.h(16)),
                width: double.infinity,
                decoration: BoxDecoration(
                  // color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(R.w(24)),
                    bottomRight: Radius.circular(R.w(24)),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button area over image
                      Padding(
                        padding: EdgeInsets.only(left: R.w(16), top: R.h(6)),
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(
                            Icons.chevron_left,
                            color: AppColors.black,
                            size: R.sp(44),
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      ),
                      SizedBox(height: R.h(6)),       
                      // Product Image (Carousel placeholder)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(R.w(12)),
                                topLeft: Radius.circular(R.w(12)),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(R.w(12)),
                                topLeft: Radius.circular(R.w(12)),
                              ),
                              child: AppCachedImage(
                                imageUrl: controller.productImages.first,
                                height: R.h(380),
                                width: double.infinity,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // SizedBox(height: R.h(16)),

                      // Title & Price Section
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: R.w(22)),
                        padding: EdgeInsets.symmetric(horizontal: R.w(10)),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(R.w(12)),
                            bottomRight: Radius.circular(R.w(12)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: R.h(16)),
                            Text(
                              controller.title.value,
                              style: TextStyle(
                                fontSize: R.sp(18),
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkGrey,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: R.h(12)),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${'home.currency_symbol'.trns()}${currencyFormat.format(controller.currentPrice.value)}',
                                  style: TextStyle(
                                    fontSize: R.sp(24),
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.black,
                                  ),
                                ),
                                SizedBox(width: R.w(10)),
                                Padding(
                                  padding: EdgeInsets.only(bottom: R.h(3)),
                                  child: Text(
                                    '${'home.currency_symbol'.trns()}${currencyFormat.format(controller.oldPrice.value)}',
                                    style: TextStyle(
                                      fontSize: R.sp(16),
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.lightGrey,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: R.h(24)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- BOTTOM BLACK AREA ---
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description & Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'details.description'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(18),
                            fontWeight: FontWeight.w700,
                            color: AppColors
                                .darkSurface, // Or use a grey scale color. Matching design:
                            // color: const Color(0xFF4A4A4A),
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.star,
                              size: R.sp(18),
                            ),
                            SizedBox(width: R.w(4)),
                            Text(
                              '${controller.rating.value}',
                              style: TextStyle(
                                fontSize: R.sp(16),
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                              ),
                            ),
                            Text(
                              '/5',
                              style: TextStyle(
                                fontSize: R.sp(12),
                                fontWeight: FontWeight.w900,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: R.h(12)),

                    // Text Content
                    _buildDarkBodyText(controller.description.value),
                    SizedBox(height: R.h(20)),

                    _buildDarkSubtitleText(
                      'details.product_specification'.trns(),
                    ),
                    _buildDarkBodyText(controller.specificationsText.value),
                    SizedBox(height: R.h(20)),

                    _buildDarkSubtitleText('details.feature'.trns()),
                    ...controller.features.map(
                      (feature) => _buildDarkBodyText(feature),
                    ),
                    SizedBox(height: R.h(20)),

                    _buildDarkSubtitleText('details.package_content'.trns()),
                    _buildDarkBodyText(controller.packageContent.value),
                    SizedBox(height: R.h(30)),

                    // Specification Table
                    Text(
                      'details.specification'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4A4A4A),
                      ),
                    ),
                    SizedBox(height: R.h(16)),
                    _buildSpecRow('details.sku'.trns(), controller.sku.value),
                    _buildSpecRow(
                      'details.category'.trns(),
                      controller.category.value,
                    ),
                    _buildSpecRow(
                      'details.availability'.trns(),
                      controller.availability.value,
                    ),
                    _buildSpecRow(
                      'details.product_type'.trns(),
                      controller.productType.value,
                    ),

                    SizedBox(height: R.h(40)), // Padding for bottom
                    Text(
                      "details.related_products".trns(),
                      style: TextStyle(
                        fontSize: R.sp(22),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(16)),
                    SizedBox(
                      height: R.h(260), // Match GridView item height approx
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.zero,
                        itemCount:
                            Get.find<HomeController>().specialProducts.length,
                        itemBuilder: (context, index) {
                          final product =
                              Get.find<HomeController>().specialProducts[index];
                          return Padding(
                            padding: EdgeInsets.only(right: R.w(16)),
                            child: ProductCard(
                              width: R.w(
                                170,
                              ), // Fixed width for horizontal list items
                              product: product,
                              onAddTap: () => Get.find<HomeController>()
                                  .onAddToCart(product),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: R.h(78)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkSubtitleText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(6)),
      child: Text(
        text,
        style: TextStyle(
          fontSize: R.sp(14),
          fontWeight: FontWeight.w700,
          color: const Color(0xFF8A8A8A),
        ),
      ),
    );
  }

  Widget _buildDarkBodyText(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: R.sp(14),
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B6B6B),
        height: 1.5,
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: R.w(110),
            child: Text(
              label,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w400,
                color: const Color(0xFF8A8A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
