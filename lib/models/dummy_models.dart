class CategoryModel {
  final String id;
  final String title;
  final int productCount;
  final String imageUrl;

  CategoryModel({
    required this.id,
    required this.title,
    required this.productCount,
    required this.imageUrl,
  });
}

class ProductModel {
  final String id;
  final String title;
  final String category;
  final double price;
  final double rating;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}


class CartItemModel {
  final String id;
  final String title;
  final String imageUrl;
  final double price;
  final int bulkQty;
  final double bulkPrice;
  int quantity;

  CartItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.bulkQty,
    required this.bulkPrice,
    this.quantity = 1,
  });
}