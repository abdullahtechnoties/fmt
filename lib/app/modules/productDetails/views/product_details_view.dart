import 'package:flutter/material.dart';
import 'package:fmt/app/modules/productDetails/controllers/product_details_controller.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/home_components.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0', 'en_US');

String _price(double v) =>
    '${'home.currency_symbol'.trns()}${_money.format(v)}';

class ProductDetailsView extends GetView<ProductDetailsController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) return const _DetailShimmer();
          final error = controller.loadError.value;
          if (error != null && controller.product == null) {
            return _ErrorState(message: error, onRetry: controller.loadDetail);
          }
          final product = controller.product;
          if (product == null) {
            return _ErrorState(
                message: 'details.load_failed'.trns(),
                onRetry: controller.loadDetail);
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.loadDetail,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Gallery(product: product),
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                              R.w(20), R.h(16), R.w(20), R.h(90)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TitleBlock(product: product),
                              SizedBox(height: R.h(16)),
                              _PriceBlock(),
                              SizedBox(height: R.h(20)),
                              _OptionPickers(product: product),
                              _QuantityRow(),
                              if ((product.description?.trim().isNotEmpty ??
                                  false)) ...[
                                SizedBox(height: R.h(20)),
                                _DescriptionBlock(product: product),
                              ],
                              SizedBox(height: R.h(12)),
                              _SpecRows(product: product),
                              if (product.relatedProducts.isNotEmpty) ...[
                                SizedBox(height: R.h(24)),
                                _RelatedBlock(product: product),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _BottomBar(),
            ],
          );
        }),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();
    final images = product.allImages;
    return Container(
      color: AppColors.white,
      child: Stack(
        children: [
          SizedBox(
            height: R.h(320),
            child: images.isEmpty
                ? Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        size: R.sp(56), color: AppColors.lightGrey),
                  )
                : PageView.builder(
                    onPageChanged: controller.onGalleryChanged,
                    itemCount: images.length,
                    itemBuilder: (context, i) => AppCachedImage(
                      imageUrl: images[i],
                      width: double.infinity,
                      height: R.h(320),
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
          Positioned(
            top: R.h(12),
            left: R.w(16),
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: R.w(40),
                height: R.w(40),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Icon(Icons.arrow_back,
                    size: R.sp(20), color: AppColors.darkGrey),
              ),
            ),
          ),
          if (product.hasDiscount)
            Positioned(
              top: R.h(16),
              right: R.w(16),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(10), vertical: R.h(5)),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(R.w(8)),
                ),
                child: Text(
                  '-${product.discountPercent}%',
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          if (images.length > 1)
            Positioned(
              bottom: R.h(12),
              left: 0,
              right: 0,
              child: Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (i) => Container(
                        width:
                            controller.galleryIndex.value == i ? R.w(22) : R.w(7),
                        height: R.h(7),
                        margin: EdgeInsets.symmetric(horizontal: R.w(3)),
                        decoration: BoxDecoration(
                          color: controller.galleryIndex.value == i
                              ? AppColors.primary
                              : AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
            ),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((product.categoryName ?? '').isNotEmpty)
          Text(
            product.categoryName!,
            style: TextStyle(
              fontSize: R.sp(13),
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        SizedBox(height: R.h(6)),
        Text(
          product.title,
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
            height: 1.25,
          ),
        ),
        SizedBox(height: R.h(8)),
        Row(
          children: [
            Icon(Icons.star, color: AppColors.star, size: R.sp(16)),
            SizedBox(width: R.w(4)),
            Text(
              product.rating > 0 ? product.rating.toString() : '—',
              style: TextStyle(
                fontSize: R.sp(13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(width: R.w(12)),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(10), vertical: R.h(4)),
              decoration: BoxDecoration(
                color: product.inStock
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : AppColors.cardBorder,
                borderRadius: BorderRadius.circular(R.w(8)),
              ),
              child: Text(
                product.inStock
                    ? 'details.in_stock'.trns()
                    : 'details.out_of_stock'.trns(),
                style: TextStyle(
                  fontSize: R.sp(12),
                  fontWeight: FontWeight.w700,
                  color: product.inStock
                      ? AppColors.primary
                      : AppColors.mediumGrey,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();
    return Obx(() {
      final product = controller.product;
      if (product == null) return const SizedBox.shrink();
      final variant = controller.matchedVariant;
      final regular = variant?.regularPrice ?? product.regularPrice;
      final hasDiscount =
          variant?.hasDiscount ?? product.hasDiscount;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _price(controller.unitPrice),
                style: TextStyle(
                  fontSize: R.sp(26),
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              if (hasDiscount) ...[
                SizedBox(width: R.w(10)),
                Padding(
                  padding: EdgeInsets.only(bottom: R.h(3)),
                  child: Text(
                    _price(regular),
                    style: TextStyle(
                      fontSize: R.sp(15),
                      color: AppColors.lightGrey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (controller.footerPriceHint.isNotEmpty) ...[
            SizedBox(height: R.h(6)),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: R.w(12), vertical: R.h(8)),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(R.w(10)),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer_outlined,
                      size: R.sp(16), color: AppColors.primary),
                  SizedBox(width: R.w(8)),
                  Expanded(
                    child: Text(
                      controller.footerPriceHint,
                      style: TextStyle(
                        fontSize: R.sp(13),
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _OptionPickers extends StatelessWidget {
  const _OptionPickers({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    if (!product.isVariable || product.attributes.isEmpty) {
      return const SizedBox.shrink();
    }
    final controller = Get.find<ProductDetailsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final attr in product.attributes) ...[
          Obx(() {
            final selectedId = controller.selectedOptions[attr.id];
            final selectedLabel = attr.values
                .where((v) => v.id == selectedId)
                .map((v) => v.value)
                .firstOrNull;
            return RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: R.sp(15),
                  color: AppColors.darkGrey,
                ),
                children: [
                  TextSpan(
                    text: '${attr.name}: ',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: selectedLabel ??
                        'details.choose_option'.trns(),
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: selectedLabel == null
                          ? AppColors.mediumGrey
                          : AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: R.h(10)),
          Obx(() => Wrap(
                spacing: R.w(10),
                runSpacing: R.h(10),
                children: [
                  for (final v in attr.values)
                    GestureDetector(
                      onTap: v.inStock
                          ? () => controller.selectOption(attr.id, v.id)
                          : null,
                      child: Opacity(
                        opacity: v.inStock ? 1 : 0.45,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: R.w(16), vertical: R.h(10)),
                          decoration: BoxDecoration(
                            color: controller.selectedOptions[attr.id] == v.id
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(R.w(10)),
                            border: Border.all(
                              color:
                                  controller.selectedOptions[attr.id] == v.id
                                      ? AppColors.primary
                                      : AppColors.cardBorder,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            v.value,
                            style: TextStyle(
                              fontSize: R.sp(14),
                              fontWeight: FontWeight.w600,
                              color:
                                  controller.selectedOptions[attr.id] == v.id
                                      ? AppColors.white
                                      : AppColors.darkGrey,
                              decoration: v.inStock
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
          SizedBox(height: R.h(18)),
        ],
      ],
    );
  }
}

class _QuantityRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();
    return Obx(() {
      final max = controller.maxQuantity;
      return Row(
        children: [
          Text(
            'details.quantity'.trns(),
            style: TextStyle(
              fontSize: R.sp(15),
              fontWeight: FontWeight.w700,
              color: AppColors.darkGrey,
            ),
          ),
          SizedBox(width: R.w(14)),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(R.w(12)),
            ),
            child: Row(
              children: [
                _StepBtn(
                  icon: Icons.remove,
                  onTap: controller.decrementQty,
                ),
                SizedBox(
                  width: R.w(40),
                  child: Text(
                    '${controller.quantity.value}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                _StepBtn(
                  icon: Icons.add,
                  onTap: controller.incrementQty,
                ),
              ],
            ),
          ),
          if (max != null) ...[
            SizedBox(width: R.w(12)),
            Expanded(
              child: Text(
                'details.only_left'.trnsFormat({'count': max}),
                style: TextStyle(
                  fontSize: R.sp(12),
                  color: AppColors.mediumGrey,
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: R.w(38),
        height: R.h(38),
        alignment: Alignment.center,
        child: Icon(icon, size: R.sp(18), color: AppColors.primary),
      ),
    );
  }
}

class _DescriptionBlock extends StatelessWidget {
  const _DescriptionBlock({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    final text = (product.shortDescription?.trim().isNotEmpty ?? false)
        ? '${product.shortDescription!.trim()}\n\n${product.description!.trim()}'
        : product.description!.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.description'.trns(),
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(height: R.h(8)),
        Text(
          text,
          style: TextStyle(
            fontSize: R.sp(14),
            height: 1.5,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }
}

class _SpecRows extends StatelessWidget {
  const _SpecRows({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    Widget row(String label, String value) => Padding(
          padding: EdgeInsets.only(bottom: R.h(8)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: R.w(110),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.mediumGrey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGrey,
                  ),
                ),
              ),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.product_specification'.trns(),
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(height: R.h(10)),
        if ((product.sku ?? '').isNotEmpty)
          row('details.sku'.trns(), product.sku!),
        if ((product.categoryName ?? '').isNotEmpty)
          row('details.category'.trns(), product.categoryName!),
        row(
          'details.availability'.trns(),
          product.inStock
              ? 'details.in_stock'.trns()
              : 'details.out_of_stock'.trns(),
        ),
        row(
          'details.product_type'.trns(),
          product.isVariable
              ? 'details.type_variable'.trns()
              : 'details.type_simple'.trns(),
        ),
        if (product.stockQty > 0)
          row(
            'details.stock_qty'.trns(),
            '${product.stockQty}',
          ),
      ],
    );
  }
}

class _RelatedBlock extends StatelessWidget {
  const _RelatedBlock({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details.related_products'.trns(),
          style: TextStyle(
            fontSize: R.sp(16),
            fontWeight: FontWeight.w800,
            color: AppColors.darkGrey,
          ),
        ),
        SizedBox(height: R.h(12)),
        SizedBox(
          height: R.h(260),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: product.relatedProducts.length,
            itemBuilder: (context, index) {
              final item = product.relatedProducts[index];
              return Padding(
                padding: EdgeInsets.only(right: R.w(16)),
                child: ProductCard(
                  width: R.w(170),
                  product: item,
                  onAddTap: () => controller.addRelated(item),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(R.w(20), R.h(12), R.w(20), R.h(20)),
      child: SafeArea(
        top: false,
        child: Obx(() {
          final enabled = controller.canAdd && !controller.isAdding.value;
          return Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'details.total'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(12),
                      color: AppColors.mediumGrey,
                    ),
                  ),
                  Text(
                    _price(
                        controller.unitPrice * controller.quantity.value),
                    style: TextStyle(
                      fontSize: R.sp(20),
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(width: R.w(16)),
              Expanded(
                child: SizedBox(
                  height: R.h(52),
                  child: ElevatedButton(
                    onPressed:
                        enabled ? controller.onAddToCart : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.cardBorder,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.w(12)),
                      ),
                    ),
                    child: controller.isAdding.value
                        ? SizedBox(
                            width: R.w(22),
                            height: R.w(22),
                            child:
                                const CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            controller.addButtonLabel,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: R.sp(15),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(
              width: double.infinity, height: R.h(320), borderRadius: 0),
          Padding(
            padding: EdgeInsets.all(R.w(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: R.w(90), height: R.h(14), borderRadius: 6),
                SizedBox(height: R.h(10)),
                ShimmerBox(
                    width: double.infinity, height: R.h(22), borderRadius: 6),
                SizedBox(height: R.h(6)),
                ShimmerBox(width: R.w(220), height: R.h(22), borderRadius: 6),
                SizedBox(height: R.h(16)),
                ShimmerBox(width: R.w(140), height: R.h(28), borderRadius: 8),
                SizedBox(height: R.h(20)),
                ShimmerBox(
                    width: double.infinity, height: R.h(90), borderRadius: 12),
              ],
            ),
          ),
        ],
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
            padding: EdgeInsets.symmetric(horizontal: R.w(48)),
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
