// import 'package:fmt/models/notification_model.dart';
// import 'package:fmt/network/api/api_path.dart';
// import 'package:fmt/network/response/api_response.dart';
// import 'package:fmt/network/service/network_service.dart';
// import 'package:fmt/utilities/translation_extention.dart';
// import 'package:get/get.dart';

// class NotificationService {
//   final NetworkService _network = Get.find<NetworkService>();

//   /// GET /notifications — list of notifications for the auth user.
//   Future<ApiResponse<List<NotificationModel>>> fetchNotifications() async {
//     final res = await _network.get(endpoint: ApiPath.notifications);
//     if (res.isError) {
//       return ApiResponse.error(res.message ?? 'errors.unexpected'.trns());
//     }
//     try {
//       final data = res.data!['data'];
//       if (data is! List) {
//         return ApiResponse.completed([]);
//       }
//       final items = data
//           .whereType<Map<String, dynamic>>()
//           .map(NotificationModel.fromJson)
//           .toList();
//       return ApiResponse.completed(items);
//     } catch (e) {
//       return ApiResponse.error('errors.unexpected'.trns());
//     }
//   }

//   /// POST /notifications/read/{id} — marks a single notification as read.
//   Future<ApiResponse<Map<String, dynamic>>> markAsRead(int id) async {
//     final res = await _network.post(
//       endpoint: ApiPath.markNotificationRead(id),
//     );
//     if (res.isError) {
//       return ApiResponse.error(res.message ?? 'errors.unexpected'.trns());
//     }
//     return ApiResponse.completed(res.data ?? {});
//   }

//   /// POST /notifications/read-all — marks all notifications as read.
//   Future<ApiResponse<Map<String, dynamic>>> markAllAsRead() async {
//     final res = await _network.post(
//       endpoint: ApiPath.markAllNotificationsRead,
//     );
//     if (res.isError) {
//       return ApiResponse.error(res.message ?? 'errors.unexpected'.trns());
//     }
//     return ApiResponse.completed(res.data ?? {});
//   }
// }
