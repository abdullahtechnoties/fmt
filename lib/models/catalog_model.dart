import 'package:fmt/utilities/image_path_helper.dart';

/// Normalises the API's dual price encoding: decimal strings in catalog
/// payloads (`"5250.00"`) and numbers in cart payloads.
double _parsePrice(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim()) ?? 0;
  return 0;
}

int _parseInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

bool _parseBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final t = v.trim().toLowerCase();
    return t == 'true' || t == '1' || t == 'yes';
  }
  return false;
}

/// Category card from `GET /home` / `GET /categories`.
/// Parses defensively — the API nests children inside parents.
class CatalogCategory {
  CatalogCategory({
    required this.id,
    required this.name,
    this.slug,
    this.image,
    this.productsCount = 0,
    this.children = const [],
  });

  final int id;
  final String name;
  final String? slug;
  final String? image;
  final int productsCount;
  final List<CatalogCategory> children;

  bool get hasChildren => children.isNotEmpty;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return CatalogCategory(
      id: _parseInt(json['id']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      slug: json['slug']?.toString(),
      image: getImage(
        (json['image'] ??
                json['image_url'] ??
                json['icon'] ??
                json['thumbnail'])
            ?.toString(),
      ),
      productsCount: _parseInt(
        json['products_count'] ?? json['productsCount'] ?? json['count'],
      ),
      children: rawChildren is List
          ? rawChildren
              .whereType<Map>()
              .map((e) =>
                  CatalogCategory.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// Product card from `GET /home` / `GET /products` / search.
class CatalogProduct {
  CatalogProduct({
    required this.id,
    required this.title,
    this.slug,
    this.thumbnail,
    this.regularPrice = 0,
    this.salePrice = 0,
    this.discount,
    this.inStock = true,
    this.type = 'simple',
    this.categoryName,
    this.rating = 0,
  });

  final int id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final double regularPrice;
  final double salePrice;
  final int? discount;
  final bool inStock;
  final String type;
  final String? categoryName;
  final double rating;

  /// What the customer pays — sale price wins when set.
  double get effectivePrice => salePrice > 0 ? salePrice : regularPrice;

  bool get hasDiscount =>
      (discount != null && discount! > 0) ||
      (salePrice > 0 && salePrice < regularPrice);

  /// Discount %, from the field when present, else derived from prices.
  int get discountPercent {
    if (discount != null && discount! > 0) return discount!;
    if (regularPrice > 0 && salePrice > 0 && salePrice < regularPrice) {
      return (((regularPrice - salePrice) / regularPrice) * 100).round();
    }
    return 0;
  }

  bool get isVariable => type == 'variable';

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    return CatalogProduct(
      id: _parseInt(json['id']),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      thumbnail: getImage(
        (json['thumbnail'] ?? json['image'] ?? json['image_url'])?.toString(),
      ),
      regularPrice: _parsePrice(json['regular_price']),
      salePrice: _parsePrice(json['sale_price']),
      discount: json['discount'] == null
          ? null
          : _parseInt(json['discount']),
      inStock: json.containsKey('stock_status')
          ? _parseBool(json['stock_status'])
          : (json.containsKey('in_stock')
              ? _parseBool(json['in_stock'])
              : true),
      type: json['type']?.toString() ?? 'simple',
      categoryName: json['category_name']?.toString(),
      rating: _parsePrice(json['rating']),
    );
  }
}

/// The four home-screen blocks from `GET /home`.
/// Variant of a variable product (`GET /products/{slug}`)..
/// `attribute_values` links it to attribute options; `in_stock` and
/// `stock_qty` are branch-relative.
class HomeData {
  HomeData({
    this.categories = const [],
    this.latestProducts = const [],
    this.featuredProducts = const [],
    this.specialProducts = const [],
  });

  final List<CatalogCategory> categories;
  final List<CatalogProduct> latestProducts;
  final List<CatalogProduct> featuredProducts;
  final List<CatalogProduct> specialProducts;

  static List<CatalogCategory> _cats(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CatalogCategory.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<CatalogProduct> _prods(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => CatalogProduct.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    return HomeData(
      categories: _cats(data['categories']),
      latestProducts: _prods(data['latest_products']),
      featuredProducts: _prods(data['featured_products']),
      specialProducts: _prods(data['special_products']),
    );
  }
}

/// One selectable option of a product attribute, e.g. Size = Small.
/// `inStock` is true when at least one variant holding this value has stock
/// at the current branch — use it to disable sold-out options.
class ProductAttributeValue {
  ProductAttributeValue({
    required this.id,
    required this.value,
    this.inStock = true,
  });

  final int id;
  final String value;
  final bool inStock;

  factory ProductAttributeValue.fromJson(Map<String, dynamic> json) {
    return ProductAttributeValue(
      id: _parseInt(json['value_id'] ?? json['id']),
      value: (json['value'] ?? '').toString(),
      inStock: json.containsKey('in_stock')
          ? _parseBool(json['in_stock'])
          : true,
    );
  }
}

/// One attribute group of a variable product, e.g. Size: [Small, Large].
class ProductAttribute {
  ProductAttribute({
    required this.id,
    required this.name,
    this.values = const [],
  });

  final int id;
  final String name;
  final List<ProductAttributeValue> values;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    final raw = json['values'];
    return ProductAttribute(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      values: raw is List
          ? raw
              .whereType<Map>()
              .map((e) => ProductAttributeValue.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

/// One purchasable variant: a concrete combination of attribute values.
class ProductVariant {
  ProductVariant({
    required this.id,
    this.sku,
    this.regularPrice = 0,
    this.salePrice = 0,
    this.bulkPrice,
    this.minBulkQty,
    this.stockQty = 0,
    this.inStock = true,
    this.optionValueIds = const [],
    this.optionLabels = const [],
  });

  final int id;
  final String? sku;
  final double regularPrice;
  final double salePrice;
  final double? bulkPrice;
  final int? minBulkQty;
  final int stockQty;
  final bool inStock;

  /// `value_id`s of this variant's attribute values (for matching).
  final List<int> optionValueIds;

  /// Human labels of this variant's attribute values (for the cart line).
  final List<String> optionLabels;

  double get effectivePrice => salePrice > 0 ? salePrice : regularPrice;

  bool get hasDiscount => salePrice > 0 && salePrice < regularPrice;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final rawAttrs = json['attribute_values'];
    final ids = <int>[];
    final labels = <String>[];
    if (rawAttrs is List) {
      for (final e in rawAttrs.whereType<Map>()) {
        final m = Map<String, dynamic>.from(e);
        ids.add(_parseInt(m['value_id'] ?? m['id']));
        final label = (m['value'] ?? '').toString();
        if (label.isNotEmpty) labels.add(label);
      }
    }
    return ProductVariant(
      id: _parseInt(json['id']),
      sku: json['sku']?.toString(),
      regularPrice: _parsePrice(json['regular_price']),
      salePrice: _parsePrice(json['sale_price']),
      bulkPrice: json['bulk_price'] == null
          ? null
          : _parsePrice(json['bulk_price']),
      minBulkQty: json['min_bulk_qty'] == null
          ? null
          : _parseInt(json['min_bulk_qty']),
      stockQty: _parseInt(json['stock_qty']),
      inStock: json.containsKey('in_stock')
          ? _parseBool(json['in_stock'])
          : true,
      optionValueIds: ids,
      optionLabels: labels,
    );
  }
}

/// Full product detail from `GET /products/{slug}`: gallery, variants,
/// attribute groups (for the option pickers), bulk pricing and up to 8
/// related product cards.
class ProductDetail {
  ProductDetail({
    required this.id,
    required this.title,
    this.slug,
    this.thumbnail,
    this.regularPrice = 0,
    this.salePrice = 0,
    this.discount,
    this.inStock = true,
    this.type = 'simple',
    this.categoryName,
    this.rating = 0,
    this.stockQty = 0,
    this.sku,
    this.description,
    this.shortDescription,
    this.bulkPrice,
    this.minBulkQty,
    this.gallery = const [],
    this.variants = const [],
    this.attributes = const [],
    this.relatedProducts = const [],
  });

  final int id;
  final String title;
  final String? slug;
  final String? thumbnail;
  final double regularPrice;
  final double salePrice;
  final int? discount;
  final bool inStock;
  final String type;
  final String? categoryName;
  final double rating;
  final int stockQty;
  final String? sku;
  final String? description;
  final String? shortDescription;
  final double? bulkPrice;
  final int? minBulkQty;
  final List<String> gallery;
  final List<ProductVariant> variants;
  final List<ProductAttribute> attributes;
  final List<CatalogProduct> relatedProducts;

  bool get isVariable => type == 'variable';

  double get effectivePrice => salePrice > 0 ? salePrice : regularPrice;

  bool get hasDiscount =>
      (discount != null && discount! > 0) ||
      (salePrice > 0 && salePrice < regularPrice);

  /// Discount %, from the field when present, else derived from prices.
  int get discountPercent {
    if (discount != null && discount! > 0) return discount!;
    if (regularPrice > 0 && salePrice > 0 && salePrice < regularPrice) {
      return (((regularPrice - salePrice) / regularPrice) * 100).round();
    }
    return 0;
  }

  /// Gallery with the cover first, de-duplicated (cover may repeat).
  List<String> get allImages {
    final out = <String>[];
    void add(String? url) {
      final u = url?.trim() ?? '';
      if (u.isNotEmpty && !out.contains(u)) out.add(u);
    }

    add(thumbnail);
    for (final g in gallery) {
      add(g);
    }
    return out;
  }

  /// Exact variant matching every selected attribute value.
  ProductVariant? matchVariant(Map<int, int> selected) {
    if (!isVariable || selected.isEmpty) return null;
    final wanted = selected.values.toSet();
    for (final v in variants) {
      final have = v.optionValueIds.toSet();
      if (have.length == wanted.length && have.containsAll(wanted)) {
        return v;
      }
    }
    return null;
  }

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final rawGallery = json['gallery'];
    final rawVariants = json['variants'];
    final rawAttributes = json['attributes'];
    final rawRelated =
        json['related_products'] ?? json['relatedProducts'];
    return ProductDetail(
      id: _parseInt(json['id']),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      slug: json['slug']?.toString(),
      thumbnail: getImage(
        (json['thumbnail'] ?? json['image'] ?? json['image_url'])?.toString(),
      ),
      regularPrice: _parsePrice(json['regular_price']),
      salePrice: _parsePrice(json['sale_price']),
      discount:
          json['discount'] == null ? null : _parseInt(json['discount']),
      inStock: json.containsKey('stock_status')
          ? _parseBool(json['stock_status'])
          : (json.containsKey('in_stock')
              ? _parseBool(json['in_stock'])
              : true),
      type: json['type']?.toString() ?? 'simple',
      categoryName: json['category_name']?.toString(),
      rating: _parsePrice(json['rating']),
      stockQty: _parseInt(json['stock_qty']),
      sku: json['sku']?.toString(),
      description:
          (json['description'] ?? json['long_description'])?.toString(),
      shortDescription: json['short_description']?.toString(),
      bulkPrice: json['bulk_price'] == null
          ? null
          : _parsePrice(json['bulk_price']),
      minBulkQty: json['min_bulk_qty'] == null
          ? null
          : _parseInt(json['min_bulk_qty']),
      gallery: rawGallery is List
          ? rawGallery
              .map((e) => (getImage(e?.toString()) ?? '').trim())
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      variants: rawVariants is List
          ? rawVariants
              .whereType<Map>()
              .map((e) =>
                  ProductVariant.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      attributes: rawAttributes is List
          ? rawAttributes
              .whereType<Map>()
              .map((e) =>
                  ProductAttribute.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      relatedProducts: rawRelated is List
          ? rawRelated
              .whereType<Map>()
              .map((e) =>
                  CatalogProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}
