import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoriesController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Dummy Data
  final categories = [
    {
      'title': 'AWESHINE Products',
      'count': 52,
      'image': 'https://www.fmtonlinestore.com/storage/4196/uCW4HVj6lN2IIa.jpg' // Placeholder
    },
    {
      'title': 'BGA Reballing Stencils',
      'count': 157,
      'image': 'https://www.fmtonlinestore.com/storage/5359/1527436.jpg'
    },
    {
      'title': 'Blades(Chip Repair-Cutting Blades-Opening)',
      'count': 99,
      'image': 'https://www.fmtonlinestore.com/storage/5356/1521503.jpg'
    },
    {
      'title': 'Box-Adopter-Cable-Reader',
      'count': 80,
      'image': 'https://www.fmtonlinestore.com/storage/5348/1508532.jpg'
    },
    {
      'title': 'MaAnt Battery Activation Board',
      'count': 45,
      'image': 'https://www.fmtonlinestore.com/storage/4572/conversions/gryat9weQ1P4nJ-card.jpg'
    },
    {
      'title': 'Infinix Charging Board',
      'count': 120,
      'image': 'https://www.fmtonlinestore.com/storage/5061/conversions/965733-card.jpg'
    },
  ].obs;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}