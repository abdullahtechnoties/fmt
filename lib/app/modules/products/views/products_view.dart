import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/products/controllers/products_controller.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/home_components.dart';
import 'package:fmt/widgets/inputfield.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';

class ProductsView extends GetView<ProductsController> {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              showmenu: false,
              title: controller.title.value,
              onMenu: () => Get.find<BottomnavController>().openDrawer(),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(20)),
              child: _SearchRow(onFilterTap: () => _openFilterSheet(context)),
            ),
            SizedBox(height: R.h(12)),
            _CategoryChips(),
            SizedBox(height: R.h(12)),
            Flexible(child: _Body(onRetry: controller.loadFirst)),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterSheet(BuildContext context) =>
      showProductsFilterSheet(context, controller);
}

class _Body extends StatelessWidget {
  const _Body({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsController>();
    return Obx(() {
      if (controller.isLoading.value) return const _GridShimmer();
      if (controller.loadError.value != null && controller.products.isEmpty) {
        return _ErrorState(
          message: controller.loadError.value!,
          onRetry: onRetry,
        );
      }
      if (controller.products.isEmpty) {
        return _EmptyState(onClear: controller.clearAllFilters);
      }
      return Column(
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(4)),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'products.results_count'
                    .trnsFormat({'count': controller.total.value}),
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w500,
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: controller.refreshList,
              child: GridView.builder(
                controller: controller.scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.fromLTRB(
                    R.w(20), R.h(4), R.w(20), R.h(100)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: R.w(16),
                  mainAxisSpacing: R.h(16),
                  childAspectRatio: 0.68,
                ),
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  final product = controller.products[index];
                  return ProductCard(
                    product: product,
                    onAddTap: () => controller.onAddToCart(product),
                  );
                },
              ),
            ),
          ),
          if (controller.isLoadingMore.value)
            Padding(
              padding: EdgeInsets.only(bottom: R.h(90), top: R.h(4)),
              child: const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2.5,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.onFilterTap});

  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsController>();
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: R.h(58),
            child: Obx(
              () => InputField(
                controller: controller.searchController,
                focusNode: controller.searchFocusNode,
                hintText: 'products.search_hint'.trns(),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.lightGrey,
                  size: R.sp(22),
                ),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: controller.clearSearch,
                        child: Icon(
                          Icons.clear,
                          color: AppColors.lightGrey,
                          size: R.sp(20),
                        ),
                      )
                    : null,
                borderRadius: 12,
                textInputAction: TextInputAction.search,
                onChanged: controller.onSearchChanged,
              ),
            ),
          ),
        ),
        SizedBox(width: R.w(12)),
        GestureDetector(
          onTap: onFilterTap,
          child: Obx(() {
            final active = controller.hasActiveFilters;
            return Container(
              height: R.h(55),
              width: R.h(55),
              decoration: BoxDecoration(
                color: active ? AppColors.darkGrey : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.filter_alt_outlined,
                  color: AppColors.white,
                  size: R.sp(26),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsController>();
    return Obx(() {
      if (controller.categories.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: R.h(40),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: R.w(20)),
          itemCount: controller.categories.length + 1,
          separatorBuilder: (_, _) => SizedBox(width: R.w(8)),
          itemBuilder: (context, index) {
            if (index == 0) {
              final noneSelected = controller.selectedCategoryIds.isEmpty;
              return _Chip(
                label: 'products.all'.trns(),
                selected: noneSelected,
                onTap: controller.clearCategoryFilter,
              );
            }
            final cat = controller.categories[index - 1];
            return Obx(() => _Chip(
                  label: cat.name,
                  selected:
                      controller.selectedCategoryIds.contains(cat.id),
                  onTap: () => controller.toggleCategory(cat.id),
                ));
          },
        ),
      );
    });
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: R.w(16)),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: R.sp(13),
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.darkGrey,
          ),
        ),
      ),
    );
  }
}

