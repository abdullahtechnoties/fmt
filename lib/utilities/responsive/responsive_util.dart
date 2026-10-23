import 'dart:math' as math;
import 'package:flutter/material.dart';

class R {
  R._();

  static late MediaQueryData _mq;
  static late Size _size;

  static void init(BuildContext context) {
    _mq = MediaQuery.of(context);
    _size = _mq.size;
  }

  static double get screenWidth => _size.width;
  static double get screenHeight => _size.height;
  static double get pixelRatio => _mq.devicePixelRatio;

  /// Scale a size relative to a 390px base design width
  static double w(double size) => size * (screenWidth / 390);

  /// Scale a size relative to a 844px base design height
  static double h(double size) => size * (screenHeight / 844);

  /// Responsive font size
  static double sp(double size) {
    final scale = (screenWidth / 390).clamp(0.85, 1.3);
    return size * scale;
  }

  /// Clamped responsive value
  static double adaptive(
    BuildContext context,
    double baseSize, {
    double minScale = 0.85,
    double maxScale = 1.3,
  }) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double scale = (screenWidth / 390).clamp(minScale, maxScale);
    return math.max(baseSize * scale, 8.0);
  }


    static const double maxDesktopWidth = 1920.0;
  static const double standardDesktopWidth = 1024.0;
  static const double tabletBreakpoint = 768.0;
  static const double mobileBreakpoint = 360.0;

  static const double maxDesktopScale = 1.2;
  static const double desktopScale = 1.1;
  static const double tabletScale = 1.0;
  static const double mobileScale = 0.85;

  static double scaleSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double pixelDensity = MediaQuery.devicePixelRatioOf(context);
    double scaleFactor;

    if (screenWidth >= maxDesktopWidth) {
      scaleFactor = (screenWidth / maxDesktopWidth) * maxDesktopScale;
    } else if (screenWidth >= standardDesktopWidth) {
      scaleFactor = (screenWidth / maxDesktopWidth) * desktopScale;
    } else if (screenWidth >= tabletBreakpoint) {
      scaleFactor = (screenWidth / standardDesktopWidth) * tabletScale;
    } else { 
      scaleFactor = (screenWidth / mobileBreakpoint) * mobileScale;
    }

    scaleFactor = scaleFactor.clamp(0.85, 1.3);

    return math.max(
      (baseSize * scaleFactor),
      (pixelDensity > 2 ? pixelDensity * 0.75 : 8.0),
    );
  }
}