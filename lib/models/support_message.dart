import '../utilities/image_path_helper.dart';
import 'support_ticket.dart';

class SupportMessage {
  final int id;
  final int ticketId;
  final int senderId;
  final String type; // text, image, file, voice, system
  final String? message;
  final String? fileUrl;
  final String? fileName;
  final String? fileSize;
  final String? fileMime;
  final int? voiceDuration;
  final bool isRead;
  final DateTime createdAt;
  final TicketUser sender;

  SupportMessage({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.type,
    this.message,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.fileMime,
    this.voiceDuration,
    required this.isRead,
    required this.createdAt,
    required this.sender,
  });

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as int,
      ticketId: json['ticket_id'] as int,
      senderId: json['sender_id'] as int,
      type: json['type']?.toString() ?? 'text',
      message: json['message']?.toString(),
      fileUrl: getImage(json['file_url']?.toString()),
      fileName: json['file_name']?.toString(),
      fileSize: json['file_size']?.toString(),
      fileMime: json['file_mime']?.toString(),
      voiceDuration: json['voice_duration'] as int?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
      sender: TicketUser.fromJson(json['sender']),
    );
  }

  SupportMessage copyWith({bool? isRead}) {
    return SupportMessage(
      id: id,
      ticketId: ticketId,
      senderId: senderId,
      type: type,
      message: message,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
      fileMime: fileMime,
      voiceDuration: voiceDuration,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      sender: sender,
    );
  }

  bool get isText => type == 'text';
  bool get isImage => type == 'image';
  bool get isFile => type == 'file';
  bool get isVoice => type == 'voice';
  bool get isSystem => type == 'system';
}
