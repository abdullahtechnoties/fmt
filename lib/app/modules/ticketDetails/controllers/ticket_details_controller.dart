import 'package:flutter/material.dart';
import 'package:fmt/models/support_model.dart';
import 'package:fmt/repositories/support_repository.dart';
import 'package:fmt/utilities/chat_navigator.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// One ticket with its full thread (`GET /support/tickets/{reference}`)
/// plus replies. Opening clears the badge server-side; replying to a
/// finished ticket reopens it, so status is always re-read from the reply
/// response and the UI warns before sending.
class TicketDetailsController extends GetxController {
  TicketDetailsController({SupportRepository? supportRepo})
      : _supportRepo = supportRepo ?? SupportRepository();

  final SupportRepository _supportRepo;

  String get reference => '${Get.arguments ?? ''}';

  final Rxn<SupportTicket> ticket = Rxn<SupportTicket>();
  final isLoading = true.obs;
  final RxnString loadError = RxnString();
  final isReplying = false.obs;
  final replyController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadTicket();
  }

  Future<void> loadTicket() async {
    if (reference.isEmpty) {
      loadError.value = 'ticket_details.load_failed'.trns();
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _supportRepo.ticket(reference);
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'ticket_details.load_failed'.trns();
        return;
      }
      ticket.value = res.data!;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendReply() async {
    final body = replyController.text.trim();
    if (body.isEmpty || isReplying.value) return;
    isReplying.value = true;
    try {
      final res = await _supportRepo.reply(reference, body);
      if (res.isError || res.data == null) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: (res.message?.isNotEmpty ?? false)
              ? res.message!
              : 'ticket_details.reply_failed'.trns(),
        );
        return;
      }
      // Re-read: a reply to a finished ticket reopens it to `open`.
      ticket.value = res.data!;
      replyController.clear();
      SnackbarService.showSuccess(
        title: 'common.success'.trns(),
        message: 'ticket_details.reply_sent'.trns(),
      );
      _scrollToBottom();
    } finally {
      isReplying.value = false;
    }
  }

  Future<void> openChat() => ChatNavigator.openChat();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      try {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      } catch (_) {}
    });
  }

  @override
  void onClose() {
    replyController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
