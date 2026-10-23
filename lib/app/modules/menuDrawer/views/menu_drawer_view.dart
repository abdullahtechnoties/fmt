import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import '../controllers/menu_drawer_controller.dart';

class MenuDrawerView extends StatelessWidget {
  const MenuDrawerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Put controller so it binds correctly when Drawer opens
    final controller = Get.put(MenuDrawerController());

    return Drawer(
      // backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: GradientScaffold(
        child: SafeArea(
          child: Column(
            children: [
              // Top Profile Card (Floating with Gradient)
              Padding(
                padding: EdgeInsets.all(R.w(16)),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: R.w(16), vertical: R.h(16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(R.w(16)),
                    boxShadow: [
                      BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    // Matches the cyan gradient style
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE0F7F4), AppColors.white], 
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: R.h(24),
                        backgroundImage: NetworkImage(controller.userImage.value),
                      ),
                      SizedBox(width: R.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.userName.value,
                              style: TextStyle(fontSize: R.sp(16), fontWeight: FontWeight.w700, color: AppColors.darkGrey),
                            ),
                            Text(
                              controller.userEmail.value,
                              style: TextStyle(fontSize: R.sp(12), color: AppColors.mediumGrey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Close Drawer Button
                      GestureDetector(
                        onTap: () => Scaffold.of(context).closeDrawer(),
                        child: Icon(Icons.close, color: AppColors.darkGrey, size: R.sp(20)),
                      )
                    ],
                  ),
                ),
              ),
              
              // Navigation Links
              Expanded(
                child: Theme(
                  // Remove ExpansionTile borders
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ListView(
                    padding: EdgeInsets.zero,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDrawerItem('drawer.home'.trns(), onTap: () {}),
                      _buildDivider(),
                      
                      _buildDrawerItem('drawer.shop'.trns(), onTap: () {}),
                      _buildDivider(),
                      
                      // Expandable Categories
                      ExpansionTile(
                        title: Text(
                          'drawer.categories'.trns(),
                          style: TextStyle(fontSize: R.sp(15), fontWeight: FontWeight.w700, color: AppColors.darkGrey),
                        ),
                        iconColor: AppColors.darkGrey,
                        collapsedIconColor: AppColors.darkGrey,
                        tilePadding: EdgeInsets.symmetric(horizontal: R.w(20)),
                        childrenPadding: EdgeInsets.only(left: R.w(20), bottom: R.h(10)),
                        children: controller.categories.map((category) {
                          return ListTile(
                            title: Text(
                              category,
                              style: TextStyle(fontSize: R.sp(14), fontWeight: FontWeight.w400, color: AppColors.grey),
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: R.w(16)),
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            onTap: () {},
                          );
                        }).toList(),
                      ),
                      _buildDivider(),
                      
                      _buildDrawerItem('drawer.cart'.trns(), onTap: () {}),
                      _buildDivider(),
                      
                      _buildDrawerItem('drawer.profile'.trns(), onTap: () {}),
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

  Widget _buildDrawerItem(String title, {required VoidCallback onTap}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: R.sp(15), fontWeight: FontWeight.w700, color: AppColors.darkGrey),
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