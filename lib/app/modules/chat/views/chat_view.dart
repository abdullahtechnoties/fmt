import 'package:flutter/material.dart';
import 'package:fmt/utilities/responsive/responsive_util.dart';
import 'package:get/get.dart';
import 'package:fmt/utilities/colors.dart';
import 'package:fmt/utilities/translation_extention.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(R.h(70)),
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: AppColors.white,
              size: R.sp(24),
            ),
            onPressed: () => Get.back(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: R.h(20),
                    backgroundImage: NetworkImage(
                      controller.chatUserImage.value,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: R.w(12),
                      height: R.w(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8FC642), // Online green dot
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: R.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.chatUser.value,
                    style: TextStyle(
                      fontSize: R.sp(16),
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  Text(
                    'chat.active_now'.trns(),
                    style: TextStyle(
                      fontSize: R.sp(12),
                      fontWeight: FontWeight.w400,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: R.w(20),
                  vertical: R.h(20),
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];

                  Widget content;
                  if (msg['type'] == 'audio') {
                    content = _buildAudioBubble(msg);
                  } else {
                    content = _buildTextBubble(msg);
                  }

                  return Column(
                    children: [
                      if (msg['showDivider'] == true) ...[
                        SizedBox(height: R.h(16)),
                        Text(
                          'chat.just_now'.trns(),
                          style: TextStyle(
                            fontSize: R.sp(14),
                            fontWeight: FontWeight.w700,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: R.h(16)),
                      ],
                      content,
                    ],
                  );
                },
              ),
            ),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  Widget _buildTextBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'] as bool;
    return Padding(
      padding: EdgeInsets.only(bottom: R.h(16)),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildTimeText(),
          if (!isMe) SizedBox(width: R.w(8)),

          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: R.w(16),
                vertical: R.h(14),
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : const Color(0xFFF3F3F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(R.w(12)),
                  topRight: Radius.circular(R.w(12)),
                  bottomLeft: Radius.circular(isMe ? R.w(12) : 0),
                  bottomRight: Radius.circular(isMe ? 0 : R.w(12)),
                ),
              ),
              child: Text(
                msg['text'],
                style: TextStyle(
                  fontSize: R.sp(14),
                  color: isMe ? AppColors.white : AppColors.mediumGrey,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioBubble(Map<String, dynamic> msg) {
    final bool isMe = msg['isMe'] as bool;

    // Note: Assuming Outgoing audio only based on screenshot
    return Padding(
      padding: EdgeInsets.only(
        bottom: R.h(4),
      ), // Audio has subtext underneath in design
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Container(
                  height: R.h(60),
                  padding: EdgeInsets.symmetric(horizontal: R.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(R.w(12)),
                      topRight: Radius.circular(R.w(12)),
                      bottomLeft: Radius.circular(R.w(12)),
                      bottomRight: const Radius.circular(0),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Fake Waveform
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(25, (index) {
                            return Container(
                              width: R.w(3),
                              height: R.h(
                                10 + (index % 4) * 8,
                              ), // Randomish heights
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            );
                          }),
                        ),
                      ),
                      SizedBox(width: R.w(12)),
                      // Play/Pause button
                      CircleAvatar(
                        radius: R.h(16),
                        backgroundColor: AppColors.white,
                        child: Icon(
                          Icons.pause,
                          color: AppColors.primary,
                          size: R.sp(18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isMe) ...[SizedBox(width: R.w(8)), _buildTimeText()],
            ],
          ),
          SizedBox(height: R.h(6)),
          Text(
            "Quiche has been listening your voice",
            style: TextStyle(fontSize: R.sp(12), color: AppColors.lightGrey),
          ),
          SizedBox(height: R.h(16)),
        ],
      ),
    );
  }

  Widget _buildTimeText() {
    return CircleAvatar(
      radius: R.h(18),
      backgroundImage: NetworkImage(controller.chatUserImage.value),
    );
  }

  Widget _buildBottomInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: R.w(20), vertical: R.h(16)),
      decoration: BoxDecoration(color: AppColors.scaffoldBg),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: R.w(16)),
        height: R.h(56),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(R.w(30)),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // TODO: Replace with SVG paperclip
            Icon(
              Icons.attach_file,
              color: AppColors.mediumGrey,
              size: R.sp(22),
            ),
            SizedBox(width: R.w(12)),
            Expanded(
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: 'chat.type_message'.trns(),
                  hintStyle: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: R.sp(14),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            Container(height: R.h(24), width: 1, color: AppColors.inputBorder),
            SizedBox(width: R.w(12)),
            // TODO: Replace with SVG Mic
            Icon(Icons.mic_none, color: AppColors.primary, size: R.sp(24)),
            SizedBox(width: R.w(12)),
            // TODO: Replace with SVG Send Plane
            GestureDetector(
              onTap: controller.sendMessage,
              child: Icon(Icons.send, color: AppColors.primary, size: R.sp(22)),
            ),
          ],
        ),
      ),
    );
  }
}
