import 'package:fmt/models/support_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/response/pagination_helper.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Support tickets (auth only): categories for the form, raising a
/// ticket, the customer's own ticket list (paginated, newest activity
/// first), one ticket with its thread, replies (which reopen a finished
/// ticket), per-ticket read, and the global unread badge.
class SupportRepository {
  SupportRepository({NetworkService? network})
      : _network = network ?? Get.find();

  final NetworkService _network;

  /// Active categories in display order — fetched, never hardcoded.
  Future<ApiResponse<List<SupportCategory>>> categories() async {
    final res =
        await _network.get(endpoint: ApiPath.supportCategories);
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      final data = res.data!;
      final payload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : <String, dynamic>{};
      final raw = payload['categories'] ?? [];
      final items = raw is List
          ? raw
              .whereType<Map>()
              .map((e) => SupportCategory.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : <SupportCategory>[];
      return ApiResponse.completed(items, message: res.message);
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// Raises a ticket — 201 with the ticket incl. its new reference.
  Future<ApiResponse<SupportTicket>> raise({
    required dynamic categoryId,
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    final res = await _network.post(
      endpoint: ApiPath.supportTickets,
      body: {
        'ticket_category_id': categoryId,
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
      },
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      return ApiResponse.completed(
        SupportTicket.fromBody(res.data),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// Own tickets, newest activity first (rows omit the thread).
  Future<ApiResponse<PaginatedResult<SupportTicket>>> tickets({
    int page = 1,
    int perPage = 15,
  }) async {
    final res = await _network.get(
      endpoint: ApiPath.supportTickets,
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
      final rawList =
          payload['tickets'] ?? payload['data'] ?? <dynamic>[];
      final items = rawList is List
          ? rawList
              .whereType<Map>()
              .map((e) => SupportTicket.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : <SupportTicket>[];
      final rawMeta = payload['meta'];
      final meta = rawMeta is Map
          ? PaginationMeta.fromJson(
              Map<String, dynamic>.from(rawMeta))
          : PaginationMeta(
              currentPage: page,
              lastPage: items.length < perPage ? page : page + 1,
              total: items.length,
              perPage: perPage,
            );
      return ApiResponse.completed(
        PaginatedResult<SupportTicket>(items: items, meta: meta),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// One ticket with its full thread — opening clears its unread badge.
  Future<ApiResponse<SupportTicket>> ticket(Object reference) async {
    final res = await _network.get(
      endpoint: ApiPath.supportTicket(reference),
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      return ApiResponse.completed(
        SupportTicket.fromBody(res.data),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// Replies (201 with the updated ticket) — reopens a finished ticket
  /// back to `open`, so the caller must re-read `status` from the result.
  Future<ApiResponse<SupportTicket>> reply(
    Object reference,
    String body,
  ) async {
    final res = await _network.post(
      endpoint: ApiPath.supportTicketReplies(reference),
      body: {'body': body},
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    try {
      return ApiResponse.completed(
        SupportTicket.fromBody(res.data),
        message: res.message,
      );
    } catch (_) {
      return ApiResponse.error(res.message ?? '');
    }
  }

  /// Clears one ticket's badge without fetching the thread.
  Future<bool> markRead(Object reference) async {
    try {
      final res = await _network.post(
        endpoint: ApiPath.supportTicketRead(reference),
      );
      return !res.isError;
    } catch (_) {
      return false;
    }
  }

  /// Global badge: `{unread_count, open_tickets}` — cheap on resume.
  Future<({int unread, int open})> unread() async {
    try {
      final res =
          await _network.get(endpoint: ApiPath.supportUnread);
      if (res.isError || res.data == null) return (unread: 0, open: 0);
      final data = res.data!;
      final payload = data['data'] is Map
          ? Map<String, dynamic>.from(data['data'])
          : Map<String, dynamic>.from(data);
      return (
        unread: SupportTicket.parseInt(payload['unread_count']),
        open: SupportTicket.parseInt(payload['open_tickets']),
      );
    } catch (_) {
      return (unread: 0, open: 0);
    }
  }
}