class _GridShimmer extends StatelessWidget {
  const _GridShimmer();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(R.w(20), R.h(4), R.w(20), R.h(24)),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: R.w(16),
          mainAxisSpacing: R.h(16),
          childAspectRatio: 0.68,
        ),
        itemCount: 6,
        itemBuilder: (context, _) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
                width: double.infinity, height: R.h(130), borderRadius: 16),
            SizedBox(height: R.h(10)),
            ShimmerBox(width: R.w(110), height: R.h(14), borderRadius: 6),
            SizedBox(height: R.h(6)),
            ShimmerBox(width: R.w(70), height: R.h(14), borderRadius: 6),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: SizedBox(
          height: R.h(420),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: R.w(84),
                  height: R.w(84),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: R.sp(38),
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: R.h(16)),
                Text(
                  'products.empty_title'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(18),
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: R.h(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.w(48)),
                  child: Text(
                    'products.empty_message'.trns(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.sp(14),
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ),
                SizedBox(height: R.h(16)),
                ElevatedButton(
                  onPressed: onClear,
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
                    'products.clear_filters'.trns(),
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: R.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_outlined,
                size: R.sp(48), color: AppColors.lightGrey),
            SizedBox(height: R.h(12)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.w(48)),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: R.sp(14), color: AppColors.mediumGrey),
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
      ),
    );
  }
}

/// Bottom sheet with sort + stock filters. Selections are staged locally and
/// committed with Apply; Clear resets everything.
Future<void> showProductsFilterSheet(
  BuildContext context,
  ProductsController controller,
) {
  var draftSort = controller.sort.value;
  var draftStock = controller.stock.value;

  Widget option({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: R.h(8)),
        padding:
            EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(13)),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(R.w(12)),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: R.sp(14),
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color:
                      active ? AppColors.primary : AppColors.darkGrey,
                ),
              ),
            ),
            if (active)
              Icon(Icons.check_circle,
                  color: AppColors.primary, size: R.sp(20)),
          ],
        ),
      ),
    );
  }

  return Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setSheetState) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(24))),
        ),
        padding: EdgeInsets.fromLTRB(R.w(20), R.h(12), R.w(20), R.h(28)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: R.w(44),
                    height: R.h(4),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                SizedBox(height: R.h(16)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'products.filter_title'.trns(),
                      style: TextStyle(
                        fontSize: R.sp(18),
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setSheetState(() {
                          draftSort = ProductsController.sortLatest;
                          draftStock = ProductsController.stockAll;
                        });
                      },
                      child: Text(
                        'products.clear'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(14),
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.h(16)),
                Text(
                  'products.sort_by'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: R.h(10)),
                for (final value in ProductsController.sortOptions)
                  option(
                    label: 'products.sort_$value'.trns(),
                    active: draftSort == value,
                    onTap: () => setSheetState(() => draftSort = value),
                  ),
                SizedBox(height: R.h(12)),
                Text(
                  'products.availability'.trns(),
                  style: TextStyle(
                    fontSize: R.sp(15),
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey,
                  ),
                ),
                SizedBox(height: R.h(10)),
                option(
                  label: 'products.stock_all'.trns(),
                  active: draftStock == ProductsController.stockAll,
                  onTap: () => setSheetState(
                      () => draftStock = ProductsController.stockAll),
                ),
                option(
                  label: 'products.stock_in_stock'.trns(),
                  active: draftStock == ProductsController.stockIn,
                  onTap: () => setSheetState(
                      () => draftStock = ProductsController.stockIn),
                ),
                option(
                  label: 'products.stock_out_of_stock'.trns(),
                  active: draftStock == ProductsController.stockOut,
                  onTap: () => setSheetState(
                      () => draftStock = ProductsController.stockOut),
                ),
                SizedBox(height: R.h(16)),
                SizedBox(
                  width: double.infinity,
                  height: R.h(52),
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters(
                        nextSort: draftSort,
                        nextStock: draftStock,
                      );
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(12)),
                      ),
                    ),
                    child: Text(
                      'products.apply'.trns(),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: R.sp(16),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
