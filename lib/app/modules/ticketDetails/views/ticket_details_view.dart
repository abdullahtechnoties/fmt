import 'package:flutter/material.dart';
import 'package:fmt/app/modules/ticketDetails/controllers/ticket_details_controller.dart';
import 'package:fmt/models/support_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/main_btn.dart';
import 'package:fmt/widgets/shared_ui.dart';
import 'package:get/get.dart';

/// Ticket thread: header card (reference/subject/status), the opening
/// message plus staff/customer replies, a reopen warning on finished
/// tickets, and a reply composer. Tickets are text-only — a link points
/// at chat for screenshots and voice notes.
class TicketDetailsView extends GetView<TicketDetailsController> {
  const TicketDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: SafeArea(
        child: Column(
          children: [
            Obx(() => CustomHeaderBar(
              showmenu: false,
                  title: controller.ticket.value?.reference
                          .isNotEmpty ==
                      true
                      ? controller.ticket.value!.reference
                      : 'ticket_details.title'.trns(),
                  onMenu: () {},
                )),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmer();
                }
                if (controller.loadError.value != null ||
                    controller.ticket.value == null) {
                  return _buildError();
                }
                return _buildThread(controller.ticket.value!);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThread(SupportTicket ticket) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: controller.loadTicket,
            child: SingleChildScrollView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: EdgeInsets.fromLTRB(
                  R.w(20), R.h(16), R.w(20), R.h(16)),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(ticket: ticket),
                  SizedBox(height: R.h(16)),
                  _MessageBubble(
                    author: 'ticket_details.you'.trns(),
                    body: ticket.message,
                    isMe: true,
                    time: ticket.createdAt,
                  ),
                  ...ticket.replies.map((r) =>
                      _MessageBubble(
                        author: r.author.isNotEmpty
                            ? r.author
                            : (r.isStaff
                                ? 'ticket_details.staff'
                                    .trns()
                                : 'ticket_details.you'
                                    .trns()),
                        body: r.body,
                        isMe: !r.isStaff,
                        time: r.createdAt,
                      )),
                  SizedBox(height: R.h(8)),
                  _buildChatNudge(),
                ],
              ),
            ),
          ),
        ),
        _buildComposer(ticket),
      ],
    );
  }

  /// Reopen warning on finished tickets + reply composer.
  Widget _buildComposer(SupportTicket ticket) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          R.w(20), R.h(10), R.w(20), R.h(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            if (ticket.isFinished)
              Container(
                margin: EdgeInsets.only(bottom: R.h(10)),
                padding: EdgeInsets.all(R.w(10)),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: R.sp(18),
                        color: Colors.amber.shade800),
                    SizedBox(width: R.w(8)),
                    Expanded(
                      child: Text(
                        'ticket_details.reopen_notice'
                            .trnsFormat({
                          'status':
                              ticket.displayStatus
                        }),
                        style: TextStyle(
                          fontSize: R.sp(12),
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:
                        controller.replyController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction:
                        TextInputAction.send,
                    onSubmitted: (_) =>
                        controller.sendReply(),
                    decoration: InputDecoration(
                      hintText:
                          'ticket_details.reply_hint'
                              .trns(),
                      contentPadding:
                          EdgeInsets.symmetric(
                              horizontal: R.w(14),
                              vertical: R.h(12)),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: R.w(10)),
                Obx(() => IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(
                            R.w(48), R.h(48)),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  12),
                        ),
                      ),
                      onPressed: controller
                              .isReplying.value
                          ? null
                          : controller.sendReply,
                      icon: controller
                              .isReplying.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatNudge() {
    return InkWell(
      onTap: controller.openChat,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.all(R.w(10)),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.chat_outlined,
                size: R.sp(18),
                color: AppColors.primary),
            SizedBox(width: R.w(8)),
            Expanded(
              child: Text(
                'ticket_details.attach_note'.trns(),
                style: TextStyle(
                  fontSize: R.sp(12),
                  color: AppColors.darkGrey,
                ),
              ),
            ),
            Icon(Icons.chevron_right,
                size: R.sp(18),
                color: AppColors.primary),
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
              controller.loadError.value ??
                  'ticket_details.load_failed'.trns(),
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
              onPressed: controller.loadTicket,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding:
          EdgeInsets.fromLTRB(R.w(20), R.h(16), R.w(20), R.h(32)),
      child: Column(
        children: List.generate(
          5,
          (_) => Container(
            height: R.h(88),
            margin: EdgeInsets.only(bottom: R.h(12)),
            decoration: BoxDecoration(
              color: AppColors.darkGrey
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.ticket});

  final SupportTicket ticket;

  Color get _color {
    switch (ticket.status) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.reference,
                  style: TextStyle(
                    fontSize: R.sp(13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: R.w(10),
                    vertical: R.h(4)),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(999),
                ),
                child: Text(
                  ticket.displayStatus,
                  style: TextStyle(
                    fontSize: R.sp(11),
                    fontWeight: FontWeight.w700,
                    color: _color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: R.h(8)),
          Text(
            ticket.subject,
            style: TextStyle(
              fontSize: R.sp(16),
              fontWeight: FontWeight.w800,
              color: AppColors.darkGrey,
            ),
          ),
          if (ticket.category.isNotEmpty) ...[
            SizedBox(height: R.h(4)),
            Text(
              ticket.category,
              style: TextStyle(
                fontSize: R.sp(12),
                color: AppColors.darkGrey
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.author,
    required this.body,
    required this.isMe,
    required this.time,
  });

  final String author;
  final String body;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(10)),
        padding: EdgeInsets.all(R.w(12)),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isMe
              ? null
              : [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: TextStyle(
                fontSize: R.sp(11),
                fontWeight: FontWeight.w700,
                color: isMe
                    ? AppColors.primary
                    : AppColors.darkGrey
                        .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: R.h(4)),
            Text(
              body,
              style: TextStyle(
                fontSize: R.sp(14),
                color: AppColors.darkGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
