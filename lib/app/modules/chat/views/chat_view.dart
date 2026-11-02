import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fmt/app/modules/chat/controllers/chat_controller.dart';
import 'package:fmt/models/chat_model.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:fmt/utilities/translation_extention.dart';
import 'package:fmt/widgets/app_cached_image.dart';
import 'package:fmt/widgets/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

/// Live store-chat thread. Newest message at the bottom; older history
/// pages in at the top. Own bubbles carry send ticks (sending → sent →
/// read); failed sends show a retry affordance. Attachments, voice notes
/// and the composer live here; realtime arrives via Pusher with polling
/// as the safety net while it connects.
class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(R.h(70)),
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back,
                color: AppColors.white, size: R.sp(24)),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              CircleAvatar(
                radius: R.h(20),
                backgroundColor: AppColors.white.withValues(alpha: 0.2),
                child: Icon(Icons.storefront,
                    color: AppColors.white, size: R.sp(20)),
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'chat.store_title'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Obx(() => Text(
                        controller.isRecording.value
                            ? 'chat.recording'.trns()
                            : 'chat.active_now'.trns(),
                        style: TextStyle(
                          fontSize: R.sp(12),
                          fontWeight: FontWeight.w400,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const _ChatShimmer();
              }
              if (controller.loadError.value != null &&
                  controller.messages.isEmpty) {
                return _ErrorState(
                  message: controller.loadError.value!,
                  onRetry: controller.loadThread,
                );
              }
              if (controller.messages.isEmpty) {
                return _EmptyState(onRetry: controller.loadThread);
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (n) {
                  // Reversed list: maxScrollExtent is the top (older).
                  if (n.metrics.pixels >=
                          n.metrics.maxScrollExtent - 200 &&
                      controller.hasMore.value &&
                      !controller.isLoadingOlder.value) {
                    controller.loadOlder();
                  }
                  return false;
                },
                child: ListView.builder(
                  controller: controller.scrollController,
                  reverse: true,
                  padding: EdgeInsets.symmetric(
                      horizontal: R.w(16), vertical: R.h(16)),
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.messages.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (controller.hasMore.value &&
                        index == controller.messages.length) {
                      return const _OlderLoader();
                    }
                    final msg = controller.messages[index];
                    return Obx(() {
                      final highlighted =
                          controller.highlightId.value != null &&
                              '${msg.id}' ==
                                  controller.highlightId.value;
                      return Container(
                        decoration: highlighted
                            ? BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.08),
                                borderRadius:
                                    BorderRadius.circular(R.w(12)),
                              )
                            : null,
                        child: _MessageBubble(message: msg),
                      );
                    });
                  },
                ),
              );
            }),
          ),
          Obx(() => controller.isRecording.value
              ? _RecordingBar()
              : _ComposerBar()),
        ],
      ),
    );
  }
}

// ─── Bubbles ─────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final failed = message.sendState == ChatSendState.failed;
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(12)),
      child: GestureDetector(
        // Failed optimistic sends retry on tap.
        onTap: failed
            ? () => Get.find<ChatController>().retrySend(message)
            : null,
        behavior: HitTestBehavior.opaque,
        child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              constraints:
                  BoxConstraints(maxWidth: R.w(290)),
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(14), vertical: R.h(10)),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.w(14)),
                  topRight: Radius.circular(R.w(14)),
                  bottomLeft: Radius.circular(isMe ? R.w(14) : R.w(4)),
                  bottomRight: Radius.circular(isMe ? R.w(4) : R.w(14)),
                ),
                border: isMe
                    ? null
                    : Border.all(color: AppColors.cardBorder),
                boxShadow: isMe
                    ? [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.06),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.voiceNote != null ||
                      _isLocalVoice(message))
                    _VoiceBubble(message: message, isMe: isMe),
                  for (final a in message.attachments)
                    _AttachmentBubble(attachment: a, isMe: isMe),
                  if (message.localPath != null &&
                      message.voiceNote == null &&
                      message.attachments.isEmpty)
                    _LocalImagePreview(
                        path: message.localPath!, isMe: isMe),
                  if (message.hasText)
                    Padding(
                      padding: EdgeInsets.only(
                          top: _hasMedia(message) ? R.h(6) : 0),
                      child: Text(
                        message.body!,
                        style: TextStyle(
                          fontSize: R.sp(14),
                          height: 1.4,
                          color: isMe
                              ? AppColors.white
                              : AppColors.darkGrey,
                        ),
                      ),
                    ),
                  SizedBox(height: R.h(4)),
                  _MetaRow(message: message, isMe: isMe),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  bool _isLocalVoice(ChatMessage m) =>
      m.localPath != null &&
      m.voiceNote == null &&
      (m.localPath!.endsWith('.m4a') || m.localPath!.endsWith('.mp3'));

  bool _hasMedia(ChatMessage m) =>
      m.voiceNote != null ||
      m.attachments.isNotEmpty ||
      m.localPath != null;
}

