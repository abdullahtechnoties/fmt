import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/app/modules/cart/controllers/cart_controller.dart';
import 'package:fmt/app/modules/cart/views/cart_view.dart';
import 'package:fmt/app/modules/categories/controllers/categories_controller.dart';
import 'package:fmt/app/modules/categories/views/categories_view.dart';
import 'package:fmt/app/modules/home/controllers/home_controller.dart';
import 'package:fmt/app/modules/home/views/home_view.dart';
import 'package:fmt/app/modules/menuDrawer/views/menu_drawer_view.dart';
import 'package:fmt/app/modules/profile/controllers/profile_controller.dart';
import 'package:fmt/app/modules/profile/views/profile_view.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:get/get.dart';

class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String icon;
  final String activeIcon;
}

const _navItems = [
  _NavItem(
    label: 'Home',
    icon: 'assets/images/b1.png',
    activeIcon: 'assets/images/b1a.png',
  ),
  _NavItem(
    label: 'Shop',
    icon: 'assets/images/b2.png',
    activeIcon: 'assets/images/b2a.png',
  ),
  _NavItem(
    label: 'Cart',
    icon: 'assets/images/b3.png',
    activeIcon: 'assets/images/b3a.png',
  ),
  _NavItem(
    label: 'Profile',
    icon: 'assets/images/b4.png',
    activeIcon: 'assets/images/b4a.png',
  ),
];

class BottomnavView extends GetView<BottomnavController> {
  const BottomnavView({super.key});



  static const List<Widget> pages = [
    HomeView(),
    CategoriesView(),
    CartView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    Get.put(HomeController());
    Get.put(CategoriesController());
    Get.put(CartController());
    Get.put(ProfileController());

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (popResult, isFinal) async {
        final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Exit'),
            backgroundColor: AppColors.white,
            content: const Text('Are you sure you want to exit?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: controller.scaffoldKey,
        drawer: const MenuDrawerView(),    
        extendBody: true,
        backgroundColor: AppColors.white,
        body: Obx(
          () => IndexedStack(index: controller.tabIndex.value, children: pages),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 4,
          shape: const CircleBorder(),
          onPressed: () => Get.toNamed(Routes.SUPPORT),
          child: Image.asset(
            'assets/images/chat.png',
            height: 33,
            width: 33,
            fit: BoxFit.contain,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        color: AppColors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 62,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              const SizedBox(width: 48),
              _buildNavItem(2),
              _buildNavItem(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];

    return Obx(() {
      final isSelected = controller.tabIndex.value == index;

      return GestureDetector(
        onTap: () => controller.changeTabIndex(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                isSelected ? item.activeIcon : item.icon,
                height: 23,
                width: 23,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.primary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
