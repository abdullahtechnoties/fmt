import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:intl/intl.dart';

class OrderHistoryCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final int bulkQty;
  final double bulkPrice;
  final double currentPrice;
  final VoidCallback onRemove;

  const OrderHistoryCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.bulkQty,
    required this.bulkPrice,
    required this.currentPrice,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,##0', 'en_US');

    return Container(
      margin: EdgeInsets.only(bottom: R.h(16)),
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
        padding: EdgeInsets.all(R.w(16)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AppCachedImage(
              imageUrl: imageUrl,
              width: R.w(70),
              height: R.h(70),
              fit: BoxFit.contain,
              borderRadius: BorderRadius.circular(R.w(8)),
            ),
            SizedBox(width: R.w(16)),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(15),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: R.h(6)),
                  Text(
                    'order_history.buy_bulk'.trnsFormat({
                      'qty': bulkQty,
                      'price': format.format(bulkPrice),
                    }),
                    style: TextStyle(
                      fontSize: R.sp(13),
                      fontWeight: FontWeight.w500,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  SizedBox(height: R.h(6)),
                  Text(
                    '${'home.currency_symbol'.trns()}${format.format(currentPrice)}',
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Close/Remove Button
            GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: EdgeInsets.only(left: R.w(8)),
                // TODO: Replace with custom SVG cross icon if needed
                child: Icon(Icons.close, size: R.sp(20), color: AppColors.darkGrey),
              ),
            )
          ],
        ),
      ),
    );
  }
}