/// Time + send ticks under every bubble.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final subColor =
        isMe ? AppColors.white.withValues(alpha: 0.85) : AppColors.grey;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.timeLabel.isNotEmpty)
          Text(
            message.timeLabel,
            style: TextStyle(fontSize: R.sp(11), color: subColor),
          ),
        if (isMe) ...[
          SizedBox(width: R.w(4)),
          _Tick(state: message.sendState, isRead: message.isRead),
        ],
      ],
    );
  }
}

/// sending = clock, sent = single tick, read = double tick,
/// failed = error (whole bubble retries on tap).
class _Tick extends StatelessWidget {
  const _Tick({required this.state, required this.isRead});

  final ChatSendState state;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final white = AppColors.white.withValues(alpha: 0.9);
    switch (state) {
      case ChatSendState.sending:
        return SizedBox(
          width: R.sp(12),
          height: R.sp(12),
          child: CircularProgressIndicator(
              color: white, strokeWidth: 1.6),
        );
      case ChatSendState.failed:
        return Icon(Icons.error_outline,
            size: R.sp(14), color: Colors.red.shade200);
      case ChatSendState.sent:
        return Icon(
          isRead ? Icons.done_all : Icons.done,
          size: R.sp(14),
          color: isRead ? const Color(0xFF7DD8FF) : white,
        );
    }
  }
}

class _AttachmentBubble extends StatelessWidget {
  const _AttachmentBubble({required this.attachment, required this.isMe});

