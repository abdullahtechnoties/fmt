// // import 'package:fmt/app/modules/chat/controllers/chat_detail_controller.dart';
// // import 'package:fmt/app/modules/chat/controllers/chat_list_controller.dart';
// // import 'package:fmt/app/modules/profile_details/controllers/profile_details_controller.dart';
// import 'package:fmt/app/routes/app_pages.dart';
// import 'package:fmt/network/service/auth_service.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:get/get.dart';

// class NotificationResolverService {
//   NotificationResolverService._privateConstructor();
//   static final NotificationResolverService instance =
//       NotificationResolverService._privateConstructor();

//   AuthService? get _authService =>
//       Get.isRegistered<AuthService>() ? Get.find<AuthService>() : null;

//   /// Handle both tapped notifications and foreground notifications
//   void handleNotification(RemoteMessage message, {bool isTap = false}) {
//     if (!_isUserLoggedIn()) {
//       return;
//     }

//     //SupportTicket? supportTicket;
//     // User? 
//     print('Notification received: ${message.data}');
//     final modelType = message.data['model_type'];
//     if (modelType == 'App\\Models\\User') {
//       _handleProfileNotification(message, isTap: isTap);
//     } else if (modelType == 'App\\Models\\Message' ||
//         modelType == 'App\\Models\\Conversation') {
//           print('Notification is for chat: ${message.data}');
//       _handleChatNotification(message, isTap: isTap);
//     } else {
//       print('Notification is for other model type: $modelType');
//       // Handle other model types here as needed
//       _handleOtherNotification(message, isTap: isTap);
//     }
//     // Add other model types here as needed
//   }

//   /// Resolve navigation from in-app notification list
//   void resolve({
//     required String modelType,
//     required int modelId,
//     String? senderName,
//     String? senderPhoto,
//     int? senderId,
//   }) {
//     if (!_isUserLoggedIn()) return;
//     print('Resolving navigation for modelType: $modelType, modelId: $modelId, senderName: $senderName, senderPhoto: $senderPhoto, senderId: $senderId');
//     if (modelType == 'App\\Models\\User') {
//       _navigateToProfileDetails(jobId: modelId);
//     } else if (modelType == 'App\\Models\\Message' ||
//         modelType == 'App\\Models\\Conversation') {
//       print('Resolving navigation to chat detail for chatId: $modelId with senderName: $senderName, senderPhoto: $senderPhoto, senderId: $senderId');
//       _navigateToChatDetail(
//         chatId: modelId,
//         senderName: senderName,
//         senderPhoto: senderPhoto,
//         senderId: senderId,
//       );
//     }
//   }

//   /// Refresh all relevant controllers when app returns to foreground
//   void refreshAll() {
//     if (!_isUserLoggedIn()) return;

//     _refreshRelevantControllers();
//     // _refreshChatList();
//   }

//   // void _refreshChatList() {
//   //   if (Get.isRegistered<ChatListController>()) {
//   //     Get.find<ChatListController>().fetchChats(silent: true);
//   //   }
//   // }

//   bool _isUserLoggedIn() {
//     final authService = _authService;
//     return authService?.accessToken.value != null &&
//         authService!.accessToken.value!.isNotEmpty;
//   }

//   void _handleProfileNotification(RemoteMessage message, {required bool isTap}) {
//     final jobId = message.data['sender_id'] ?? message.data['user_id'];
//     if (jobId == null) return;

//     // Refresh relevant controllers if they are registered
//     _refreshRelevantControllers(jobId: int.tryParse(jobId.toString()));

//     if (isTap) {
//       _navigateToProfileDetails(jobId: int.tryParse(jobId.toString()));
//     }
//   }

//   void _refreshRelevantControllers({int? jobId}) {
//     // if (Get.isRegistered<MyJobsController>()) {
//     //   Get.find<MyJobsController>().fetchJobs(showLoader: false);
//     // }

//     // if (Get.isRegistered<JobDetailsController>()) {
//     //   final jobDetailsController = Get.find<JobDetailsController>();
//     //   if (jobId != null && jobDetailsController.jobId == jobId) {
//     //     jobDetailsController.fetchJobDetails(showLoader: false);
//     //   }
//     // }

//     // if (Get.isRegistered<VendorRevisionController>()) {
//     //   final vendorRevisionController = Get.find<VendorRevisionController>();
//     //   if (jobId != null && vendorRevisionController.jobId == jobId) {
//     //     vendorRevisionController.fetchJobDetails(showLoader: false);
//     //   }
//     // }
//   }

//   void _handleOtherNotification(RemoteMessage message, {required bool isTap}) {
//     // Handle other model types here as needed
//     // For example, if you have a notification for a new feature or announcement
//     // you can navigate to that specific page or show a dialog.
//     // Get.toNamed(Routes.NOTIFICATIONS);
//   }

