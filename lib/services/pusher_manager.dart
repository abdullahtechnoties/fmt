import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

/// Shared Pusher connection for the app (store chat, etc).
///
/// Replaces the legacy manager: no hard-coded secret (one was a key/secret
/// mix-up), the app auth endpoint is `POST /api/broadcasting/auth` with
/// the Bearer token (the website's `/broadcasting/auth` is cookie-only and
/// rejects apps), and connect failures no longer throw — chat falls back
/// to polling when realtime is unavailable.
///
/// The Pusher app key is a public client key. Ask the backend for
/// `PUSHER_APP_KEY` and pass it to [init] before subscribing.
class PusherManager extends GetxService {
  static PusherManager get instance => Get.find<PusherManager>();

  static const String _cluster = 'ap2';

  final AuthService _auth = Get.find<AuthService>();
  PusherChannelsFlutter? _pusher;
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _key = "2e5f57f8cc5c7acf6ab2";

  final Map<String, List<Function(PusherEvent)>> _handlers = {};

  bool get isReady => _isInitialized && _isConnected && _key != null;

  /// Initialises Pusher with the public app key. Safe to call repeatedly —
  /// extra calls are no-ops. Never throws; returns false when realtime is
  /// unavailable so callers can fall back to polling.
  Future<bool> init({required String appKey}) async {
    if (_isInitialized && _key == appKey) return _isConnected;
    _key = appKey;
    try {
      _pusher?.disconnect();
    } catch (_) {}
    _handlers.clear();
    _isInitialized = false;
    _isConnected = false;
    try {
      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher!.init(
        apiKey: appKey,
        cluster: _cluster,
        onAuthorizer: _authorizer,
        onConnectionStateChange: (current, _) {
          _isConnected = current == 'CONNECTED';
          _log('Connection state → $current');
        },
        onError: (message, code, _) {
          _log('Pusher error [$code]: $message');
        },
      );
      await _pusher!.connect();
      _isInitialized = true;
      return _isConnected;
    } catch (e) {
      _log('init failed: $e');
      _isInitialized = true;
      return false;
    }
  }

  Future<void> subscribe({
    required String channelName,
    required Function(PusherEvent) onEvent,
  }) async {
    if (_key == null) {
      _log('subscribe without key — call init() with PUSHER_APP_KEY first');
      return;
    }
    if (!_isInitialized) {
      await init(appKey: _key!);
    }
    if (!isReady) {
      _log('not connected — skipping subscribe to $channelName');
      return;
    }
    if (!_handlers.containsKey(channelName)) {
      _handlers[channelName] = [];
      try {
        await _pusher!.subscribe(
          channelName: channelName,
          onEvent: _dispatch,
        );
        _log('subscribed to $channelName');
      } catch (e) {
        _log('subscribe to $channelName failed: $e');
        return;
      }
    }
    _handlers[channelName]!.add(onEvent);
  }

  Future<void> unsubscribe({
    required String channelName,
    Function(PusherEvent)? onEvent,
  }) async {
    if (!_handlers.containsKey(channelName)) return;
    if (onEvent != null) {
      _handlers[channelName]!.remove(onEvent);
    } else {
      _handlers[channelName]!.clear();
    }
    if (_handlers[channelName]!.isEmpty) {
      try {
        await _pusher?.unsubscribe(channelName: channelName);
      } catch (_) {}
      _handlers.remove(channelName);
      _log('unsubscribed from $channelName');
    }
  }

  void _dispatch(dynamic event) {
    if (event is! PusherEvent) return;
    for (final handler in List.of(_handlers[event.channelName] ?? const [])) {
      try {
        handler(event);
      } catch (e) {
        _log('handler error: $e');
      }
    }
  }

  /// `POST /api/broadcasting/auth` with Bearer token. The body is
  /// form-encoded `socket_id` + `channel_name`; returns `{"auth": "…"}`.
  /// Subscribing to another customer's conversation returns 403.
  dynamic _authorizer(String channelName, String socketId, dynamic _) async {
    try {
      final token = _auth.accessToken.value ?? '';
      final uri = Uri.parse(ApiPath.broadcastingAuth);
      final client = HttpClient();
      final request = await client.postUrl(uri);
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(
          HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write(
          'socket_id=${Uri.encodeQueryComponent(socketId)}&channel_name=${Uri.encodeQueryComponent(channelName)}');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();
      if (response.statusCode == 200) return jsonDecode(body);
      _log('auth [${response.statusCode}]: $body');
      return null;
    } catch (e) {
      _log('auth error: $e');
      return null;
    }
  }

  void _log(String message) {
    if (kDebugMode) print('[PusherManager] $message');
  }

  @override
  void onClose() {
    try {
      _pusher?.disconnect();
    } catch (_) {}
    _handlers.clear();
    super.onClose();
  }
}
