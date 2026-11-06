import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fmt/app/modules/chat/controllers/chat_controller.dart';
import 'package:fmt/app/modules/orderDetails/controllers/order_details_controller.dart';
import 'package:fmt/app/modules/orderHistory/controllers/order_history_controller.dart';
import 'package:fmt/app/modules/support/controllers/support_controller.dart';
import 'package:fmt/app/modules/ticketDetails/controllers/ticket_details_controller.dart';
import 'package:fmt/app/modules/ticketList/controllers/ticket_list_controller.dart';
import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/chat_model.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/chat_repository.dart';
import 'package:get/get.dart';

/// Routes every push by its `data.type`:
/// - `chat` → `{conversation_id, message_id}` → chat screen
/// - `order` → `{order_id, status}` → order details (refreshes history)
/// - `ticket` → `{reference, ticket_id}` → ticket thread by reference
///
/// Guests are ignored (chat is login-only; guest orders have no account
/// to notify). Taps from a terminated state arrive via getInitialMessage
/// and are consumed post-splash by [handlePendingLaunch].
class NotificationResolverService {
  NotificationResolverService._privateConstructor();
  static final NotificationResolverService instance =
      NotificationResolverService._privateConstructor();

  bool get _loggedIn {
    try {
      final auth = Get.find<AuthService>();
      if (auth.currentUser.value != null) return true;
    } catch (_) {}
    return AuthService.authenticated();
  }

  /// Foreground pushes update live state but never navigate; taps do.
  void handleNotification(RemoteMessage message, {bool isTap = false}) {
    if (!_loggedIn) return;
    final type = '${message.data['type'] ?? ''}'.toLowerCase().trim();
    if (type == 'chat') {
      _onChat(message, isTap: isTap);
    } else if (type == 'order') {
      _onOrder(message, isTap: isTap);
    } else if (type == 'ticket') {
      _onTicket(message, isTap: isTap);
    }
  }

  /// Called once routing is ready (post-splash) for cold-start taps.
  void handlePendingLaunch(RemoteMessage? message) {
    if (message == null) return;
    handleNotification(message, isTap: true);
  }

  // ─── Chat ─────────────────────────────────────────────────────────────────

  void _onChat(RemoteMessage message, {required bool isTap}) {
    _refreshChat(message);
    if (!isTap) return;
    final convId =
        int.tryParse('${message.data['conversation_id'] ?? ''}');
    if (Get.currentRoute == Routes.CHAT) {
      // Already inside the thread — the live feed/poll picks it up.
      if (Get.isRegistered<ChatController>()) {
        Get.find<ChatController>().handleExternalPing();
      }
      return;
    }
    final args = <String, dynamic>{};
    if (convId != null) args['conversationId'] = convId;
    final msgId = '${message.data['message_id'] ?? ''}';
    if (msgId.isNotEmpty) args['highlightMessageId'] = msgId;
    Get.toNamed(Routes.CHAT, arguments: args.isEmpty ? null : args);
  }

  void _refreshChat(RemoteMessage message) {
    if (!Get.isRegistered<ChatController>()) return;
    final controller = Get.find<ChatController>();
    final msgId = '${message.data['message_id'] ?? ''}';
    if (msgId.isNotEmpty && msgId != controller.lastSeenMessageId) {
      controller.refreshFromPush();
    }
  }

  // ─── Orders ───────────────────────────────────────────────────────────────

  void _onOrder(RemoteMessage message, {required bool isTap}) {
    final orderId = '${message.data['order_id'] ?? ''}';
    if (orderId.isEmpty) return;
    if (Get.isRegistered<OrderHistoryController>()) {
      try {
        Get.find<OrderHistoryController>().loadOrders();
      } catch (_) {}
    }
    if (Get.isRegistered<OrderDetailsController>()) {
      try {
        final details = Get.find<OrderDetailsController>();
        if ('${details.orderId}' == orderId) details.loadDetail();
      } catch (_) {}
    }
    if (!isTap) return;
    if (Get.currentRoute == Routes.ORDER_DETAILS) {
      try {
        final details = Get.find<OrderDetailsController>();
        if ('${details.orderId}' == orderId) return;
      } catch (_) {}
    }
    Get.toNamed(Routes.ORDER_DETAILS, arguments: orderId);
  }

  /// App-resume refresh: chat badge + live thread, newest orders.
  /// Pushes are best-effort — this is the source of truth.
  Future<void> refreshAll() async {
    if (!_loggedIn) return;
    if (Get.isRegistered<ChatController>()) {
      try {
        await Get.find<ChatController>().refreshFromPush();
      } catch (_) {}
    } else {
      try {
        await ChatRepository().unreadCount();
      } catch (_) {}
    }
    if (Get.isRegistered<OrderHistoryController>()) {
      try {
        await Get.find<OrderHistoryController>().loadOrders();
      } catch (_) {}
    }
    if (Get.isRegistered<TicketListController>()) {
      try {
        Get.find<TicketListController>().refreshQuietly();
      } catch (_) {}
    }
    if (Get.isRegistered<SupportController>()) {
      try {
        Get.find<SupportController>().refreshUnread();
      } catch (_) {}
    }
  }

  // ─── Support tickets ──────────────────────────────────────────────────────

  void _onTicket(RemoteMessage message, {required bool isTap}) {
    final reference = '${message.data['reference'] ?? ''}'.trim();
    if (reference.isEmpty) return;
    if (Get.isRegistered<TicketListController>()) {
      try {
        Get.find<TicketListController>().refreshQuietly();
      } catch (_) {}
    }
    if (Get.isRegistered<TicketDetailsController>()) {
      try {
        final details = Get.find<TicketDetailsController>();
        if (details.reference == reference) details.loadTicket();
      } catch (_) {}
    }
    if (!isTap) return;
    if (Get.currentRoute == Routes.TICKET_DETAILS) {
      try {
        final details = Get.find<TicketDetailsController>();
        if (details.reference == reference) return;
      } catch (_) {}
    }
    Get.toNamed(Routes.TICKET_DETAILS, arguments: reference);
  }
}

/// Re-exported for call sites that only import the resolver.
typedef ChatMessageModel = ChatMessage;
