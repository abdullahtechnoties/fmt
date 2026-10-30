import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:get/get.dart';

/// Small confirmation dialog used for destructive choices
/// (branch switch clears the cart, logout, account deletion…).
class AppConfirmDialog extends StatelessWidget {
  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText,
    this.cancelText,
    this.isDangerous = false,
  });

  final String title;
  final String message;
  final String? confirmText;
  final String? cancelText;
  final bool isDangerous;

  /// Shows the dialog and resolves to true when confirmed.
  static Future<bool?> show({
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    bool isDangerous = false,
  }) {
    return Get.dialog<bool>(
      AppConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDangerous: isDangerous,
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.w(16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(R.w(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w700,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: R.h(10)),
            Text(
              message,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w400,
                color: AppColors.grey,
                height: 1.5,
              ),
            ),
            SizedBox(height: R.h(20)),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      height: R.h(52),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBg,
                        borderRadius: BorderRadius.circular(R.w(10)),
                      ),
                      child: Text(
                        cancelText ?? 'common.cancel'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGrey,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: R.w(12)),
                Expanded(
                  child: SizedBox(
                    height: R.h(52),
                    child: MainBtn(
                      text: confirmText ?? 'common.confirm'.trns(),
                      color: isDangerous ? AppColors.red : AppColors.primary,
                      borderRadius: 10,
                      onPressed: () => Get.back(result: true),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
