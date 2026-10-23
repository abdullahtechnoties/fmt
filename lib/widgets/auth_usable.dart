import 'package:flutter/material.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
// import 'package:fmt/utilities/translation_extention.dart';

/// Define your static asset paths here for the custom vectors
class AuthAssets {
  static const String logo = 'assets/images/logo.png'; // REPLACE: Your FMT Vector Logo
  static const String googleIcon = 'assets/images/google.png'; // REPLACE: Google Vector
  static const String appleIcon = 'assets/images/apple.png';   // REPLACE: Apple Vector
  static const String facebookIcon = 'assets/images/facebook.png'; // REPLACE: Facebook Vector
}

/// Reusable Top Logo Widget
class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: R.h(60), bottom: R.h(40),),
        child: Image.asset(
          AuthAssets.logo,
          height: R.h(100),
          width: R.w(170),
          fit: BoxFit.contain,
          // Fallback if asset is missing during development:
          errorBuilder: (context, error, stackTrace) => Container(
             height: R.h(80),
             width: R.w(150),
             color: AppColors.shimmerBase,
             alignment: Alignment.center,
             child: Text("Logo Here"),
          ),
        ),
      ),
    );
  }
}

/// Reusable Social Login Circular Button
class SocialLoginBtn extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const SocialLoginBtn({super.key, required this.iconPath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: R.w(56),
        width: R.w(56),
        margin: EdgeInsets.symmetric(horizontal: R.w(10)),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
          border: Border.all(color: AppColors.primary, width: 1),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          iconPath,
          height: R.w(28),
          width: R.w(28),
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: AppColors.primary),
        ),
      ),
    );
  }
}

/// Reusable Bottom Rich Text (e.g., "Don't have an account? Sign Up")
class AuthBottomRichText extends StatelessWidget {
  final String normalText;
  final String linkText;
  final VoidCallback onLinkTap;

  const AuthBottomRichText({
    super.key,
    required this.normalText,
    required this.linkText,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLinkTap,
      child: RichText(
        text: TextSpan(
          text: normalText,
          style: TextStyle(
            fontSize: R.sp(14),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
          ),
          children: [
            TextSpan(
              text: linkText,
              style: TextStyle(
                fontSize: R.sp(14),
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}