  final ChatAttachment attachment;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    if (attachment.isImage &&
        (attachment.url ?? '').isNotEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: R.h(4)),
        child: GestureDetector(
          onTap: () => _openFullImage(context, attachment.url!),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(R.w(10)),
            child: AppCachedImage(
              imageUrl: attachment.url!,
              width: R.w(200),
              height: R.w(150),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    final labelColor =
        isMe ? AppColors.white : AppColors.darkGrey;
    return GestureDetector(
      onTap: () => _openFile(attachment.url),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: R.h(4)),
        padding: EdgeInsets.symmetric(
            horizontal: R.w(10), vertical: R.h(8)),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.white.withValues(alpha: 0.15)
              : AppColors.scaffoldBg,
          borderRadius: BorderRadius.circular(R.w(10)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insert_drive_file_outlined,
                size: R.sp(22), color: labelColor),
            SizedBox(width: R.w(8)),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attachment.name ?? 'chat.file'.trns(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: R.sp(13),
                      fontWeight: FontWeight.w600,
                      color: labelColor,
                    ),
                  ),
                  if (attachment.size > 0)
                    Text(
                      _formatBytes(attachment.size),
                      style: TextStyle(
                        fontSize: R.sp(11),
                        color: isMe
                            ? AppColors.white
                                .withValues(alpha: 0.8)
                            : AppColors.grey,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  static void _openFullImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(R.w(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(R.w(12)),
              child: AppCachedImage(
                imageUrl: url,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: R.h(12)),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(R.w(10)),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close,
                    color: AppColors.white, size: R.sp(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openFile(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _LocalImagePreview extends StatelessWidget {
  const _LocalImagePreview({required this.path, required this.isMe});

  final String path;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(4)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(R.w(10)),
        child: Image.file(
          File(path),
          width: R.w(200),
          height: R.w(150),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: R.w(200),
            height: R.w(90),
            color: (isMe ? AppColors.white : AppColors.darkGrey)
                .withValues(alpha: 0.12),
            alignment: Alignment.center,
            child: Icon(Icons.image_outlined,
                size: R.sp(28),
                color: isMe ? AppColors.white : AppColors.grey),
          ),
        ),
      ),
    );
  }
}

/// Voice player row: play/pause + progress bar + duration.
class _VoiceBubble extends StatelessWidget {
  const _VoiceBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final key =
        message.voiceNote?.url ?? message.localPath ?? message.key;
    final accent = isMe ? AppColors.white : AppColors.primary;
    final track =
        isMe ? AppColors.white.withValues(alpha: 0.35) : AppColors.inputBorder;
    return Obx(() {
      final active = controller.playingVoiceKey.value == key;
      final playing = active && controller.isPlaying.value;
      final duration = active && controller.playDuration.value > 0
          ? controller.playDuration.value
          : (message.voiceNote?.duration ?? 0);
      final position =
          active ? controller.playPosition.value : 0.0;
      final progress =
          duration > 0 ? (position / duration).clamp(0.0, 1.0) : 0.0;
      final label = active && duration > 0
          ? _fmt(position)
          : (message.voiceNote?.durationLabel ??
              _fmt(duration));
      return GestureDetector(
        onTap: () => controller.toggleVoice(message),
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: R.w(190),
          padding: EdgeInsets.symmetric(vertical: R.h(2)),
          child: Row(
            children: [
              Container(
                width: R.w(36),
                height: R.w(36),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isMe ? 0.22 : 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: accent,
                  size: R.sp(20),
                ),
              ),
              SizedBox(width: R.w(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(R.w(4)),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: R.h(4),
                        backgroundColor: track,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(accent),
                      ),
                    ),
                    SizedBox(height: R.h(4)),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: R.sp(11),
                        color: isMe
                            ? AppColors.white
                                .withValues(alpha: 0.85)
                            : AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static String _fmt(double seconds) {
    final total = seconds.round();
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }
}

// ─── Composer ────────────────────────────────────────────────────────────────

class _ComposerBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    return Container(
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(10), R.w(16), R.h(16)),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _showAttachSheet(context, controller),
            child: Icon(Icons.attach_file,
                color: AppColors.mediumGrey, size: R.sp(24)),
          ),
          SizedBox(width: R.w(8)),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: R.w(14)),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(R.w(24)),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: controller.composer,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'chat.type_message'.trns(),
                  hintStyle: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: R.sp(14),
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => controller.sendText(),
              ),
            ),
          ),
          SizedBox(width: R.w(8)),
          GestureDetector(
            onTap: controller.toggleRecording,
            child: Icon(Icons.mic_none,
                color: AppColors.primary, size: R.sp(26)),
          ),
          SizedBox(width: R.w(8)),
          Obx(() => GestureDetector(
                onTap: controller.hasComposerText.value
                    ? controller.sendText
                    : null,
                child: Container(
                  width: R.w(44),
                  height: R.w(44),
                  decoration: BoxDecoration(
                    color: controller.hasComposerText.value
                        ? AppColors.primary
                        : AppColors.lightGrey.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send,
                      color: AppColors.white, size: R.sp(20)),
                ),
              )),
        ],
      ),
    );
  }

  void _showAttachSheet(
      BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(R.w(20))),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: R.h(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetItem(
                icon: Icons.photo_camera_outlined,
                label: 'chat.take_photo'.trns(),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              _sheetItem(
                icon: Icons.photo_library_outlined,
                label: 'chat.choose_photo'.trns(),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              _sheetItem(
                icon: Icons.insert_drive_file_outlined,
                label: 'chat.choose_file'.trns(),
                onTap: () {
                  Get.back();
                  controller.pickFiles();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetItem(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: R.sp(24)),
      title: Text(
        label,
        style: TextStyle(
          fontSize: R.sp(15),
          fontWeight: FontWeight.w600,
          color: AppColors.darkGrey,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Recording state replaces the composer: timer + cancel + stop/send.
class _RecordingBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    return Container(
      padding: EdgeInsets.fromLTRB(R.w(16), R.h(10), R.w(16), R.h(16)),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBg,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: controller.cancelRecording,
            child: Icon(Icons.delete_outline,
                color: AppColors.red, size: R.sp(26)),
          ),
          SizedBox(width: R.w(12)),
          Container(
            width: R.w(10),
            height: R.w(10),
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: R.w(8)),
          Obx(() => Text(
                _fmt(controller.recordingSeconds.value),
                style: TextStyle(
                  fontSize: R.sp(16),
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGrey,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )),
          SizedBox(width: R.w(8)),
          Expanded(
            child: Text(
              'chat.recording_hint'.trns(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  TextStyle(fontSize: R.sp(13), color: AppColors.grey),
            ),
          ),
          GestureDetector(
            onTap: controller.toggleRecording,
            child: Container(
              width: R.w(44),
              height: R.w(44),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send,
                  color: AppColors.white, size: R.sp(20)),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(int total) =>
      '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
}

// ─── States ──────────────────────────────────────────────────────────────────

class _OlderLoader extends StatelessWidget {
  const _OlderLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: R.h(8)),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
              color: AppColors.primary, strokeWidth: 2),
        ),
      ),
    );
  }
}

class _ChatShimmer extends StatelessWidget {
  const _ChatShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(R.w(16)),
      itemCount: 6,
      itemBuilder: (context, i) {
        final isMe = i.isEven;
        return Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            ShimmerBox(
              width: R.w(200 + (i % 3) * 20),
              height: R.h(56),
              borderRadius: 14,
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.w(84),
              height: R.w(84),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: R.sp(38),
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: R.h(16)),
            Text(
              'chat.empty_title'.trns(),
              style: TextStyle(
                fontSize: R.sp(18),
                fontWeight: FontWeight.w700,
                color: AppColors.darkGrey,
              ),
            ),
            SizedBox(height: R.h(8)),
            Text(
              'chat.empty_message'.trns(),
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: R.sp(14), color: AppColors.mediumGrey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined,
              size: R.sp(48), color: AppColors.lightGrey),
          SizedBox(height: R.h(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: R.w(48)),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: R.sp(14), color: AppColors.mediumGrey),
            ),
          ),
          SizedBox(height: R.h(16)),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(R.w(10)),
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: R.w(24), vertical: R.h(12)),
            ),
            child: Text(
              'common.retry'.trns(),
              style: TextStyle(
                color: AppColors.white,
                fontSize: R.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
