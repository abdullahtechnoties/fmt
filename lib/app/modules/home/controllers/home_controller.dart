import 'package:fmt/models/dummy_models.dart';
import 'package:get/get.dart';
// Import your models here
// import 'package:fmt/app/data/models/dummy_models.dart'; 

class HomeController extends GetxController {
  final isLoading = true.obs;

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;
  final RxList<ProductModel> specialProducts = <ProductModel>[].obs;

  // Static user profile image for header
  final String userProfileImage = 'https://i.pravatar.cc/150?img=11';

  @override
  void onInit() {
    super.onInit();
    _loadDummyData();
  }

  void _loadDummyData() async {
    isLoading.value = true;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    categories.assignAll([
      CategoryModel(
        id: '1',
        title: 'AWESHINE\nProducts',
        productCount: 52,
        imageUrl: 'https://www.fmtonlinestore.com/storage/4196/uCW4HVj6lN2IIa.jpg', // Dummy
      ),
      CategoryModel(
        id: '2',
        title: 'CNC Motherboards',
        productCount: 120,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5326/1481823.jpg', // Dummy
      ),
    ]);

    featuredProducts.assignAll([
      ProductModel(
        id: '1',
        title: 'KG-DDJ KEGUAN Multi-Function R...',
        category: 'Fixture & Opener',
        price: 9300,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5329/1485090.jpg',
      ),
      ProductModel(
        id: '2',
        title: 'KG-ZGD KEGUAN High-Power Ultra...',
        category: 'Light & Fan',
        price: 12500,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5331/1486767.jpg',
      ),
      ProductModel(
        id: '3',
        title: 'iPhone 16Pro CPU&NAND CNC...',
        category: 'CNC Motherboard',
        price: 9500,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5326/1481823.jpg',
      ),
      ProductModel(
        id: '4',
        title: 'KG-GRS KEGUAN Special Heat-ins...',
        category: 'Fixture & Opener',
        price: 500,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5330/1485416.jpg',
      ),
      ProductModel(
        id: '5',
        title: 'KG-DWMJ KEGUAN Blue Lig...',
        category: 'Fixture & Opener',
        price: 2500,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5328/1483480.jpg',
      ),
      ProductModel(
        id: '6',
        title: 'KG-LGDW01 KEGUAN Camera...',
        category: 'Fixture & Opener',
        price: 1300,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/5327/1482964.jpg',
      ),
    ]);

    specialProducts.assignAll([
      ProductModel(
        id: '7',
        title: '858D KADA 8-Hole Hot Air Gun',
        category: 'Hot Air Rework Station',
        price: 1850,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/3978/uXyDJQBJVBZPbh.jpg',
      ),
      ProductModel(
        id: '8',
        title: 'iPhone X intel iCL Motherboard',
        category: 'CNC Motherboard',
        price: 9500,
        rating: 5.0,
        imageUrl: 'https://www.fmtonlinestore.com/storage/3997/YML4AkDCnOqi6n.jpg',
      ),
    ]);

    isLoading.value = false;
  }

  void onAddToCart(ProductModel product) {
    // Utilize your SnackbarService
    // SnackbarService.showSuccess(
    //   title: 'Success',
    //   message: '${product.title} added to cart!',
    // );
  }
}