//   void _navigateToProfileDetails({int? jobId}) {
//     if (jobId == null) {
//       _navigateToNotifications();
//       return;
//     }

//     final currentRoute = Get.currentRoute;

//     // if (currentRoute == Routes.PROFILE_DETAILS) {
//     //   // Already on profile details page - let's check if it's the same user
//     //   if (Get.isRegistered<ProfileDetailsController>()) {
//     //     final controller = Get.find<ProfileDetailsController>();
//     //     if (controller.resolvedUserId == jobId) {
//     //       // Same user, just refresh
//     //       controller.fetchProfile();
//     //       return;
//     //     }
//     //   }
//     // }

//     // Navigate with proper back stack
//     // final isInMainFlow = [
//     //   Routes.BOTTOM_NAV,
//     //   Routes.HOME,
//     //   Routes.ACTIVITY,
//     //   Routes.EXPLORE,
//     //   Routes.CHAT_LIST,
//     //   Routes.PROFILE,
//     // ].contains(currentRoute);

//     // if (isInMainFlow) {
//     //   Get.toNamed(Routes.PROFILE_DETAILS, arguments: jobId);
//     // } else {
//     //   // If not in main flow, go to bottomnav first then to job details
//     //   Get.offAllNamed(Routes.BOTTOM_NAV);
//     //   Future.delayed(const Duration(milliseconds: 300), () {
//     //     Get.toNamed(Routes.PROFILE_DETAILS, arguments: jobId);
//     //   });
//     // }
//   }

//   void _navigateToNotifications() {
//     // final currentRoute = Get.currentRoute;
//     // if (currentRoute != Routes.NOTIFICATIONS) {
//     //   final isInMainFlow = [
//     //     Routes.BOTTOM_NAV,
//     //     Routes.HOME,
//     //     Routes.ACTIVITY,
//     //     Routes.EXPLORE,
//     //     Routes.CHAT_LIST,
//     //     Routes.PROFILE,
//     //   ].contains(currentRoute);

//     //   if (isInMainFlow) {
//     //     Get.toNamed(Routes.NOTIFICATIONS);
//     //   } else {
//     //     Get.offAllNamed(Routes.BOTTOM_NAV);
//     //     Future.delayed(const Duration(milliseconds: 300), () {
//     //       Get.toNamed(Routes.NOTIFICATIONS);
//     //     });
//     //   }
//     // }
//   }

//   // ─── Chat notifications ───────────────────────────────────────────────────

//   void _handleChatNotification(RemoteMessage message, {required bool isTap}) {
//     final chatId = message.data['conversation_id'];
//     if (chatId == null) return;
//     print('Handling chat notification for chatId: $chatId, isTap: $isTap');
//     final id = int.tryParse(chatId.toString());
//     if (id == null) return;
//     print('Handling chat notification for chatId: $id, isTap: $isTap');
//     // _refreshChatList();

//     if (isTap) {
//       _navigateToChatDetail(
//         chatId: id,
//         message: message,
//         senderName: message.data['sender_name'],
//         senderPhoto: message.data['sender_photo'],
//         senderId: int.tryParse(message.data['sender_id']?.toString() ?? ''),
//       );
//     }
//   }

//   void _navigateToChatDetail({
//     required int chatId,
//     RemoteMessage? message,
//     String? senderName,
//     String? senderPhoto,
//     int? senderId,
//   }) {
//     final currentRoute = Get.currentRoute;

//     // If already in this chat, just ignore (Pusher handles it)
//     // if (currentRoute == Routes.CHAT_DETAIL &&
//     //     Get.isRegistered<ChatDetailController>()) {
//     //   final ctrl = Get.find<ChatDetailController>();
//     //   if (ctrl.chatId == chatId) return;
//     // }

//     final args = <String, dynamic>{
//       'conversation_id': chatId,
//       'name': senderName ?? message?.data['sender_name'] ?? 'Customer',
//       'photo': senderPhoto ?? message?.data['sender_photo'],
//       'other_user_id':
//           senderId ??
//           int.tryParse(message?.data['sender_id']?.toString() ?? ''),
//     };

//     // final isInMainFlow = [
//     //   Routes.BOTTOM_NAV,
//     //   Routes.HOME,
//     //   Routes.ACTIVITY,
//     //   Routes.EXPLORE,
//     //   Routes.CHAT_LIST,
//     //   Routes.PROFILE,
//     // ].contains(currentRoute);

//     // if (isInMainFlow) {
//     //   Get.toNamed(Routes.CHAT_DETAIL, arguments: args);
//     // } else {
//     //   Get.offAllNamed(Routes.BOTTOM_NAV);
//     //   Future.delayed(const Duration(milliseconds: 300), () {
//     //     Get.toNamed(Routes.CHAT_DETAIL, arguments: args);
//     //   });
//     // }
//   }
// }
