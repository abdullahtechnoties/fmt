// In-app store chat models (`GET /chat`, `POST /chat/messages`).
//
// One thread per customer: `is_admin=false` is always this customer,
// `is_admin=true` is always the store. `sendState` is UI-only — server
// messages are always [ChatSendState.sent].

enum ChatSendState { sending, sent, failed }

class ChatAttachment {
  ChatAttachment({
    this.id,
    this.name,
    this.url,
    this.size = 0,
    this.mime,
  });

  final dynamic id;
  final String? name;
  final String? url;
  final int size;
  final String? mime;

  bool get isImage => (mime ?? '').toLowerCase().startsWith('image/');

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      name: json['name']?.toString(),
      url: json['url']?.toString(),
      size: json['size'] is num
          ? (json['size'] as num).toInt()
          : int.tryParse('${json['size']}') ?? 0,
      mime: json['mime']?.toString(),
    );
  }
}

class ChatVoiceNote {
  ChatVoiceNote({
    this.id,
    this.url,
    this.duration = 0,
    this.mime,
  });

  final dynamic id;
  final String? url;
  final double duration;
  final String? mime;

  String get durationLabel {
    final total = duration.round();
    return '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}';
  }

  factory ChatVoiceNote.fromJson(Map<String, dynamic> json) {
    final raw = json['duration'];
    return ChatVoiceNote(
      id: json['id'],
      url: json['url']?.toString(),
      duration: raw is num ? raw.toDouble() : double.tryParse('$raw') ?? 0,
      mime: json['mime']?.toString(),
    );
  }
}

class ChatMessage {
  ChatMessage({
    this.id,
    this.tempId,
    this.conversationId,
    this.userId,
    this.isAdmin = false,
    this.body,
    this.readAt,
    this.createdAt,
    this.senderName,
    this.attachments = const [],
    this.voiceNote,
    this.localPath,
    this.sendState = ChatSendState.sent,
  });

  final dynamic id;
  final String? tempId;
  final dynamic conversationId;
  final dynamic userId;

  /// false = this customer, true = the store.
  final bool isAdmin;
  final String? body;
  final String? readAt;
  final DateTime? createdAt;
  final String? senderName;
  final List<ChatAttachment> attachments;
  final ChatVoiceNote? voiceNote;

  /// Local preview path for optimistic media/voice bubbles.
  final String? localPath;
  final ChatSendState sendState;

  bool get isMe => !isAdmin;
  bool get isRead => (readAt ?? '').isNotEmpty;
  bool get hasText => (body ?? '').trim().isNotEmpty;
  String get key => '${id ?? tempId}';

  String get timeLabel {
    final dt = createdAt?.toLocal();
    if (dt == null) return '';
    final now = DateTime.now();
    final sameDay =
        now.year == dt.year && now.month == dt.month && now.day == dt.day;
    final h = dt.hour > 12
        ? dt.hour - 12
        : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour >= 12 ? 'PM' : 'AM';
    if (sameDay) return '$h:$m $suffix';
    return '${dt.day}/${dt.month} $h:$m $suffix';
  }

  ChatMessage copyWith({
    dynamic id,
    String? readAt,
    ChatSendState? sendState,
    List<ChatAttachment>? attachments,
    ChatVoiceNote? voiceNote,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      tempId: tempId,
      conversationId: conversationId,
      userId: userId,
      isAdmin: isAdmin,
      body: body,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
      senderName: senderName,
      attachments: attachments ?? this.attachments,
      voiceNote: voiceNote ?? this.voiceNote,
      localPath: localPath,
      sendState: sendState ?? this.sendState,
    );
  }

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = '$v'.toLowerCase().trim();
    return s == 'true' || s == '1';
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawSender = json['sender'];
    final rawAttachments = json['attachments'];
    final rawVoice = json['voice_note'];
    DateTime? created;
    try {
      final raw = json['created_at']?.toString();
      if (raw != null && raw.isNotEmpty) created = DateTime.parse(raw);
    } catch (_) {}
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation_id'],
      userId: json['user_id'],
      isAdmin: _asBool(json['is_admin']),
      body: json['body']?.toString(),
      readAt: json['read_at']?.toString(),
      createdAt: created,
      senderName: rawSender is Map ? rawSender['name']?.toString() : null,
      attachments: rawAttachments is List
          ? rawAttachments
              .whereType<Map>()
              .map((e) =>
                  ChatAttachment.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      voiceNote: rawVoice is Map
          ? ChatVoiceNote.fromJson(Map<String, dynamic>.from(rawVoice))
          : null,
    );
  }
}

/// `GET /chat` payload: conversation meta + newest page (oldest-first).
class ChatThread {
  ChatThread({
    this.conversationId,
    this.unreadCount = 0,
    this.channel,
    this.messages = const [],
    this.hasMore = false,
  });

  final dynamic conversationId;
  final int unreadCount;
  final String? channel;
  final List<ChatMessage> messages;
  final bool hasMore;

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  factory ChatThread.fromBody(Map<String, dynamic>? body) {
    final data = _map(body?['data']);
    final conv = _map(data['conversation']);
    final rawMessages = data['messages'];
    return ChatThread(
      conversationId: conv['id'] ?? data['conversation_id'],
      unreadCount: conv['unread_count'] is num
          ? (conv['unread_count'] as num).toInt()
          : int.tryParse('${conv['unread_count']}') ?? 0,
      channel: data['channel']?.toString(),
      messages: rawMessages is List
          ? rawMessages
              .whereType<Map>()
              .map(
                  (e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      hasMore: data['has_more'] == true,
    );
  }
}

/// `GET /chat/messages?after_id=` payload (newer messages, oldest-first).
class ChatPollResult {
  ChatPollResult({
    this.messages = const [],
    this.lastId,
    this.unreadCount = 0,
  });

  final List<ChatMessage> messages;
  final dynamic lastId;
  final int unreadCount;

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  factory ChatPollResult.fromBody(Map<String, dynamic>? body) {
    final data = _map(body?['data']);
    final rawMessages = data['messages'];
    return ChatPollResult(
      messages: rawMessages is List
          ? rawMessages
              .whereType<Map>()
              .map(
                  (e) => ChatMessage.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      lastId: data['last_id'],
      unreadCount: data['unread_count'] is num
          ? (data['unread_count'] as num).toInt()
          : int.tryParse('${data['unread_count']}') ?? 0,
    );
  }
}
