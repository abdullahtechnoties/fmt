import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:fmt/network/api/api_path.dart';
import 'package:fmt/network/service/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

/// A singleton service that manages a single Pusher connection
/// to be shared by both ChatService and PusherSupportService
class PusherManager extends GetxService {
  static PusherManager get instance => Get.find<PusherManager>();
  
  static const String _appKey = '0e338b1aa07568b911cb';
  static const String _cluster = 'ap2';

  final AuthService _auth = Get.find<AuthService>();
  PusherChannelsFlutter? _pusher;
  final Completer<void> _connectionCompleter = Completer<void>();
  bool _isInitialized = false;

  // Map to track all active subscriptions: channelName -> eventHandlers
  final Map<String, List<Function(dynamic)>> _channelEventHandlers = {};

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initPusher();
  }

  Future<void> _initPusher() async {
    if (_isInitialized) return;
    
    try {
      _pusher = PusherChannelsFlutter.getInstance();
      await _pusher!.init(
        apiKey: _appKey,
        cluster: _cluster,
        onAuthorizer: _pusherAuthorizer,
        onConnectionStateChange: (currentState, previousState) {
          _log('Connection state: $previousState → $currentState');
          if (currentState == 'CONNECTED') {
            if (!_connectionCompleter.isCompleted) {
              _connectionCompleter.complete();
            }
          }
        },
        onError: (message, code, error) {
          _log('Pusher error [$code]: $message');
          if (error != null) {
            _log('Error details: $error');
          }
        },
      );
      await _pusher!.connect();
      _isInitialized = true;
      _log('Pusher initialized successfully');
    } catch (e, stackTrace) {
      _log('Pusher init error: $e\n$stackTrace');
      if (!_connectionCompleter.isCompleted) {
        _connectionCompleter.completeError(e);
      }
    }
  }

  Future<void> ensureConnected() async {
    if (!_isInitialized) {
      await _initPusher();
    }
    if (!_connectionCompleter.isCompleted) {
      await _connectionCompleter.future;
    }
  }

  /// Subscribe to a channel and register an event handler
  Future<void> subscribe({
    required String channelName,
    required Function(dynamic) onEvent,
  }) async {
    await ensureConnected();
    
    // If first subscription to this channel, subscribe in Pusher
    if (!_channelEventHandlers.containsKey(channelName)) {
      _channelEventHandlers[channelName] = [];
      await _pusher!.subscribe(
        channelName: channelName,
        onEvent: _handlePusherEvent,
      );
      _log('Subscribed to channel: $channelName');
    }
    
    // Add the event handler
    _channelEventHandlers[channelName]!.add(onEvent);
  }

  /// Unsubscribe a specific event handler from a channel
  Future<void> unsubscribe({
    required String channelName,
    Function(dynamic)? onEvent,
  }) async {
    if (!_channelEventHandlers.containsKey(channelName)) {
      return;
    }
    
    // If specific onEvent is provided, remove only that one
    if (onEvent != null) {
      _channelEventHandlers[channelName]!.remove(onEvent);
    } else {
      // Otherwise clear all handlers for this channel
      _channelEventHandlers[channelName]!.clear();
    }
    
    // If no more handlers for this channel, unsubscribe from Pusher
    if (_channelEventHandlers[channelName]!.isEmpty) {
      await _pusher?.unsubscribe(channelName: channelName);
      _channelEventHandlers.remove(channelName);
      _log('Unsubscribed from channel: $channelName');
    }
  }

  /// Handle incoming Pusher events and dispatch to all registered handlers
  void _handlePusherEvent(dynamic event) {
    if (event is! PusherEvent) return;
    final channelName = event.channelName;
    
    if (_channelEventHandlers.containsKey(channelName)) {
      for (final handler in _channelEventHandlers[channelName]!) {
        try {
          handler(event);
        } catch (e) {
          _log('Error in event handler: $e');
        }
      }
    }
  }

  /// Pusher channel authorization
  dynamic _pusherAuthorizer(String channelName, String socketId, dynamic options) async {
    try {
      final token = _auth.accessToken.value ?? '';
      final uri = Uri.parse('${ApiPath.baseUrl}/broadcasting/auth');

      final client = HttpClient();
      final request = await client.postUrl(uri);

      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.write('socket_id=${Uri.encodeQueryComponent(socketId)}&channel_name=${Uri.encodeQueryComponent(channelName)}');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      client.close();

      if (response.statusCode == 200) {
        return jsonDecode(body);
      }
      _log('Auth [${response.statusCode}]: $body');
      return null;
    } catch (e) {
      _log('Auth error: $e');
      return null;
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      print('[PusherManager] $message');
    }
  }

  @override
  void onClose() {
    _pusher?.disconnect();
    _channelEventHandlers.clear();
    super.onClose();
  }
}
