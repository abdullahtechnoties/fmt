import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/dummy_models.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/r.dart'; // Import your R helper
// import 'package:fmt/widgets/app_cached_image.dart'; // Import your image helper
// import 'package:fmt/utilities/translation_extention.dart';

// --- Formatters ---
final _currencyFormat = NumberFormat('#,##0', 'en_US');

// --- Top Header Widget ---
class HomeTopHeader extends StatelessWidget {
  final String profileImageUrl;
  final VoidCallback onSearchTap;
  final VoidCallback onMenuTap;

  const HomeTopHeader({
    super.key,
    required this.profileImageUrl,
    required this.onSearchTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // REPLACE WITH ACTUAL ASSET PATH: 'assets/images/fmt_logo.png'
        // Image.network(
        //   'https://dummyimage.com/150x50/fff/00b9ae.png&text=FMT+Logo',
        // ),
        Image.asset('assets/images/logo.png',
          height: R.h(95),
          fit: BoxFit.contain,
         
        ),
        Row(
          children: [
            IconButton(
              onPressed: onSearchTap,
              icon: Icon(CupertinoIcons.search, size: R.sp(28), color: AppColors.darkGrey),
              splashRadius: 24,
            ),
            SizedBox(width: R.w(8)),
            Container(
              height: R.h(57),
              padding: EdgeInsets.only(left: R.w(4), right: R.w(12)),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: R.h(20),
                    backgroundColor: AppColors.white,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                  SizedBox(width: R.w(10)),
                  GestureDetector(
                    onTap: onMenuTap,
                    child: Icon(Icons.menu, color: AppColors.white, size: R.sp(24)),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }
}

// --- Section Title Widget ---
class SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const SectionTitle({
    super.key,
    required this.title,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: R.sp(22),
            fontWeight: FontWeight.w700,
            color: AppColors.darkGrey,
          ),
        ),
        InkWell(
          onTap: onViewAll,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(6)),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Text(
                  'home.view_all'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(width: R.w(4)),
                Icon(Icons.play_arrow, color: AppColors.white, size: R.sp(14)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- Promo Banner Widget ---
class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: R.h(170),
      decoration: BoxDecoration(
        color: const Color(0xFF333333), // Dark grey from design
        borderRadius: BorderRadius.circular(R.w(16)),
      ),
      child:  Image.asset(
                  'assets/images/Frame 427320798.png',
                  width: R.w(200),
                  fit: BoxFit.fill,
                ),
    );
  }
}

// --- Category Card Widget ---
class CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.w(270),
      margin: EdgeInsets.only(right: R.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha:0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Image Left
          Padding(
            padding: EdgeInsets.all(R.w(12)),
            child: AppCachedImage(
              imageUrl: category.imageUrl,
              width: R.w(130),
              height: R.h(130),
              borderRadius: BorderRadius.circular(R.w(12)),
              fit: BoxFit.contain,
            ),
          ),
          // Content Right
          Expanded(
            child: Padding(
              padding: EdgeInsets.only( top: R.w(16), bottom: R.w(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: R.h(18)),
                  Text(
                    category.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(18),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: R.h(6)),
                  Text(
                    'home.products_count'.trnsFormat({'count': category.productCount}),
                    style: TextStyle(
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: R.w(100),
                    height: R.h(30),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(R.w(8)),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        'home.browse'.trns(),
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: R.h(12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- Product Card Widget (Used for Grid and Horizontal list) ---
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onAddTap;
  final double? width;

  const ProductCard({
    super.key, 
    required this.product, 
    required this.onAddTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to product details page
        Get.toNamed(Routes.PRODUCT_DETAILS, arguments: product);
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.w(16)),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(R.w(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(R.w(13)),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: AppCachedImage(
                    imageUrl: product.imageUrl,
                    height: R.h(120),
                    width: double.infinity,
                    fit: BoxFit.contain,
                    borderRadius: BorderRadius.circular(R.w(8)),
                  ),
                ),
              ),
              SizedBox(height: R.h(12)),
              
              // Title & Rating
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: R.sp(14),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                        height: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: R.w(4)),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.star, size: R.sp(14)),
                      SizedBox(width: R.w(2)),
                      Text(
                        '(${product.rating.toString()})',
                        style: TextStyle(
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      )
                    ],
                  )
                ],
              ),
              SizedBox(height: R.h(4)),
              
              // Category subtitle
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w400,
                  color: AppColors.lightGrey,
                ),
              ),
              const Spacer(),
              
              // Price & Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${'home.currency_symbol'.trns()}${_currencyFormat.format(product.price)}',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                  GestureDetector(
                    onTap: onAddTap,
                    child: Container(
                      padding: EdgeInsets.all(R.w(6)),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: AppColors.white, size: R.sp(20)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}