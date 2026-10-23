import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon; 
  final String title;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.h(14)),
        child: Row(
          children: [
            // TODO: Replace Icon with Image.asset or SvgPicture.asset when vectors are provided
            Icon(icon, size: R.sp(22), color: AppColors.darkGrey),
            SizedBox(width: R.w(16)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: R.sp(15),
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            Icon(Icons.chevron_right, size: R.sp(22), color: AppColors.darkGrey),
          ],
        ),
      ),
    );
  }
}