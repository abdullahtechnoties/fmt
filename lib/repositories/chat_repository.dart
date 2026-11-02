import 'dart:io';

import 'package:fmt/models/chat_model.dart';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Store chat API (auth only, one thread per customer).
///
/// send() posts `multipart/form-data` — at least one of body,
/// attachments[] or voice_note is required (empty send = 422).
class ChatRepository {
  ChatRepository({NetworkService? network})
      : _network = network ?? Get.find();

  final NetworkService _network;

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// `GET /chat` — conversation + newest 30 messages (oldest-first).
  /// Pass [beforeId] to page further back. The first call (no before_id)
  /// also marks the store's messages as read.
  Future<ApiResponse<ChatThread>> thread({dynamic beforeId}) async {
    final res = await _network.get(
      endpoint: ApiPath.chat,
      queryParams:
          beforeId != null ? {'before_id': '$beforeId'} : null,
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    return ApiResponse.completed(ChatThread.fromBody(res.data),
        message: res.message);
  }

  /// `GET /chat/messages?after_id=` — everything newer, oldest first.
  Future<ApiResponse<ChatPollResult>> poll({required dynamic afterId}) async {
    final res = await _network.get(
      endpoint: ApiPath.chatMessages,
      queryParams: {'after_id': '$afterId'},
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '');
    }
    return ApiResponse.completed(ChatPollResult.fromBody(res.data),
        message: res.message);
  }

  /// `POST /chat/read` — marks the store's messages read, clears the badge.
  Future<void> markRead() async {
    try {
      await _network.post(endpoint: ApiPath.chatRead);
    } catch (_) {}
  }

  /// `GET /chat/unread` — cheap badge check for app resume.
  Future<int> unreadCount() async {
    try {
      final res = await _network.get(endpoint: ApiPath.chatUnread);
      final data = _map(res.data?['data']);
      final raw = data['unread_count'];
      if (raw is num) return raw.toInt();
      return int.tryParse('$raw') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// `POST /chat/messages` — 201 returns the created message.
  Future<ApiResponse<ChatMessage>> send({
    String? body,
    List<File>? attachments,
    File? voiceNote,
    double? voiceDuration,
  }) async {
    final trimmed = (body ?? '').trim();
    final fields = <String, dynamic>{};
    if (trimmed.isNotEmpty) fields['body'] = trimmed;
    if (voiceDuration != null && voiceDuration > 0) {
      fields['voice_duration'] = voiceDuration.toStringAsFixed(1);
    }
    final res = await _network.postForm(
      endpoint: ApiPath.chatMessages,
      fields: fields,
      multiFiles: attachments != null && attachments.isNotEmpty
          ? {
              'attachments[]': attachments,
            }
          : null,
      files: voiceNote != null ? {'voice_note': voiceNote} : null,
    );
    if (res.isError || res.data == null) {
      return ApiResponse.error(res.message ?? '', errors: res.errors);
    }
    final data = _map(res.data!['data']);
    // 201 shape: the message object itself, sometimes nested under `message`.
    final raw = data['message'] is Map ? _map(data['message']) : data;
    if (raw['id'] == null) {
      return ApiResponse.error(res.message ?? '');
    }
    return ApiResponse.completed(ChatMessage.fromJson(raw),
        message: res.message);
  }
}
