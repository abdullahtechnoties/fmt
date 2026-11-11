import 'dart:io';

import 'package:fmt/models/cart_model.dart';
import 'package:fmt/models/payment_proof_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Checkout + order placement API (auth only).
class CheckoutRepository {
  CheckoutRepository({NetworkService? network})
    : _network = network ?? Get.find();

  final NetworkService _network;

  /// `GET /checkout/summary` — recalculated cart, saved address for
  /// prefill, payment-proof rules and notice lines. 422 when the cart is
  /// empty.
  Future<ApiResponse<Map<String, dynamic>>> summary() {
    return _network.get(endpoint: ApiPath.checkoutSummary);
  }

  /// `POST /orders` — revalidates stock, creates the order, empties the cart.
  ///
  /// Sent as multipart/form-data when [paymentProof] is attached and as
  /// ordinary JSON when it is not. A rejected proof rolls the whole order
  /// back, so the customer can retry without creating a duplicate.
  Future<ApiResponse<Map<String, dynamic>>> placeOrder({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String city,
    required String province,
    required String country,
    String? zip,
    String? notes,
    int? storeId,
    File? paymentProof,
    String paymentProofField = 'payment_proof',
  }) {
    final fields = <String, dynamic>{
      'billing_name': name,
      'billing_email': email,
      'billing_phone': phone,
      'billing_address': address,
      'billing_city': city,
      'billing_province': province,
      'billing_country': country,
      if (zip != null && zip.trim().isNotEmpty) 'billing_zip': zip.trim(),
      if (notes != null && notes.trim().isNotEmpty) 'order_notes': notes.trim(),
      if (storeId != null) 'store_id': storeId,
    };

    if (paymentProof != null) {
      return _network.postForm(
        endpoint: ApiPath.orders,
        fields: fields,
        files: {paymentProofField: paymentProof},
      );
    }

    return _network.post(endpoint: ApiPath.orders, body: fields);
  }
}

/// Parsed `GET /checkout/summary` payload. Every field is optional — the UI
/// falls back to the logged-in user and the live cart.
class CheckoutSummary {
  const CheckoutSummary({
    this.cart,
    this.savedAddress = const {},
    this.paymentProofRules = const PaymentProofRules(),
    this.notices = const [],
  });

  final CartData? cart;
  final Map<String, dynamic> savedAddress;
  final PaymentProofRules paymentProofRules;
  final List<String> notices;

  static Map<String, dynamic> _map(dynamic v) => v is Map<String, dynamic>
      ? v
      : (v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{});

  static CheckoutSummary fromBody(Map<String, dynamic>? body) {
    if (body == null) return const CheckoutSummary();
    final data = _map(body['data']);
    if (data.isEmpty) return const CheckoutSummary();
    final rawCart = data['cart'];
    final rawAddress =
        data['saved_address'] ?? data['address'] ?? data['billing_address'];
    final rawProofRules = data['payment_proof'];
    final rawNotices =
        data['notices'] ?? data['notice_lines'] ?? data['notice'];
    return CheckoutSummary(
      cart: rawCart is Map
          ? CartData.fromBody({'data': Map<String, dynamic>.from(rawCart)})
          : null,
      savedAddress: _map(rawAddress),
      paymentProofRules: PaymentProofRules.fromJson(_map(rawProofRules)),
      notices: rawNotices is List
          ? rawNotices.map((e) => e.toString()).toList()
          : (rawNotices is String ? [rawNotices] : const []),
    );
  }
}

/// Parsed `POST /orders` success payload.
class PlacedOrder {
  const PlacedOrder({
    this.id,
    this.status,
    this.paymentMethod,
    this.total = 0,
    this.whatsappUrl,
    this.paymentProof,
  });

  final dynamic id;
  final String? status;
  final String? paymentMethod;
  final double total;
  final String? whatsappUrl;
  final PaymentProof? paymentProof;

  static PlacedOrder fromBody(Map<String, dynamic>? body) {
    final data = body?['data'];
    final order = data is Map ? data['order'] : null;
    double total = 0;
    if (order is Map && order['total'] != null) {
      final t = order['total'];
      total = t is num ? t.toDouble() : double.tryParse('$t') ?? 0;
    }
    return PlacedOrder(
      id: order is Map ? order['id'] : null,
      status: order is Map ? order['status']?.toString() : null,
      paymentMethod: order is Map ? order['payment_method']?.toString() : null,
      total: total,
      whatsappUrl: data is Map ? data['whatsapp_url']?.toString() : null,
      paymentProof: PaymentProof.tryParse(
        order is Map ? order['payment_proof'] : null,
      ),
    );
  }
}
