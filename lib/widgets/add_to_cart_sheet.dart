// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:fmt/app/modules/customer/productList/controllers/product_list_controller.dart';
// import 'package:fmt/models/product_model.dart';
// import 'package:fmt/utilities/colors.dart';
// import 'package:fmt/utilities/translation_extention.dart';
// import 'package:fmt/utilities/typography.dart';
// import 'package:fmt/widgets/sheet_handle.dart';

// class AddToCartSheet extends StatelessWidget {
//   const AddToCartSheet({super.key, required this.controller});
//   final ProductListController controller;

//   static void show(
//       ProductListController controller, ProductModel product) {
//     // controller.(product);
//     Get.bottomSheet(
//       AddToCartSheet(controller: controller),
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       enableDrag: true,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final sw = mq.size.width;
//     final hPad = sw * 0.05;

//     return Container(
//       decoration: const BoxDecoration(
//         color: AppColors.scaffoldBg,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Handle ────────────────────────────────────────────────
//           const SizedBox(height: 12),
//           SheetHandle(),
//           const SizedBox(height: 20),

//           // ── Title ─────────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: hPad),
//             child: Text(
//               'product_list.cart.select_size'.trns(),
//               style: AppTextStyles.sectionTitle(),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // ── Size grid ─────────────────────────────────────────────
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: hPad),
//             child: _SizeGrid(controller: controller),
//           ),

//           const SizedBox(height: 20),

//           // ── Size info row ─────────────────────────────────────────
//           _SizeInfoRow(hPad: hPad),

//           const SizedBox(height: 20),

//           // ── Add to Cart button ────────────────────────────────────
//           _AddToCartButton(
//             controller: controller,
//             hPad: hPad,
//             bottomPad: mq.padding.bottom,
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ── Size Grid ─────────────────────────────────────────────────────────────────
// class _SizeGrid extends StatelessWidget {
//   const _SizeGrid({required this.controller});
//   final ProductListController controller;

//   @override
//   Widget build(BuildContext context) {
//     final sw = MediaQuery.sizeOf(context).width;
//     final hPad = sw * 0.05;
//     final itemW = (sw - hPad * 2 - 12 * 2) / 3;

//     final sizes = controller.cartProduct?.sizes ??
//         const ['XS', 'S', 'M', 'L', 'XL'];

//     return Obx(() => Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           children: sizes.map((size) {
//             final isSelected = controller.selectedSize.value == size;
//             return GestureDetector(
//               onTap: () => controller.onSizeSelected(size),
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 180),
//                 width: itemW,
//                 height: 54,
//                 decoration: BoxDecoration(
//                   color: isSelected ? AppColors.primary : AppColors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: isSelected
//                         ? AppColors.primary
//                         : AppColors.inputBorder,
//                     width: isSelected ? 1.5 : 1,
//                   ),
//                 ),
//                 child: Center(
//                   child: Text(
//                     size,
//                     style: AppTextStyles.bodyMedium(
//                       color: isSelected
//                           ? AppColors.white
//                           : AppColors.black,
//                     ).copyWith(
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ));
//   }
// }

// // ── Size Info Row ─────────────────────────────────────────────────────────────
// class _SizeInfoRow extends StatelessWidget {
//   const _SizeInfoRow({required this.hPad});
//   final double hPad;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
      
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Container(
//         width: double.infinity,
//         color: AppColors.white,
//         padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
//         child: Row(
//           children: [
//             Text(
//               'product_list.cart.size_info'.trns(),
//               style: AppTextStyles.bodyMedium(),
//             ),
//             const Spacer(),
//             const Icon(Icons.chevron_right_rounded,
//                 color: AppColors.darkGrey, size: 22),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Add to Cart Button ────────────────────────────────────────────────────────
// class _AddToCartButton extends StatelessWidget {
//   const _AddToCartButton({
//     required this.controller,
//     required this.hPad,
//     required this.bottomPad,
//   });
//   final ProductListController controller;
//   final double hPad;
//   final double bottomPad;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.fromLTRB(hPad, 12, hPad, bottomPad + 16),
//       color: AppColors.scaffoldBg,
//       child: SizedBox(
//         height: 56,
//         child: ElevatedButton(
//           onPressed: controller.onAddToCart,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: AppColors.primary,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30),
//             ),
//             elevation: 0,
//           ),
//           child: Text(
//             'product_list.cart.add_to_cart'.trns().toUpperCase(),
//             style: AppTextStyles.buttonText().copyWith(
//               fontSize: 14,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }