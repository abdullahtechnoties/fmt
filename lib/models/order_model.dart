/// Orders: `GET /orders` (newest first, paginated) and
/// `GET /orders/{id}` (one order plus a fresh `whatsapp_url`).
/// Shapes are defensive — the API doc only names the key fields.
class OrderItem {
  OrderItem({
    this.title,
    this.imageUrl,
    this.variantLabel,
    this.quantity = 0,
    this.price = 0,
    this.subtotal = 0,
  });

  final String? title;
  final String? imageUrl;
  final String? variantLabel;
  final int quantity;
  final double price;
  final double subtotal;

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final qty = _int(json['quantity'] ?? json['qty']);
    final price = _num(json['price'] ?? json['unit_price']);
    final sub = _num(json['subtotal'] ?? json['line_total']);
    return OrderItem(
      title: (json['product_title'] ?? json['title'] ?? json['name'])
          ?.toString(),
      imageUrl: (json['image'] ?? json['thumbnail'] ?? json['product_image'])
          ?.toString(),
      variantLabel:
          (json['variant_label'] ?? json['variant'])?.toString(),
      quantity: qty,
      price: price,
      subtotal: sub == 0 ? price * qty : sub,
    );
  }
}

class OrderSummary {
  OrderSummary({
    this.id,
    this.status,
    this.paymentMethod,
    this.total = 0,
    this.itemsCount = 0,
    this.createdAt,
    this.storeName,
    this.previewTitle,
    this.previewImage,
  });

  final dynamic id;
  final String? status;
  final String? paymentMethod;
  final double total;
  final int itemsCount;
  final String? createdAt;
  final String? storeName;
  final String? previewTitle;
  final String? previewImage;

  String get statusLabel => (status ?? 'pending').trim();

  bool get isPending => statusLabel.toLowerCase() == 'pending';

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse('$v') ?? 0;
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : <String, dynamic>{};

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    final store = _map(json['store']);
    final items = json['items'] is List ? json['items'] as List : const [];
    String? previewTitle;
    String? previewImage;
    if (items.isNotEmpty && items.first is Map) {
      final first = Map<String, dynamic>.from(items.first);
      previewTitle = (first['product_title'] ?? first['title'])?.toString();
      previewImage =
          (first['image'] ?? first['thumbnail'] ?? first['product_image'])
              ?.toString();
    }
    return OrderSummary(
      id: json['id'],
      status: json['status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      total: _num(json['total'] ?? json['grand_total']),
      itemsCount: _int(json['items_count'] ??
          json['total_items'] ??
          (items.isNotEmpty ? items.length : 0)),
      createdAt:
          (json['created_at'] ?? json['date'] ?? json['order_date'])
              ?.toString(),
      storeName: (store['name'] ?? json['store_name'])?.toString(),
      previewTitle: previewTitle,
      previewImage: previewImage,
    );
  }
}

class OrderDetail {
  OrderDetail({
    required this.summary,
    this.items = const [],
    this.subtotal = 0,
    this.storeName,
    this.billingName,
    this.billingPhone,
    this.billingAddress,
    this.billingCity,
    this.notes,
    this.whatsappUrl,
  });

  final OrderSummary summary;
  final List<OrderItem> items;
  final double subtotal;
  final String? storeName;
  final String? billingName;
  final String? billingPhone;
  final String? billingAddress;
  final String? billingCity;
  final String? notes;
  final String? whatsappUrl;

  bool get hasWhatsapp => (whatsappUrl ?? '').trim().isNotEmpty;

  static OrderDetail fromBody(Map<String, dynamic>? body) {
    final data = body?['data'];
    final Map<String, dynamic> map = data is Map
        ? Map<String, dynamic>.from(data)
        : <String, dynamic>{};
    final rawOrder = map['order'];
    final Map<String, dynamic> orderJson = rawOrder is Map
        ? Map<String, dynamic>.from(rawOrder)
        : map;
    final summary = OrderSummary.fromJson(orderJson);
    final rawItems = orderJson['items'];
    final items = rawItems is List
        ? rawItems
            .whereType<Map>()
            .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <OrderItem>[];
    double sub = 0;
    if (orderJson['subtotal'] != null) {
      final v = orderJson['subtotal'];
      sub = v is num ? v.toDouble() : double.tryParse('$v') ?? 0;
    } else {
      for (final i in items) {
        sub += i.subtotal;
      }
    }
    final billing = orderJson['billing'] is Map
        ? Map<String, dynamic>.from(orderJson['billing'])
        : orderJson;
    String? addr = (billing['billing_address'] ?? billing['address'])
        ?.toString();
    final city =
        (billing['billing_city'] ?? billing['city'])?.toString();
    if (addr != null && city != null && city.isNotEmpty) {
      addr = '$addr, $city';
    }
    return OrderDetail(
      summary: summary,
      items: items,
      subtotal: sub,
      storeName: summary.storeName,
      billingName: (billing['billing_name'] ?? billing['name'])?.toString(),
      billingPhone:
          (billing['billing_phone'] ?? billing['phone'])?.toString(),
      billingAddress: addr,
      billingCity: city,
      notes: (orderJson['order_notes'] ?? orderJson['notes'])?.toString(),
      whatsappUrl: map['whatsapp_url']?.toString() ??
          orderJson['whatsapp_url']?.toString(),
    );
  }
}
