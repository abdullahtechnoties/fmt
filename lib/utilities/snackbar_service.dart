import 'package:flutter/material.dart';
import 'package:get/get.dart';


class SnackbarService {
  // Private constructor to prevent instantiation
  SnackbarService._();

  static void showSuccess({
    required String title,
    required String message,
    onTap,
    Duration? duration = const Duration(seconds: 1, milliseconds: 400),
  }) {
    Get.snackbar(
      title,
      message,
      messageText: message.trim().isEmpty ? const SizedBox.shrink() : null,
      icon: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(Icons.check_circle, color: Colors.white),
      ), 
      backgroundColor: Color(0xFF8FC642),
      backgroundGradient: LinearGradient(
        colors: [Color(0xFF8FC642), const Color.fromARGB(255, 119, 161, 61)],
      ),
      colorText: Colors.white,
      borderRadius: 8,
      barBlur: 8.0,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      onTap: onTap,
      snackPosition: SnackPosition.TOP,
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    Duration? duration = const Duration(seconds: 1, milliseconds: 400),
  }) {
    Get.snackbar(
      title,
      message,
      messageText: message.trim().isEmpty ? const SizedBox.shrink() : null,
      backgroundColor: Colors.red.withValues(alpha: 0.8),
      colorText: Colors.white,
      borderRadius: 8,
      barBlur: 3.0,
      borderWidth: 0,
      dismissDirection: DismissDirection.horizontal,
      snackPosition: SnackPosition.TOP,
      duration: duration,
    );
  }
}