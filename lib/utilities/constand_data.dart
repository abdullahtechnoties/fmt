class AppConstants {
  AppConstants._();

  // Unsplash image base
  static const String _unsplash = 'https://images.unsplash.com';

  // Banner images
  static const List<Map<String, String>> bannerData = [
    {
      'image':
          '$_unsplash/photo-1483985988355-763728e1935b?w=800&q=80',
      'title': 'Big Sale',
      'subtitle': 'Up to 50%',
      'tag': 'Happening Now',
    },
    {
      'image':
          '$_unsplash/photo-1607082348824-0a96f2a4b9da?w=800&q=80',
      'title': 'New Arrivals',
      'subtitle': 'Fresh Styles',
      'tag': 'Shop Now',
    },
    {
      'image':
          '$_unsplash/photo-1558618666-fcd25c85cd64?w=800&q=80',
      'title': 'Flash Deals',
      'subtitle': 'Limited Time',
      'tag': 'Grab Now',
    },
    {
      'image':
          '$_unsplash/photo-1441986300917-64674bd600d8?w=800&q=80',
      'title': 'Summer Sale',
      'subtitle': 'Up to 70%',
      'tag': 'Explore',
    },
    {
      'image':
          '$_unsplash/photo-1490481651871-ab68de25d43d?w=800&q=80',
      'title': 'Trending Now',
      'subtitle': 'Latest Picks',
      'tag': 'Discover',
    },
  ];

  // Categories
  static const List<Map<String, dynamic>> categories = [
    {
      'name': 'Clothing',
      'count': 109,
      'image': '$_unsplash/photo-1445205170230-053b83016050?w=400&q=80',
      'image2': '$_unsplash/photo-1469334031218-e382a71b716b?w=400&q=80',
      'image3': '$_unsplash/photo-1515886657613-9f3515b0c78f?w=400&q=80',
      'image4': '$_unsplash/photo-1434389677669-e08b4cac3105?w=400&q=80',
    },
    {
      'name': 'Skincare',
      'count': 530,
      'image': '$_unsplash/photo-1556228720-195a672e8a03?w=400&q=80',
      'image2': '$_unsplash/photo-1571781926291-c477ebfd024b?w=400&q=80',
      'image3': '$_unsplash/photo-1596462502278-27bfdc403348?w=400&q=80',
      'image4': '$_unsplash/photo-1512290923902-8a9f81dc236c?w=400&q=80',
    },
    {
      'name': 'Electronics',
      'count': 87,
      'image': '$_unsplash/photo-1511707171634-5f897ff02aa9?w=400&q=80',
      'image2': '$_unsplash/photo-1526738549149-8e07eca6c147?w=400&q=80',
      'image3': '$_unsplash/photo-1505740420928-5e560c06d30e?w=400&q=80',
      'image4': '$_unsplash/photo-1484704849700-f032a568e944?w=400&q=80',
    },
    {
      'name': 'Hair Care',
      'count': 218,
      'image': '$_unsplash/photo-1522337360788-8b13dee7a37e?w=400&q=80',
      'image2': '$_unsplash/photo-1519699047748-de8e457a634e?w=400&q=80',
      'image3': '$_unsplash/photo-1527799820374-87876b747398?w=400&q=80',
      'image4': '$_unsplash/photo-1576426863848-c21f53c60b19?w=400&q=80',
    },
    {
      'name': 'Medical',
      'count': 218,
      'image': '$_unsplash/photo-1584308666744-24d5c474f2ae?w=400&q=80',
      'image2': '$_unsplash/photo-1559757175-0eb30cd8c063?w=400&q=80',
      'image3': '$_unsplash/photo-1587854692152-cbe660dbde88?w=400&q=80',
      'image4': '$_unsplash/photo-1576671081837-49000212a370?w=400&q=80',
    },
    {
      'name': 'Brands',
      'count': 218,
      'image': '$_unsplash/photo-1542291026-7eec264c27ff?w=400&q=80',
      'image2': '$_unsplash/photo-1600185365926-3a2ce3cdb9eb?w=400&q=80',
      'image3': '$_unsplash/photo-1590874103328-eac38a683ce7?w=400&q=80',
      'image4': '$_unsplash/photo-1572635196237-14b3f281503f?w=400&q=80',
    },
  ];

  // Top product circles
  static const List<Map<String, String>> topProductCategories = [
    {
      'name': 'Dresses',
      'image': '$_unsplash/photo-1539008835657-9e8e9680c956?w=200&q=80',
    },
    {
      'name': 'T-Shirts',
      'image': '$_unsplash/photo-1576566588028-4147f3842f27?w=200&q=80',
    },
    {
      'name': 'Skirts',
      'image': '$_unsplash/photo-1583496661160-fb5218afa9a3?w=200&q=80',
    },
    {
      'name': 'Shoes',
      'image': '$_unsplash/photo-1542291026-7eec264c27ff?w=200&q=80',
    },
    {
      'name': 'Bags',
      'image': '$_unsplash/photo-1548036328-c9fa89d128fa?w=200&q=80',
    },
  ];

  // New Items products
  static const List<Map<String, dynamic>> newItems = [
    {
      'name': 'T-Shirt SPANISH',
      'price': 9,
      'fmtlPrice': null,
      'rating': 3.0,
      'reviews': 5,
      'discount': null,
      'image': '$_unsplash/photo-1521572163474-6864f9cf17ab?w=400&q=80',
      'brand': 'Mango',
    },
    {
      'name': 'T-Shirt SPANISH',
      'price': 9,
      'fmtlPrice': null,
      'rating': 4.0,
      'reviews': 15,
      'discount': null,
      'image': '$_unsplash/photo-1542291026-7eec264c27ff?w=400&q=80',
      'brand': 'Nike',
    },
    {
      'name': 'T-Shirt SP',
      'price': 9,
      'fmtlPrice': null,
      'rating': 4.5,
      'reviews': 22,
      'discount': null,
      'image': '$_unsplash/photo-1460353581641-37baddab0fa2?w=400&q=80',
      'brand': 'Adidas',
    },
    {
      'name': 'Sneakers Pro',
      'price': 12,
      'fmtlPrice': null,
      'rating': 4.0,
      'reviews': 8,
      'discount': null,
      'image': '$_unsplash/photo-1542291026-7eec264c27ff?w=400&q=80',
      'brand': 'Puma',
    },
  ];

  // Flash Sale products
  static const List<Map<String, dynamic>> flashSaleItems = [
    {
      'name': 'Floral Dress',
      'price': 14,
      'fmtlPrice': 21,
      'discount': 20,
      'rating': 4.5,
      'reviews': 12,
      'image': '$_unsplash/photo-1496747611176-843222e1e57c?w=400&q=80',
      'brand': 'Zara',
    },
    {
      'name': 'Pink Top',
      'price': 11,
      'fmtlPrice': 17,
      'discount': 20,
      'rating': 4.0,
      'reviews': 8,
      'image': '$_unsplash/photo-1564257631407-4deb1f99d992?w=400&q=80',
      'brand': 'H&M',
    },
    {
      'name': 'Casual Bag',
      'price': 18,
      'fmtlPrice': 25,
      'discount': 20,
      'rating': 3.5,
      'reviews': 5,
      'image': '$_unsplash/photo-1548036328-c9fa89d128fa?w=400&q=80',
      'brand': 'Gucci',
    },
    {
      'name': 'Sun Glasses',
      'price': 9,
      'fmtlPrice': 15,
      'discount': 20,
      'rating': 4.0,
      'reviews': 20,
      'image': '$_unsplash/photo-1572635196237-14b3f281503f?w=400&q=80',
      'brand': 'Ray-Ban',
    },
    {
      'name': 'White Sneakers',
      'price': 22,
      'fmtlPrice': 30,
      'discount': 20,
      'rating': 4.5,
      'reviews': 18,
      'image': '$_unsplash/photo-1600185365926-3a2ce3cdb9eb?w=400&q=80',
      'brand': 'Nike',
    },
    {
      'name': 'Sport Jacket',
      'price': 28,
      'fmtlPrice': 40,
      'discount': 20,
      'rating': 4.2,
      'reviews': 9,
      'image': '$_unsplash/photo-1591047139829-d91aecb6caea?w=400&q=80',
      'brand': 'Adidas',
    },
  ];

  // Just For You products
  static const List<Map<String, dynamic>> justForYouItems = [
    {
      'name': 'T-Shirt SPANISH',
      'price': 9,
      'fmtlPrice': null,
      'discount': null,
      'rating': 4.0,
      'reviews': 3,
      'image': '$_unsplash/photo-1521572163474-6864f9cf17ab?w=400&q=80',
      'brand': 'Mango',
    },
    {
      'name': 'Blouse',
      'price': 14,
      'fmtlPrice': 21,
      'discount': 20,
      'rating': 4.5,
      'reviews': 10,
      'image': '$_unsplash/photo-1564257631407-4deb1f99d992?w=400&q=80',
      'brand': 'Dorothy Perkins',
    },
    {
      'name': 'Shirt',
      'price': 17,
      'fmtlPrice': null,
      'discount': null,
      'rating': 3.0,
      'reviews': 6,
      'image': '$_unsplash/photo-1434389677669-e08b4cac3105?w=400&q=80',
      'brand': 'Mango',
    },
    {
      'name': 'Light blouse',
      'price': 14,
      'fmtlPrice': 21,
      'discount': 20,
      'rating': 4.5,
      'reviews': 10,
      'image': '$_unsplash/photo-1469334031218-e382a71b716b?w=400&q=80',
      'brand': 'Dorothy Perkins',
    },
    {
      'name': 'Summer Dress',
      'price': 19,
      'fmtlPrice': 28,
      'discount': 20,
      'rating': 4.0,
      'reviews': 15,
      'image': '$_unsplash/photo-1515886657613-9f3515b0c78f?w=400&q=80',
      'brand': 'Zara',
    },
    {
      'name': 'Casual Top',
      'price': 12,
      'fmtlPrice': null,
      'discount': null,
      'rating': 3.5,
      'reviews': 7,
      'image': '$_unsplash/photo-1576566588028-4147f3842f27?w=400&q=80',
      'brand': 'H&M',
    },
  ];
}