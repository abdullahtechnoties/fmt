import 'dart:io';

import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/service/network_service.dart';
import 'package:get/get.dart';

/// Push device registration + notification preferences (auth only).
///
/// The token is the unique key server-side: re-registering after every
/// login (and on Firebase rotation) updates in place.
class DeviceRepository {
  DeviceRepository({NetworkService? network})
      : _network = network ?? Get.find();

  final NetworkService _network;

  static Map<String, dynamic> _map(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  /// `POST /devices` — {token, platform, app_version?}.
  Future<void> register({
    required String token,
    String? appVersion,
  }) async {
    try {
      await _network.post(
        endpoint: ApiPath.devices,
        body: {
          'token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          if (appVersion != null && appVersion.isNotEmpty)
            'app_version': appVersion,
        },
      );
    } catch (_) {}
  }

  /// `DELETE /devices` — call on logout so a shared handset stops
  /// receiving the previous customer's pushes.
  Future<void> unregister({required String token}) async {
    try {
      await _network.delete(
        endpoint: ApiPath.devices,
        body: {'token': token},
      );
    } catch (_) {}
  }

  /// `GET /notifications/settings` — {notify_orders, notify_chat,
  /// push_enabled, devices}.
  Future<NotificationSettings?> settings() async {
    try {
      final res = await _network.get(
        endpoint: ApiPath.notificationSettings,
      );
      if (res.isError || res.data == null) return null;
      return NotificationSettings.fromJson(_map(res.data!['data']));
    } catch (_) {
      return null;
    }
  }

  /// `PUT /notifications/settings` — send either toggle on its own.
  Future<bool> updateSettings({bool? notifyChat, bool? notifyOrders}) async {
    try {
      final body = <String, dynamic>{};
      if (notifyChat != null) body['notify_chat'] = notifyChat;
      if (notifyOrders != null) body['notify_orders'] = notifyOrders;
      final res = await _network.put(
        endpoint: ApiPath.notificationSettings,
        body: body,
      );
      return !res.isError;
    } catch (_) {
      return false;
    }
  }
}

class NotificationSettings {
  NotificationSettings({
    this.notifyOrders = true,
    this.notifyChat = true,
    this.pushEnabled = false,
    this.devices = 0,
  });

  final bool notifyOrders;
  final bool notifyChat;
  final bool pushEnabled;
  final int devices;

  static bool _asBool(dynamic v, {bool fallback = true}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = '$v'.toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return fallback;
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    final rawDevices = json['devices'];
    return NotificationSettings(
      notifyOrders: _asBool(json['notify_orders']),
      notifyChat: _asBool(json['notify_chat']),
      pushEnabled: _asBool(json['push_enabled'], fallback: false),
      devices: rawDevices is num
          ? rawDevices.toInt()
          : int.tryParse('$rawDevices') ?? 0,
    );
  }
}
