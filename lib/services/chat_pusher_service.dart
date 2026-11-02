import 'dart:async';
import 'dart:convert';

import 'package:fmt/models/chat_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import 'pusher_manager.dart';

/// Live store-chat feed on top of [PusherManager].
///
/// The API delivers `message.sent` with the full message object and
/// `messages.read` with `{conversation_id, user_id, read_by_admin,
/// read_at}` to flip sent ticks. Neither event reaches the client that
/// caused it, so the controller still shows its own sends optimistically.
class ChatPusherService extends GetxService {
  static ChatPusherService get instance =>
      Get.isRegistered<ChatPusherService>()
          ? Get.find<ChatPusherService>()
          : Get.put(ChatPusherService());

  final PusherManager _pusher = PusherManager.instance;

  final Map<int, StreamController<ChatMessage>> _messageStreams = {};
  final Map<int, StreamController<ChatReadReceipt>> _readStreams = {};
  final Map<String, void Function(PusherEvent)> _eventHandlers = {};

  /// Ask the backend for PUSHER_APP_KEY (public client key) and call this
  /// once per session when it is known. Until then chat runs on polling.
  Future<bool> initRealtime({required String appKey}) {
    return _pusher.init(appKey: appKey);
  }

  bool get isReady => _pusher.isReady;

  /// Subscribe to `private-conversation.{id}`. The returned streams stay
  /// open across calls; call [unsubscribe] when the chat screen closes.
  ({Stream<ChatMessage> messages, Stream<ChatReadReceipt> reads}) subscribe(
      int conversationId) {
    final channel = 'private-conversation.$conversationId';
    _messageStreams.putIfAbsent(
        conversationId, () => StreamController<ChatMessage>.broadcast());
    _readStreams.putIfAbsent(
        conversationId, () => StreamController<ChatReadReceipt>.broadcast());
    if (!_eventHandlers.containsKey(channel)) {
      void handler(PusherEvent event) {
        _route(conversationId, event);
      }

      _eventHandlers[channel] = handler;
      unawaited(_pusher.subscribe(channelName: channel, onEvent: handler));
    }
    return (
      messages: _messageStreams[conversationId]!.stream,
      reads: _readStreams[conversationId]!.stream,
    );
  }

  Future<void> unsubscribe(int conversationId) async {
    final channel = 'private-conversation.$conversationId';
    final handler = _eventHandlers.remove(channel);
    await _pusher.unsubscribe(channelName: channel, onEvent: handler);
  }

  void _route(int conversationId, PusherEvent event) {
    try {
      if (event.eventName == 'message.sent') {
        final raw = _decode(event.data);
        if (raw['id'] != null) {
          _messageStreams[conversationId]
              ?.add(ChatMessage.fromJson(raw));
        }
      } else if (event.eventName == 'messages.read') {
        final raw = _decode(event.data);
        _readStreams[conversationId]?.add(ChatReadReceipt.fromJson(raw));
      }
    } catch (e) {
      if (kDebugMode) print('[ChatPusherService] route error: $e');
    }
  }

  /// Pusher data arrives as a JSON string, sometimes double-encoded.
  static Map<String, dynamic> _decode(String data) {
    var decoded = data;
    while (decoded.startsWith('"') && decoded.endsWith('"')) {
      decoded =
          decoded.substring(1, decoded.length - 1).replaceAll('\\"', '"');
    }
    dynamic json;
    try {
      json = jsonDecode(decoded);
    } catch (_) {
      return <String, dynamic>{};
    }
    if (json is Map) return Map<String, dynamic>.from(json);
    return <String, dynamic>{};
  }

  @override
  void onClose() {
    for (final s in _messageStreams.values) {
      s.close();
    }
    for (final s in _readStreams.values) {
      s.close();
    }
    _messageStreams.clear();
    _readStreams.clear();
    super.onClose();
  }
}

/// `messages.read` payload — marks this customer's messages read.
class ChatReadReceipt {
  ChatReadReceipt({
    this.conversationId,
    this.userId,
    this.readByAdmin = false,
    this.readAt,
  });

  final dynamic conversationId;
  final dynamic userId;
  final bool readByAdmin;
  final String? readAt;

  factory ChatReadReceipt.fromJson(Map<String, dynamic> json) {
    final raw = json['read_by_admin'];
    return ChatReadReceipt(
      conversationId: json['conversation_id'],
      userId: json['user_id'],
      readByAdmin:
          raw is bool ? raw : ('$raw'.toLowerCase() == 'true' || '$raw' == '1'),
      readAt: json['read_at']?.toString(),
    );
  }
}
