// import 'dart:io';
// import 'package:fmt/models/support_message.dart';
// import 'package:fmt/models/support_ticket.dart';
// import 'package:fmt/network/api/api_path.dart';
// import 'package:fmt/network/response/api_response.dart';
// import 'package:fmt/network/service/network_service.dart';
// import 'package:get/get.dart';

// class SupportApi {
//   final NetworkService _network = Get.find<NetworkService>();

//   // Create new ticket
//   Future<ApiResponse<SupportTicket>> createTicket({
//     required String subject,
//     required String description,
//     required String category,
//     required String priority,
//   }) async {
//     final response = await _network.post(
//       endpoint: ApiPath.tickets,
//       body: {
//         'subject': subject,
//         'description': description,
//         'category': category,
//         'priority': priority,
//       },
//     );

//     if (response.isCompleted && response.data != null) {
//       final ticket = SupportTicket.fromJson(response.data!['ticket']);
//       return ApiResponse.completed(ticket, message: 'Ticket created successfully');
//     }

//     return ApiResponse.error(response.message ?? 'Failed to create ticket');
//   }

//   // Get my tickets
//   Future<ApiResponse<List<SupportTicket>>> getMyTickets() async {
//     final response = await _network.get(endpoint: ApiPath.tickets);

//     if (response.isCompleted && response.data != null) {
//       final ticketsJson = response.data!['tickets'] as List;
//       final tickets = ticketsJson.map((json) => SupportTicket.fromJson(json)).toList();
//       return ApiResponse.completed(tickets);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to load tickets');
//   }

//   // Get ticket details with messages
//   Future<ApiResponse<Map<String, dynamic>>> getTicketDetails(int ticketId) async {
//     final response = await _network.get(endpoint: ApiPath.ticketById(ticketId));

//     if (response.isCompleted && response.data != null) {
//       final ticket = SupportTicket.fromJson(response.data!['ticket']);
//       final messagesJson = response.data!['messages'] as List;
//       final messages = messagesJson.map((json) => SupportMessage.fromJson(json)).toList();

//       return ApiResponse.completed({
//         'ticket': ticket,
//         'messages': messages,
//       });
//     }

//     return ApiResponse.error(response.message ?? 'Failed to load ticket details');
//   }

//   // Send text message
//   Future<ApiResponse<SupportMessage>> sendMessage(int ticketId, String message) async {
//     final response = await _network.post(
//       endpoint: ApiPath.ticketSend(ticketId),
//       body: {'message': message},
//     );

//     if (response.isCompleted && response.data != null) {
//       final msg = SupportMessage.fromJson(response.data!['message']);
//       return ApiResponse.completed(msg);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to send message');
//   }

//   // Send file (image or document)
//   Future<ApiResponse<SupportMessage>> sendFile(int ticketId, File file) async {
//     final response = await _network.postForm(
//       endpoint: ApiPath.ticketSendFile(ticketId),
//       files: {'file': file},
//     );

//     if (response.isCompleted && response.data != null) {
//       final msg = SupportMessage.fromJson(response.data!['message']);
//       return ApiResponse.completed(msg);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to send file');
//   }

//   // Send voice message
//   Future<ApiResponse<SupportMessage>> sendVoice(
//     int ticketId,
//     File voiceFile,
//     int duration,
//   ) async {
//     final response = await _network.postForm(
//       endpoint: ApiPath.ticketSendVoice(ticketId),
//       fields: {'duration': duration.toString()},
//       files: {'voice': voiceFile},
//     );

//     if (response.isCompleted && response.data != null) {
//       final msg = SupportMessage.fromJson(response.data!['message']);
//       return ApiResponse.completed(msg);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to send voice message');
//   }

//   // Mark messages as read
//   Future<ApiResponse<void>> markAsRead(int ticketId) async {
//     final response = await _network.post(endpoint: ApiPath.ticketRead(ticketId));

//     if (response.isCompleted) {
//       return ApiResponse.completed(null);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to mark as read');
//   }

//   // Get total unread count
//   Future<ApiResponse<int>> getUnreadCount() async {
//     final response = await _network.get(endpoint: ApiPath.supportUnreadCount);

//     if (response.isCompleted && response.data != null) {
//       final count = response.data!['total_unread'] as int? ?? 0;
//       return ApiResponse.completed(count);
//     }

//     return ApiResponse.error(response.message ?? 'Failed to load unread count');
//   }
// }