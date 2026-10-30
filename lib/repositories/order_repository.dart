import 'package:fmt/models/order_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/response/pagination_helper.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Customer orders (auth only): `GET /orders` newest-first paginated,
/// `GET /orders/{id}` with a fresh `whatsapp_url`, and
/// `GET /orders/{id}/invoice` returning a signed shareable invoice link.
class OrderRepository {
  OrderRepository({NetworkService? network}) : _network = network ?? Get.find();

  final NetworkService _network;

  Future<ApiResponse<PaginatedResult<OrderSummary>>> orders({
    int page = 1,
    int perPage = 10,
  }) async {
    final res = await _network.get(
      endpoint: ApiPath.orders,
      queryParams: {'page': page, 'per_page': perPage},
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final payload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : Map<String, dynamic>.from(data);
      final rawList = payload['orders'] ?? payload['data'] ?? [];
      final items = rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) =>
                  OrderSummary.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <OrderSummary>[];
      final rawMeta = payload['meta'];
      final meta = rawMeta is Map
          ? PaginationMeta.fromJson(Map<String, dynamic>.from(rawMeta))
          : PaginationMeta(
              currentPage: page,
              lastPage: items.length < perPage ? page : page + 1,
              total: items.length,
              perPage: perPage,
            );
      return ApiResponse.completed(
        PaginatedResult<OrderSummary>(items: items, meta: meta),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  Future<ApiResponse<OrderDetail>> orderDetail(Object id) async {
    final res = await _network.get(endpoint: ApiPath.orderDetail(id));
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      return ApiResponse.completed(
        OrderDetail.fromBody(res.data),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// Signed shareable invoice link — needs no auth header, open in browser.
  Future<ApiResponse<String>> invoiceUrl(Object id) async {
    final res = await _network.get(endpoint: ApiPath.orderInvoice(id));
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    final data = res.data!['data'];
    final map = data is Map ? Map<String, dynamic>.from(data) : {};
    final url = (map['invoice_url'] ?? map['url'])?.toString().trim() ?? '';
    if (url.isEmpty) return ApiResponse.error(res.message ?? '');
    return ApiResponse.completed(url, message: res.message);
  }
}
