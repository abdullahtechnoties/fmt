import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/utilities/auth_guard.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// Login-gated entry into the in-app store chat.
///
/// Chat is auth-only with one thread per customer (no guest chat, no
/// thread list), so every entry funnels through [openChat]. The order
/// screens use [confirmOrderOnChat], which drops the same confirmation
/// intent as the WhatsApp button into the composer for the customer to
/// send — the thread is created server-side on first send.
class ChatNavigator {
  ChatNavigator._();

  static Future<void> openChat({String? prefill}) async {
    final allowed = await AuthGuard.requireLogin(
      title: 'auth.required_title'.trns(),
      message: 'auth.required_chat'.trns(),
    );
    if (!allowed) return;
    Get.toNamed(
      Routes.CHAT,
      arguments: prefill != null && prefill.isNotEmpty
          ? {'prefill': prefill}
          : null,
    );
  }

  static Future<void> confirmOrderOnChat({
    required dynamic orderId,
    required double total,
  }) {
    final money = NumberFormat('#,##0', 'en_US');
    return openChat(
      prefill: 'chat.confirm_prefill'.trnsFormat({
        'id': '$orderId',
        'currency': 'home.currency_symbol'.trns(),
        'total': money.format(total),
      }),
    );
  }
}
