import 'package:get/get.dart';

class OrderHistoryController extends GetxController {
  // Dummy Data
  final orders = [
    {
      'title': 'K-890 Kaisi Auto Ranging 6000...',
      'bulkQty': 10,
      'bulkPrice': 4900.0,
      'currentPrice': 5250.0,
      'image': 'https://www.fmtonlinestore.com/storage/5078/971433.jpg'
    },
    {
      'title': 'BH12 2UUL The One Plate Magne...',
      'bulkQty': 5,
      'bulkPrice': 2300.0,
      'currentPrice': 2350.0,
      'image': 'https://www.fmtonlinestore.com/storage/5189/1245317.jpg'
    },
    {
      'title': '15 Series Mijing iPhone Mid-Laye...',
      'bulkQty': 5,
      'bulkPrice': 2600.0,
      'currentPrice': 2700.0,
      'image': 'https://fmtonlinestore.com/frontendimages/product-detail.png'
    },
     {
      'title': 'K-890 Kaisi Auto Ranging 6000...',
      'bulkQty': 10,
      'bulkPrice': 4900.0,
      'currentPrice': 5250.0,
      'image': 'https://www.fmtonlinestore.com/storage/5078/971433.jpg'
    },
  ].obs;

  void removeOrder(int index) {
    orders.removeAt(index);
  }
}