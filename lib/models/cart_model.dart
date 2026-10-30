import 'package:fmt/utilities/image_path_helper.dart';

double _price(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim()) ?? 0;
  return 0;
}

int _int(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

/// One server cart line. Keyed by `cart_key` (not product id) because a
/// variable product holds one line per variant. Prices arrive as decimal
/// strings in some payloads and numbers in others — normalised on parse.
class CartLine {
  CartLine({
    required this.cartKey,
    required this.productId,
    required this.title,
    this.variantId,
    this.variantLabel,
    this.imageUrl,
    this.quantity = 1,
    this.unitPrice = 0,
    this.bulkPrice,
    this.minBulkQty,
    this.effectivePrice = 0,
  });

  final String cartKey;
  final int productId;
  final String title;
  final int? variantId;
  final String? variantLabel;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double? bulkPrice;
  final int? minBulkQty;
  final double effectivePrice;

  bool get hasVariant => variantId != null;

  /// Bulk tier applies once the line quantity reaches the threshold.
  bool get bulkActive {
    final bp = bulkPrice;
    final min = minBulkQty;
    return bp != null &&
        bp > 0 &&
        min != null &&
        min > 0 &&
        quantity >= min;
  }

  /// What one unit costs on this line right now.
  double get displayUnitPrice =>
      effectivePrice > 0 ? effectivePrice : unitPrice;

  double get lineTotal => displayUnitPrice * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        cartKey: cartKey,
        productId: productId,
        title: title,
        variantId: variantId,
        variantLabel: variantLabel,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice,
        bulkPrice: bulkPrice,
        minBulkQty: minBulkQty,
        effectivePrice: effectivePrice,
      );

  factory CartLine.fromJson(Map<String, dynamic> json) {
    return CartLine(
      cartKey: (json['cart_key'] ?? '').toString(),
      productId: _int(json['id'] ?? json['product_id']),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      variantId: json['variant_id'] == null
          ? null
          : _int(json['variant_id']),
      variantLabel: json['variant_label']?.toString(),
      imageUrl: getImage(
        (json['image_url'] ?? json['image'] ?? json['thumbnail'])?.toString(),
      ),
      quantity: _int(json['quantity'], 1),
      unitPrice: _price(json['unit_price']),
      bulkPrice:
          json['bulk_price'] == null ? null : _price(json['bulk_price']),
      minBulkQty: json['min_bulk_qty'] == null
          ? null
          : _int(json['min_bulk_qty']),
      effectivePrice: _price(
        json['effective_price'] ?? json['unit_price'],
      ),
    );
  }
}

class CartTotals {
  const CartTotals({
    this.itemsCount = 0,
    this.quantity = 0,
    this.subtotal = 0,
    this.total = 0,
  });

  final int itemsCount;
  final int quantity;
  final double subtotal;
  final double total;

  factory CartTotals.fromJson(Map<String, dynamic> json) {
    return CartTotals(
      itemsCount: _int(json['items_count']),
      quantity: _int(json['quantity'] ?? json['items_count']),
      subtotal: _price(json['subtotal']),
      total: _price(json['total'] ?? json['subtotal']),
    );
  }
}

/// Whole server cart: token + branch it belongs to + lines + totals.
/// Every cart response carries the full cart, so UIs re-parse instead of
/// re-fetching.
class CartData {
  const CartData({
    this.cartToken,
    this.storeId,
    this.items = const [],
    this.totals = const CartTotals(),
  });

  final String? cartToken;
  final int? storeId;
  final List<CartLine> items;
  final CartTotals totals;

  bool get isEmpty => items.isEmpty;

  static CartData? fromBody(Map<String, dynamic>? body) {
    try {
      if (body == null) return null;
      final data = body['data'];
      if (data is! Map<String, dynamic>) return null;
      final rawItems = data['items'];
      final items = rawItems is List
          ? rawItems
              .whereType<Map>()
              .map((e) => CartLine.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <CartLine>[];
      final rawTotals = data['totals'];
      return CartData(
        cartToken: data['cart_token']?.toString(),
        storeId:
            data['store_id'] == null ? null : _int(data['store_id']),
        items: items,
        totals: rawTotals is Map<String, dynamic>
            ? CartTotals.fromJson(rawTotals)
            : const CartTotals(),
      );
    } catch (_) {
      return null;
    }
  }
}
