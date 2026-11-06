// Support tickets (`/support/*`): login-only tracked conversations with
// the store, addressed by human `reference` (e.g. TKT-000123) — not by
// numeric id. Staff-only internal notes never appear in `replies`.

class SupportCategory {
  SupportCategory({
    this.id,
    this.name = '',
    this.slug = '',
  });

  final dynamic id;
  final String name;
  final String slug;

  factory SupportCategory.fromJson(Map<String, dynamic> json) {
    return SupportCategory(
      id: json['id'],
      name: (json['name'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
    );
  }
}

class TicketReply {
  TicketReply({
    this.id,
    this.isStaff = false,
    this.author = '',
    this.body = '',
    this.createdAt = '',
  });

  final dynamic id;

  /// `true` = the store, `false` = this customer.
  final bool isStaff;
  final String author;
  final String body;
  final String createdAt;

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    final staff = json['is_staff'];
    return TicketReply(
      id: json['id'],
      isStaff: staff is bool ? staff : '${staff ?? ''}' == '1',
      author: (json['author'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}

class SupportTicket {
  SupportTicket({
    this.reference = '',
    this.subject = '',
    this.message = '',
    this.status = 'open',
    this.statusLabel = '',
    this.category = '',
    this.unreadCount = 0,
    this.lastReplyAt = '',
    this.createdAt = '',
    this.replies = const [],
  });

  final String reference;
  final String subject;

  /// The opening message (the ticket body).
  final String message;
  final String status;

  /// Server-localised display label — always render this, never `status`.
  final String statusLabel;
  final String category;
  final int unreadCount;
  final String lastReplyAt;
  final String createdAt;
  final List<TicketReply> replies;

  /// Replying to one of these reopens it to `open` — the UI must say so.
  bool get isFinished =>
      status == 'resolved' || status == 'rejected' || status == 'closed';

  String get displayStatus => statusLabel.isNotEmpty ? statusLabel : status;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'];
    return SupportTicket(
      reference: (json['reference'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? 'open').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      unreadCount: parseInt(json['unread_count']),
      lastReplyAt: (json['last_reply_at'] ?? '').toString(),
      createdAt: (json['created_at'] ?? '').toString(),
      replies: rawReplies is List
          ? rawReplies
              .whereType<Map>()
              .map((e) => TicketReply.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }

  /// Unwraps `{data: {ticket: {...}}}` (detail/reply/raise) or a bare row.
  factory SupportTicket.fromBody(dynamic body) {
    final Map<String, dynamic> map =
        body is Map ? Map<String, dynamic>.from(body) : {};
    final data = map['data'];
    final Map<String, dynamic> inner =
        data is Map ? Map<String, dynamic>.from(data) : {};
    final ticket = inner['ticket'];
    if (ticket is Map) {
      return SupportTicket.fromJson(
          Map<String, dynamic>.from(ticket));
    }
    if (data is Map) return SupportTicket.fromJson(inner);
    return SupportTicket.fromJson(map);
  }

  static int parseInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }
}
