// import 'dart:async';
// import 'dart:io';
// import 'package:fmt/app/modules/notifications/controllers/notifications_controller.dart';
// import 'package:fmt/firebase_options.dart';
// import 'package:fmt/network/api/api_path.dart';
// import 'package:fmt/network/service/network_service.dart';
// import 'package:fmt/services/notification_resolver_service.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('Background message received: ${message.messageId}');
//   print('Background message data: ${message.data}');
// }

// @pragma('vm:entry-point')
// Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
//   final payload = receivedAction.payload ?? {};

//   final fakeMessage = RemoteMessage(
//     data: payload,
//     notification: RemoteNotification(
//       title: receivedAction.title,
//       body: receivedAction.body,
//     ),
//   );

//   // IMPORTANT: You can't use GetX navigation directly here sometimes
//   // so keep this lightweight or delegate carefully

//   NotificationResolverService.instance.handleNotification(
//     fakeMessage,
//     isTap: true,
//   );
// }

// class NotificationService {
//   NotificationService._privateConstructor();
//   static final NotificationService instance =
//       NotificationService._privateConstructor();

//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;
//   StreamSubscription<RemoteMessage>? _onMessageSubscription;
//   StreamSubscription<RemoteMessage>? _onMessageOpenedSubscription;
//   // StreamSubscription<ReceivedAction>? _notificationActionSubscription;
//   bool _initialized = false;

//   String? fcmToken;
//   RemoteMessage? initialMessage;

//   /// Initialize FCM listeners and permission flow.
//   Future<void> init() async {
//     if (_initialized) return;

//     _initialized = true;

//     // Initialize Awesome Notifications
//     await AwesomeNotifications().initialize(
//       null, // Default icon
//       [
//         NotificationChannel(
//           channelKey: 'basic_channel',
//           channelName: 'Basic notifications',
//           channelDescription: 'Notification channel for basic tests',
//           importance: NotificationImportance.High,
//           channelShowBadge: true,
//         ),
//       ],
//       debug: true,
//     );

//     await _requestPermission();
//     await _setForegroundPresentationOptions();

//     _listenForegroundMessages();
//     _listenMessageOpenedApp();
//     _listenNotificationActions();
//     _listenAppLifecycle();
//     initialMessage = await _messaging.getInitialMessage();
//     await _processPendingNotifications();
//   }

//   /// Request permission on launch for both iOS and Android (Android 13+).
//   Future<void> _requestPermission() async {
//     await AwesomeNotifications().requestPermissionToSendNotifications();

//     final NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//       provisional: false,
//       announcement: false,
//       carPlay: false,
//       criticalAlert: false,
//     );

//     print('Notification permission status: ${settings.authorizationStatus}');
//   }

//   Future<void> _setForegroundPresentationOptions() async {
//     await _messaging.setForegroundNotificationPresentationOptions(
//       alert: false, // Disable FCM's default foreground alerts
//       badge: true,
//       sound: true,
//     );
//   }

//   /// Get FCM token and optionally send to backend
//   Future<void> getToken() async {
//     try {
//       if (Platform.isIOS) {
//         await Future.delayed(const Duration(seconds: 3));
//       }

//       fcmToken = await _messaging.getToken();

//       print('FCM Token: $fcmToken');

//       if (fcmToken != null && fcmToken!.isNotEmpty) {
//         await _sendTokenToBackend(fcmToken!);
//       }

//       _messaging.onTokenRefresh.listen((String newToken) async {
//         fcmToken = newToken;
//         print('FCM Token refreshed: $newToken');
//         await _sendTokenToBackend(newToken);
//       });
//     } catch (e) {
//       print('Error fetching FCM token: $e');
//     }
//   }

//   /// Send token to your backend
//   Future<void> _sendTokenToBackend(String token) async {
//     try {
//       final httpService = Get.find<NetworkService>();
//       print('Sending FCM token to backend: $token');
//       final response = await httpService.post(
//         endpoint: ApiPath.getSetupFcm,
//         body: {'fcm_token': token},
//       );
//       print('Response from saving FCM token: ${response.data.toString()}');
//       if (response.isCompleted && response.data?['success'] == true) {
//         print('FCM token uploaded successfully.');
//       } else {
//         print('Failed to upload FCM token: ${response.data.toString()}');
//       }
//     } catch (e) {
//       print('Error uploading FCM token: $e');
//     }
//   }

//   /// Send "@" as fcm_token to backend on logout
//   Future<void> clearTokenOnLogout() async {
//     try {
//       final httpService = Get.find<NetworkService>();
//       await httpService.post(
//         endpoint: ApiPath.getSetupFcm,
//         body: {'fcm_token': ''},
//       );
//       print('FCM token cleared on logout');
//     } catch (e) {
//       print('Error clearing FCM token on logout: $e');
//     }
//   }

//   /// Listen to messages when app is in foreground
//   void _listenForegroundMessages() {
//     _onMessageSubscription?.cancel();
//     _onMessageSubscription = FirebaseMessaging.onMessage.listen((
//       RemoteMessage message,
//     ) {
//       print('Foreground message received: ${message.notification?.title}');
//       print('Message data: ${message.data.toString()}');
//       _showAwesomeNotification(message);
//       NotificationResolverService.instance.handleNotification(
//         message,
//         isTap: false,
//       );
//       _refreshNotificationsList();
//     });
//   }

//   /// Show notification using awesome_notifications
//   void _showAwesomeNotification(RemoteMessage message) {
//     AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
//         channelKey: 'basic_channel',
//         title: message.notification?.title ?? 'New Notification',
//         body: message.notification?.body ?? '',
//         payload: message.data.map(
//           (key, value) => MapEntry(key, value.toString()),
//         ),
//       ),
//     );
//   }

//   /// Listen when user taps notification
//   void _listenMessageOpenedApp() {
//     _onMessageOpenedSubscription?.cancel();
//     _onMessageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen((
//       RemoteMessage message,
//     ) {
//       _handleNotificationTap(message, source: 'background');
//     });
//   }

//   /// Listen to notification taps from awesome_notifications
//   void _listenNotificationActions() {
//     AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//     );
//   }

//   /// Notification tap behavior: use resolver for navigation and refresh.
//   void _handleNotificationTap(RemoteMessage message, {required String source}) {
//     print('Notification tap detected from $source state.');
//     print('Notification data: ${message.data}');
//     NotificationResolverService.instance.handleNotification(
//       message,
//       isTap: true,
//     );
//     _refreshNotificationsList();
//   }

//   void _refreshNotificationsList() {
//     if (Get.isRegistered<NotificationsController>()) {
//       Get.find<NotificationsController>().fetchNotifications(showLoader: false);
//     }
//   }

//   void _listenAppLifecycle() {
//     AppLifecycleListener(
//       onResume: _processPendingNotifications,
//     );
//   }

//   Future<void> _processPendingNotifications() async {
//     NotificationResolverService.instance.refreshAll();
//     _refreshNotificationsList();
//   }
// }
