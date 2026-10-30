import 'package:flutter/material.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/menuDrawer/controllers/menu_drawer_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/repositories/cart_repository.dart';
import 'package:fmt/services/store_service.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/app_confirm_dialog.dart';
import 'package:fmt/widgets/branch_selector.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';

class MenuDrawerView extends StatelessWidget {
  const MenuDrawerView({super.key});

  MenuDrawerController get controller => Get.find<MenuDrawerController>();
  BottomnavController get _bottomnav => Get.find<BottomnavController>();
  StoreService get _storeService => Get.find<StoreService>();

  Future<void> _onBranchChosen(int storeId) async {
    final cartRepo = CartRepository();
    final cart = await cartRepo.fetchCart();
    final notEmpty = cartRepo.itemCount(cart.data) > 0;
    final target =
        _storeService.stores.firstWhereOrNull((s) => s.id == storeId);
    if (target == null) return;
    final switched = await _storeService.selectStore(
      target,
      cartNotEmpty: notEmpty,
      onClearCart: () async {
        final cleared = await cartRepo.clear();
        if (cleared.isError) throw Exception('clear-failed');
      },
    );
    if (switched) {
      // Home listens to the selected branch and reloads itself.
      Get.snackbar(
        'branch.switched_title'.trns(),
        'branch.switched'.trnsFormat({'name': target.name}),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _goTab(int index) {
    // Close the drawer first, then switch the bottom-nav tab.
    Get.back();
    Future.delayed(const Duration(milliseconds: 150), () {
      _bottomnav.changeTabIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: GradientScaffold(
        child: SafeArea(
          child: Column(
            children: [
              // Top Profile Card (Floating with Gradient)
              Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Obx(
                  () => Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.w(16), vertical: R.h(16)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(R.w(16)),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE0F7F4), AppColors.white],
                      ),
                    ),
                    child: Row(
                      children: [
                        _ProfileAvatar(
                            imageUrl: controller.userImage,
                            name: controller.userName),
                        SizedBox(width: R.w(12)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.userName,
                                style: TextStyle(
                                    fontSize: R.sp(16),
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGrey),
                              ),
                              if (controller.userEmail != null)
                                Text(
                                  controller.userEmail!,
                                  style: TextStyle(
                                      fontSize: R.sp(12),
                                      color: AppColors.mediumGrey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              if (!controller.isLoggedIn) ...[
                                SizedBox(height: R.h(8)),
                                GestureDetector(
                                  onTap: controller.goToLogin,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: R.w(14),
                                        vertical: R.h(7)),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                          BorderRadius.circular(R.w(8)),
                                    ),
                                    child: Text(
                                      'auth.login_btn'.trns(),
                                      style: TextStyle(
                                        fontSize: R.sp(12),
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Scaffold.of(context).closeDrawer(),
                          child: Icon(Icons.close,
                              color: AppColors.darkGrey, size: R.sp(20)),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // Current branch tile
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                child: Obx(
                  () => GestureDetector(
                    onTap: () => showBranchSheet(
                      onChanged: (store) => _onBranchChosen(store.id),
                    ),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: R.w(12), vertical: R.h(12)),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(R.w(12)),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.store_outlined,
                              color: AppColors.primary, size: R.sp(20)),
                          SizedBox(width: R.w(10)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'branch.current'.trns(),
                                  style: TextStyle(
                                      fontSize: R.sp(11),
                                      color: AppColors.grey),
                                ),
                                Text(
                                  _storeService.selectedStore.value?.name ??
                                      'branch.select'.trns(),
                                  style: TextStyle(
                                      fontSize: R.sp(14),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.darkGrey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.keyboard_arrow_down,
                              color: AppColors.grey, size: R.sp(20)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: R.h(8)),

              // Navigation Links
              Expanded(
                child: Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDrawerItem('drawer.home'.trns(),
                          onTap: () => _goTab(0)),
                      _buildDivider(),
                      _buildDrawerItem('drawer.shop'.trns(),
                          onTap: () => _goTab(1)),
                      _buildDivider(),

                      // Expandable live Categories
                      ExpansionTile(
                        title: Text(
                          'drawer.categories'.trns(),
                          style: TextStyle(
                              fontSize: R.sp(15),
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGrey),
                        ),
                        iconColor: AppColors.darkGrey,
                        collapsedIconColor: AppColors.darkGrey,
                        tilePadding:
                            EdgeInsets.symmetric(horizontal: R.w(20)),
                        childrenPadding:
                            EdgeInsets.only(left: R.w(20), bottom: R.h(10)),
                        onExpansionChanged: (_) =>
                            controller.loadCategories(),
                        children: [
                          Obx(() {
                            if (controller.isLoadingCategories.value) {
                              return Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: R.h(8)),
                                child: ShimmerBox(
                                    width: double.infinity,
                                    height: R.h(40)),
                              );
                            }
                            if (controller.categories.isEmpty) {
                              return Padding(
                                padding:
                                    EdgeInsets.symmetric(vertical: R.h(8)),
                                child: Text(
                                  'drawer.no_categories'.trns(),
                                  style: TextStyle(
                                      fontSize: R.sp(13),
                                      color: AppColors.grey),
                                ),
                              );
                            }
                            return Column(
                              children: controller.categories
                                  .map(
                                    (category) => ListTile(
                                      title: Text(
                                        category.name,
                                        style: TextStyle(
                                            fontSize: R.sp(14),
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.grey),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: R.w(16)),
                                      visualDensity:
                                          const VisualDensity(
                                              horizontal: 0, vertical: -4),
                                      onTap: () => controller
                                          .goToCategories(category),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ],
                      ),
                      _buildDivider(),

                      _buildDrawerItem('drawer.cart'.trns(),
                          onTap: () => _goTab(2)),
                      _buildDivider(),

                      _buildDrawerItem('drawer.profile'.trns(),
                          onTap: () => _goTab(3)),
                      _buildDivider(),

                      // Support entry (FAB exists too, this is discoverable)
                      _buildDrawerItem('drawer.support'.trns(),
                          onTap: () {
                        Get.back();
                        Get.toNamed(Routes.SUPPORT);
                      }),
                      _buildDivider(),

                      Obx(() => controller.isLoggedIn
                          ? _buildDrawerItem(
                              'drawer.logout'.trns(),
                              isDanger: true,
                              onTap: () async {
                                final confirmed =
                                    await AppConfirmDialog.show(
                                  title: 'profile.logout_title'.trns(),
                                  message:
                                      'profile.logout_message'.trns(),
                                  confirmText: 'common.yes'.trns(),
                                  isDangerous: true,
                                );
                                if (confirmed == true) {
                                  controller.logout();
                                }
                              },
                            )
                          : _buildDrawerItem(
                              'auth.login_btn'.trns(),
                              onTap: controller.goToLogin,
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(String title,
      {required VoidCallback onTap, bool isDanger = false}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: R.sp(15),
          fontWeight: FontWeight.w700,
          color: isDanger ? AppColors.red : AppColors.darkGrey,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: R.w(20)),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.inputBorder,
      indent: R.w(20),
      endIndent: R.w(20),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.imageUrl, required this.name});

  final String? imageUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: R.h(24),
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
        child: Text(
          name.isNotEmpty ? name.trim()[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: R.sp(20),
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: R.h(24),
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: ClipOval(
        child: AppCachedImage(
          imageUrl: url,
          width: R.h(48),
          height: R.h(48),
          showShimmer: false,
        ),
      ),
    );
  }
}
