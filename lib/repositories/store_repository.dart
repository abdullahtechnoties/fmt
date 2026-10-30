import 'dart:convert';

import 'package:fmt/models/bootstrap_model.dart';
import 'package:fmt/models/catalog_model.dart';
import 'package:fmt/models/store_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/response/pagination_helper.dart';
import 'package:fmt/network/service/local_storage.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:fmt/utilities/app_strings.dart';
import 'package:get/get.dart';

/// Public catalog API: bootstrap, stores, home blocks, categories.
class StoreRepository {
  StoreRepository({NetworkService? network}) : _network = network ?? Get.find();

  final NetworkService _network;

  Future<ApiResponse<BootstrapData>> bootstrap() async {
    final res = await _network.get(endpoint: ApiPath.bootstrap);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = BootstrapData.fromJson(res.data!);
      _cacheBootstrap(res.data!);
      return ApiResponse.completed(data, message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  Future<ApiResponse<List<StoreModel>>> stores() async {
    final res = await _network.get(endpoint: ApiPath.stores);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final raw = data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)['stores']
          : data['stores'];
      if (raw is! List) return ApiResponse.error(res.message ?? '');
      final list = raw
          .whereType<Map>()
          .map((e) => StoreModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      return ApiResponse.completed(list, message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  Future<ApiResponse<HomeData>> home() async {
    final res = await _network.get(endpoint: ApiPath.home);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      return ApiResponse.completed(HomeData.fromJson(res.data!),
          message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  Future<ApiResponse<List<CatalogCategory>>> categories() async {
    final res = await _network.get(endpoint: ApiPath.categories);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final raw = data['data'] is Map<String, dynamic>
          ? (data['data'] as Map<String, dynamic>)['categories']
          : data['categories'];
      final list = raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  CatalogCategory.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <CatalogCategory>[];
      return ApiResponse.completed(list, message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// `GET /products` — paginated listing with the website-shop filters.
  /// [categoryIds] are sent as comma-separated ids (children included
  /// automatically). [sort] is one of latest (default), price_low,
  /// price_high, name_asc, name_desc. [stock] is in_stock / out_of_stock
  /// (relative to the current X-Store-Id) or null for all.
  Future<ApiResponse<PaginatedResult<CatalogProduct>>> products({
    List<int>? categoryIds,
    String? search,
    String sort = 'latest',
    String? stock,
    int perPage = 12,
    int page = 1,
  }) async {
    final res = await _network.get(
      endpoint: ApiPath.products,
      queryParams: {
        if (categoryIds != null && categoryIds.isNotEmpty)
          'categories': categoryIds.join(','),
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        'sort': sort,
        if (stock != null && stock.isNotEmpty) 'stock': stock,
        'per_page': perPage,
        'page': page,
      },
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final body = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final raw = body['products'];
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) =>
                  CatalogProduct.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : <CatalogProduct>[];
      final metaRaw = body['meta'];
      final meta = metaRaw is Map<String, dynamic>
          ? PaginationMeta.fromJson(metaRaw)
          : PaginationMeta(
              currentPage: page, lastPage: page, total: items.length, perPage: perPage);
      return ApiResponse.completed(PaginatedResult(items: items, meta: meta),
          message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// `GET /products/{slug}` — full detail: gallery, variants, attributes
  /// (option pickers), bulk pricing and related product cards.
  Future<ApiResponse<ProductDetail>> productDetail(String slug) async {
    final res = await _network.get(endpoint: ApiPath.productDetail(slug));
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final body = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final raw = body['product'];
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.error(res.message ?? '');
      }
      return ApiResponse.completed(ProductDetail.fromJson(raw),
          message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  void _cacheBootstrap(Map<String, dynamic> body) {
    try {
      LocalStorageService.prefs?.setString(
        AppStrings.bootstrapCache,
        jsonEncode(body),
      );
    } catch (_) {}
  }

  /// Last cached bootstrap (for offline first paint).
  BootstrapData? cachedBootstrap() {
    try {
      final raw =
          LocalStorageService.prefs?.getString(AppStrings.bootstrapCache);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      return BootstrapData.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }
}
