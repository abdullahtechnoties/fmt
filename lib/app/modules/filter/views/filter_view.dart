import 'package:flutter/material.dart';
import 'package:fmt/app/modules/filter/controllers/filter_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';

class FilterView extends GetView<FilterController> {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeaderBar(title: 'filter.title'.trns()),
            
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: R.w(20)),
                physics: const BouncingScrollPhysics(),
                child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: R.h(20)),
                    // --- Price Section ---
                    Text(
                      'filter.price'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(16)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'home.currency_symbol'.trns()}${currencyFormat.format(controller.currentRangeValues.value.start)}',
                          style: TextStyle(fontSize: R.sp(14), color: AppColors.darkGrey),
                        ),
                        Text(
                          '${'home.currency_symbol'.trns()}${currencyFormat.format(controller.currentRangeValues.value.end)}',
                          style: TextStyle(fontSize: R.sp(14), color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.inputBorder,
                        thumbColor: AppColors.primary,
                        overlayColor: AppColors.primary.withOpacity(0.2),
                        trackHeight: 4.0,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: R.w(8)),
                      ),
                      child: RangeSlider(
                        values: controller.currentRangeValues.value,
                        min: 0,
                        max: 50000,
                        onChanged: controller.updatePriceRange,
                      ),
                    ),
                    SizedBox(height: R.h(30)),

                    // --- Stock Section ---
                    Text(
                      'filter.stock'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(16)),
                    Wrap(
                      spacing: R.w(12),
                      children: controller.stockOptions.map((stock) {
                        final isSelected = controller.selectedStock.value == stock;
                        return GestureDetector(
                          onTap: () => controller.setStock(stock),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(10)),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.white,
                              borderRadius: BorderRadius.circular(R.w(24)),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.white, // No border visible if not primary in design
                              ),
                              boxShadow: [
                                if (!isSelected)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                              ],
                            ),
                            child: Text(
                              stock,
                              style: TextStyle(
                                fontSize: R.sp(14),
                                fontWeight: FontWeight.w500,
                                color: isSelected ? AppColors.white : AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: R.h(30)),

                    // --- Categories Section ---
                    Text(
                      'filter.categories'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    SizedBox(height: R.h(16)),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.categories.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.inputBorder,
                        height: R.h(24),
                      ),
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final isSelected = controller.selectedCategory.value == category;
                        return InkWell(
                          onTap: () => controller.setCategory(category),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: R.h(4)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: R.sp(15),
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.darkGrey,
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check, color: AppColors.primary, size: R.sp(20)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: R.h(40)),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}