import 'package:flutter/material.dart';

/// Back-navigation that never races the framework:
/// unfocus first, let the current frame (and any closing sheet/dialog)
/// settle, then pop via the raw [Navigator] while the context is mounted.
/// Use this instead of a bare `Get.back()` right after async work.
class NavigationHelper {
  NavigationHelper._();

  static Future<void> safePop(
    BuildContext context, [
    dynamic result,
  ]) async {
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 120));
    if (!context.mounted) return;
    final navigator = Navigator.of(context);
    if (!navigator.canPop()) return;
    // One more frame so exit animations / snackbars don't collide.
    await Future.delayed(const Duration(milliseconds: 30));
    if (!context.mounted) return;
    navigator.pop(result);
  }
}
