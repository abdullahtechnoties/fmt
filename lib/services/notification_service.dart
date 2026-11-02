import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

import 'package:fmt/firebase_options.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:fmt/repositories/device_repository.dart';
import 'package:fmt/services/notification_resolver_service.dart';

/// Must stay top-level for the background isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
}

/// Foreground + tap listener and `POST /devices` registration.
///
/// Register after every login and on every Firebase rotation (the token
/// is the unique key server-side, so re-registering updates in place).
/// Terminated-state taps resolve via [pendingTap]; call
/// [consumePendingTap] once routing is ready (post-splash).
class FmtNotificationService extends GetxService {
  static FmtNotificationService get instance => Get.isRegistered<FmtNotificationService>()
      ? Get.find<FmtNotificationService>()
      : Get.put(FmtNotificationService());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _refreshSub;

  String? fcmToken;
  bool _initialized = false;
  RemoteMessage? pendingTap;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Cold start from a terminated-state notification tap.
    try {
      pendingTap = await _messaging.getInitialMessage();
    } catch (_) {}

    _foregroundSub?.cancel();
    _foregroundSub = FirebaseMessaging.onMessage.listen((message) {
      NotificationResolverService.instance.handleNotification(message);
    });

    _openedSub?.cancel();
    _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      NotificationResolverService.instance.handleNotification(message,
          isTap: true);
    });

    await refreshToken();
    _refreshSub?.cancel();
    _refreshSub = _messaging.onTokenRefresh.listen((token) async {
      fcmToken = token;
      await _register(token);
    });
  }

  /// Reads the current FCM token and registers it (login + app resume).
  /// No-ops for guests — there is no account to attach the token to.
  Future<void> refreshToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return;
      fcmToken = token;
      await _register(token);
    } catch (_) {}
  }

  Future<void> _register(String token) async {
    if (!_loggedIn) return;
    try {
      String? version;
      try {
        // package_info_plus is not a dependency — skip when unavailable.
        version = null;
      } catch (_) {}
      await DeviceRepository().register(token: token, appVersion: version);
    } catch (_) {}
  }

  /// `DELETE /devices` + Firebase token delete on logout so a shared
  /// handset stops receiving the previous customer's notifications.
  Future<void> clearOnLogout() async {
    final token = fcmToken;
    try {
      if (token != null && token.isNotEmpty) {
        await DeviceRepository().unregister(token: token);
      }
    } catch (_) {}
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    fcmToken = null;
    pendingTap = null;
  }

  /// Returns the stored terminated-state tap and clears it.
  RemoteMessage? consumePendingTap() {
    final tap = pendingTap;
    pendingTap = null;
    return tap;
  }

  bool get _loggedIn {
    try {
      final auth = Get.find<AuthService>();
      if (auth.currentUser.value != null) return true;
    } catch (_) {}
    return AuthService.authenticated();
  }

  /// The gotchas section says it plainly: never trust a push to arrive.
  /// Call on app resume — refreshes chat (badge + live thread) and orders.
  Future<void> refreshOnResume() async {
    await NotificationResolverService.instance.refreshAll();
  }

  @override
  void onClose() {
    _foregroundSub?.cancel();
    _openedSub?.cancel();
    _refreshSub?.cancel();
    super.onClose();
  }
}
