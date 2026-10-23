import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterController extends GetxController {
  final currentRangeValues = const RangeValues(500, 50000).obs;
  
  final selectedStock = 'All'.obs;
  final stockOptions = ['All', 'In Stock', 'Out of Stock'];

  final categories = [
    'AWESHINE Products',
    'BGA Reballing Stenciles',
    'Blades',
    'Box-Adopter-Cable-Reader',
    'CHARGER & BATTERY',
    'Charging Board',
    'Cleaning (Bursh-Clothes-Stick)',
    'Cleaning Liquid & Ultrasonic Cleaner'
  ].obs;

  final selectedCategory = 'BGA Reballing Stenciles'.obs;

  void updatePriceRange(RangeValues values) {
    currentRangeValues.value = values;
  }

  void setStock(String stock) {
    selectedStock.value = stock;
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }
}