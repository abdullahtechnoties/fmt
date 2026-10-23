import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/utilities/translation_extention.dart';

class VerticalCategoryCard extends StatelessWidget {
  final String title;
  final int productCount;
  final String imageUrl;
  final VoidCallback onBrowse;

  const VerticalCategoryCard({
    super.key,
    required this.title,
    required this.productCount,
    required this.imageUrl,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(R.w(16)),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
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
            // Image
            Expanded(
              child: Center(
                child: AppCachedImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(R.w(8)),
                ),
              ),
            ),
            SizedBox(height: R.h(12)),
            
            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w700,
                color: AppColors.darkGrey,
                height: 1.2,
              ),
            ),
            SizedBox(height: R.h(4)),
            
            // Subtitle (Products Count)
            Text(
              'home.products_count'.trnsFormat({'count': productCount}),
              style: TextStyle(
                fontSize: R.sp(12),
                fontWeight: FontWeight.w500,
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: R.h(12)),
            
            // Browse Button
            SizedBox(
              width: double.infinity,
              height: R.h(27),
              child: ElevatedButton(
                onPressed: onBrowse,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(R.w(4)),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'home.browse'.trns(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}