import 'package:flutter/material.dart';
import 'package:fmt/app/modules/ticketList/controllers/ticket_list_controller.dart';
import 'package:fmt/models/support_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';

/// Own support tickets newest-first with per-row unread dots, status pills
/// (server `status_label`), pull-to-refresh and pagination.
class TicketListView extends GetView<TicketListController> {
  const TicketListView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            CustomHeaderBar(
              title: 'ticket_list.title'.trns(),
              onMenu: () {},
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmer();
                }
                if (controller.loadError.value != null) {
                  return _buildError();
                }
                if (controller.tickets.isEmpty) {
                  return _buildEmpty();
                }
                return _buildList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: controller.loadTickets,
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >=
              n.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(
              R.w(20), R.h(16), R.w(20), R.h(32)),
          itemCount: controller.tickets.length +
              (controller.isLoadingMore.value ? 1 : 0),
          separatorBuilder: (_, _) => SizedBox(height: R.h(12)),
          itemBuilder: (context, index) {
            if (index >= controller.tickets.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return _TicketRow(
                ticket: controller.tickets[index]);
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return RefreshIndicator(
      onRefresh: controller.loadTickets,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: R.w(24)),
        child: Column(
          children: [
            SizedBox(height: R.h(80)),
            Icon(Icons.confirmation_number_outlined,
                size: R.sp(72), color: AppColors.primary),
            SizedBox(height: R.h(24)),
            Text(
              'ticket_list.empty_title'.trns(),
              style: TextStyle(
                fontSize: R.sp(20),
                fontWeight: FontWeight.w800,
                color: AppColors.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(12)),
            Text(
              'ticket_list.empty_message'.trns(),
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.darkGrey
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(32)),
            MainBtn(
              text: 'ticket_list.new_ticket'.trns(),
              color: AppColors.primary,
              borderRadius: 12,
              onPressed: controller.goToSupport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: R.sp(56), color: Colors.red.shade300),
            SizedBox(height: R.h(16)),
            Text(
              controller.loadError.value!,
              style: TextStyle(
                  fontSize: R.sp(14),
                  color: AppColors.darkGrey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: R.h(20)),
            MainBtn(
              text: 'common.retry'.trns(),
              color: AppColors.primary,
              borderRadius: 12,
              onPressed: controller.loadTickets,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding:
          EdgeInsets.fromLTRB(R.w(20), R.h(16), R.w(20), R.h(32)),
      itemCount: 6,
      separatorBuilder: (_, _) => SizedBox(height: R.h(12)),
      itemBuilder: (_, _) => Container(
        height: R.h(96),
        decoration: BoxDecoration(
          color: AppColors.darkGrey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _TicketRow extends GetView<TicketListController> {
  const _TicketRow({required this.ticket});

  final SupportTicket ticket;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.openTicket(ticket),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: EdgeInsets.all(R.w(14)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (ticket.unreadCount > 0)
              Container(
                width: R.w(10),
                height: R.w(10),
                margin: EdgeInsets.only(right: R.w(10)),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ticket.subject.isNotEmpty
                              ? ticket.subject
                              : ticket.reference,
                          style: TextStyle(
                            fontSize: R.sp(15),
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGrey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: R.w(8)),
                      _StatusPill(status: ticket),
                    ],
                  ),
                  SizedBox(height: R.h(6)),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ticket.reference,
                          style: TextStyle(
                            fontSize: R.sp(12),
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      if (ticket.category.isNotEmpty)
                        Flexible(
                          child: Text(
                            ticket.category,
                            style: TextStyle(
                              fontSize: R.sp(12),
                              color: AppColors.darkGrey
                                  .withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.darkGrey
                    .withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SupportTicket status;

  Color get _color {
    switch (status.status) {
      case 'open':
        return Colors.amber.shade800;
      case 'in_progress':
        return Colors.blue.shade700;
      case 'resolved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: R.w(10), vertical: R.h(4)),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.displayStatus,
        style: TextStyle(
          fontSize: R.sp(11),
          fontWeight: FontWeight.w700,
          color: _color,
        ),
      ),
    );
  }
}
