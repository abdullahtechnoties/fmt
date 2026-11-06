import 'package:fmt/app/routes/app_pages.dart';
import 'package:fmt/models/support_model.dart';
import 'package:fmt/repositories/support_repository.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:get/get.dart';

/// The customer's own tickets, newest activity first (`GET /support/tickets`,
/// paginated). Tapping a row opens the thread; coming back quietly refreshes
/// so the unread dots clear (opening a ticket clears its badge server-side).
class TicketListController extends GetxController {
  TicketListController({SupportRepository? supportRepo})
      : _supportRepo = supportRepo ?? SupportRepository();

  final SupportRepository _supportRepo;

  final RxList<SupportTicket> tickets = <SupportTicket>[].obs;
  final isLoading = true.obs;
  final isLoadingMore = false.obs;
  final RxnString loadError = RxnString();

  int _page = 1;
  bool _hasMore = true;
  static const int _perPage = 15;

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    loadError.value = null;
    _page = 1;
    _hasMore = true;
    try {
      final res = await _supportRepo.tickets(page: 1, perPage: _perPage);
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'ticket_list.load_failed'.trns();
        return;
      }
      tickets.assignAll(res.data!.items);
      _hasMore = res.data!.meta.hasNextPage;
      _page = 2;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isLoading.value) return;
    isLoadingMore.value = true;
    try {
      final res =
          await _supportRepo.tickets(page: _page, perPage: _perPage);
      if (!res.isError && res.data != null) {
        tickets.addAll(res.data!.items);
        _hasMore = res.data!.meta.hasNextPage;
        _page++;
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Silent refresh after returning from a thread (no shimmer flash).
  Future<void> refreshQuietly() async {
    try {
      final res = await _supportRepo.tickets(page: 1, perPage: _perPage);
      if (res.isError || res.data == null) return;
      tickets.assignAll(res.data!.items);
      _hasMore = res.data!.meta.hasNextPage;
      _page = 2;
    } catch (_) {}
  }

  Future<void> openTicket(SupportTicket ticket) async {
    if (ticket.reference.isEmpty) return;
    await Get.toNamed(Routes.TICKET_DETAILS,
        arguments: ticket.reference);
    refreshQuietly();
  }

  void goToSupport() {
    Get.toNamed(Routes.SUPPORT);
  }
}
