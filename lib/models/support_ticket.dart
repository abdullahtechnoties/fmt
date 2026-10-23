import '../utilities/image_path_helper.dart';
import '../utilities/translation_extention.dart';

class SupportTicket {
  final int id;
  final String ticketNumber;
  final String subject;
  final String category;
  final String priority;
  final String status;
  final TicketUser? user;
  final TicketUser? agent;
  final String lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;

  SupportTicket({
    required this.id,
    required this.ticketNumber,
    required this.subject,
    required this.category,
    required this.priority,
    required this.status,
    this.user,
    this.agent,
    required this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.createdAt,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      ticketNumber: json['ticket_number']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      category: json['category']?.toString() ?? 'other',
      priority: json['priority']?.toString() ?? 'medium',
      status: json['status']?.toString() ?? 'open',
      user: json['user'] != null ? TicketUser.fromJson(json['user']) : null,
      agent: json['agent'] != null ? TicketUser.fromJson(json['agent']) : null,
      lastMessage: json['last_message']?.toString() ?? '',
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get categoryLabel {
    switch (category) {
      case 'payment':
        return 'ticket.categories.payment'.trns();
      case 'booking':
        return 'ticket.categories.booking'.trns();
      case 'technical':
        return 'ticket.categories.technical'.trns();
      case 'account':
        return 'ticket.categories.account'.trns();
      default:
        return 'ticket.categories.other'.trns();
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'urgent':
        return 'ticket.priorities.urgent'.trns();
      case 'high':
        return 'ticket.priorities.high'.trns();
      case 'medium':
        return 'ticket.priorities.medium'.trns();
      default:
        return 'ticket.priorities.low'.trns();
    }
  }

  String get statusLabel {
    switch (status) {
      case 'open':
        return 'ticket.status.open'.trns();
      case 'assigned':
        return 'ticket.status.assigned'.trns();
      case 'resolved':
        return 'ticket.status.resolved'.trns();
      case 'closed':
        return 'ticket.status.closed'.trns();
      default:
        return status;
    }
  }
}

class TicketUser {
  final int id;
  final String name;
  final String? role;
  final String? photo;

  TicketUser({required this.id, required this.name, this.role, this.photo});

  factory TicketUser.fromJson(Map<String, dynamic> json) {
    return TicketUser(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown',
      role: json['role']?.toString(),
      photo: getImage(json['photo']?.toString()),
    );
  }
}
