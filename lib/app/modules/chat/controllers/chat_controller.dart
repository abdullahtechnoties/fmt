import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final messageController = TextEditingController();
  final chatUser = 'Quiche Hollandaise'.obs;
  final chatUserImage = 'https://i.pravatar.cc/150?img=11'.obs;
  
  // Dummy Chat Data
  final messages = [
    {
      'type': 'text',
      'text': 'Sed ligula erat, dignissim sit amet dictum id?',
      'time': '01:15 PM',
      'isMe': false,
      'showDivider': false,
    },
    {
      'type': 'text',
      'text': 'Sed ligula erat,mauris sit eros a viverra amet dictum id?',
      'time': '01:15 PM',
      'isMe': true,
      'showDivider': false,
    },
    {
      'type': 'audio',
      'duration': '0:12',
      'time': '01:18 PM',
      'isMe': true,
      'showDivider': false,
    },
    {
      'type': 'text',
      'text': 'Sed ligula erat, dignissim sit amet dictum id?',
      'time': '01:15 PM', // Adjusted time based on design
      'isMe': false,
      'showDivider': true, // Triggers "Just Now" divider
    },
    {
      'type': 'text',
      'text': 'Sed ligula erat,mauris sit eros a viverra amet dictum id?',
      'time': '01:15 PM',
      'isMe': true,
      'showDivider': false,
    },
  ].obs;

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;
    
    messages.add({
      'type': 'text',
      'text': messageController.text.trim(),
      'time': 'Just Now',
      'isMe': true,
      'showDivider': false,
    });
    messageController.clear();
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}