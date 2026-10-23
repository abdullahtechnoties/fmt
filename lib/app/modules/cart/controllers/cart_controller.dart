import 'package:flutter/material.dart';
import 'package:fmt/models/dummy_models.dart';
import 'package:get/get.dart';
// import 'package:fmt/app/data/models/dummy_models.dart'; 

class CartController extends GetxController {
  final promoController = TextEditingController();
  
  final cartItems = <CartItemModel>[].obs;
  final shippingCost = 200.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDummyCart();
  }

  void _loadDummyCart() {
    cartItems.assignAll([
      CartItemModel(
        id: '1',
        title: 'K-890 Kaisi Auto Ranging 6000...',
        imageUrl: 'https://www.fmtonlinestore.com/storage/5078/971433.jpg',
        price: 5250,
        bulkQty: 10,
        bulkPrice: 4900,
        quantity: 1,
      ),
      CartItemModel(
        id: '2',
        title: 'BH12 2UUL The One Plate Magne...',
        imageUrl: 'https://www.fmtonlinestore.com/storage/5189/1245317.jpg',
        price: 2350,
        bulkQty: 5,
        bulkPrice: 2300,
        quantity: 1,
      ),
      CartItemModel(
        id: '3',
        title: '15 Series Mijing iPhone Mid-Laye...',
        imageUrl: 'https://fmtonlinestore.com/frontendimages/product-detail.png',
        price: 2700,
        bulkQty: 5,
        bulkPrice: 2600,
        quantity: 1,
      ),
    ]);
  }

  double get subtotal => cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  double get total => subtotal + shippingCost.value;
  int get totalItems => cartItems.length;

  void increaseQty(int index) {
    cartItems[index].quantity++;
    cartItems.refresh();
  }

  void decreaseQty(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      cartItems.refresh();
    }
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
  }

  void applyPromo() {
    // Utilize your SnackbarService
    // SnackbarService.showSuccess(title: 'Promo Applied', message: 'Discount code applied successfully!');
  }
}