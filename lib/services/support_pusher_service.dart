import 'dart:async';
import 'dart:convert';
import 'package:fmt/models/support_message.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'pusher_manager.dart';

class PusherSupportService extends GetxService {
  static PusherSupportService get instance => Get.find<PusherSupportService>();
  final PusherManager _pusherManager = Get.find<PusherManager>();

  final Map<int, StreamController<SupportMessage>> _ticketStreams = {};
  final Map<int, Function(dynamic)> _ticketEventHandlers = {};
  final Map<int, void Function(int ticketId, int readerId)> _readCallbacks = {};

  // Subscribe to a ticket's channel
  Future<void> subscribeToTicket(int ticketId,
      {void Function(int ticketId, int readerId)? onRead}) async {
    try {
      final channelName = 'private-support-ticket.$ticketId';

      if (onRead != null) {
        _readCallbacks[ticketId] = onRead;
      }

      // Create or reuse event handler
      if (!_ticketEventHandlers.containsKey(ticketId)) {
        _ticketEventHandlers[ticketId] = (dynamic event) {
          if (event is! PusherEvent) return;
          _log('Received event: ${event.eventName}, data: ${event.data}');
          // Handle new message events
          if (event.eventName == 'new.support.message' || 
              event.eventName == 'App\\Events\\NewSupportMessage' ||
              event.eventName == 'NewSupportMessage') {
            _handleNewMessage(ticketId, event.data);
          } else if (event.eventName == 'support.message.read') {
            _handleReadEvent(ticketId, event.data);
          }
        };
      }

      await _pusherManager.subscribe(
        channelName: channelName,
        onEvent: _ticketEventHandlers[ticketId]!,
      );

      _log('Subscribed to $channelName');
    } catch (e) {
      _log('Error subscribing to ticket $ticketId: $e');
    }
  }

  // Unsubscribe from ticket
  Future<void> unsubscribeFromTicket(int ticketId) async {
    try {
      final channelName = 'private-support-ticket.$ticketId';
      final handler = _ticketEventHandlers[ticketId];
      
      if (handler != null) {
        await _pusherManager.unsubscribe(
          channelName: channelName,
          onEvent: handler,
        );
        _ticketEventHandlers.remove(ticketId);
      }
      _readCallbacks.remove(ticketId);
      
      // Close stream
      _ticketStreams[ticketId]?.close();
      _ticketStreams.remove(ticketId);
      
      _log('Unsubscribed from $channelName');
    } catch (e) {
      _log('Error unsubscribing from ticket $ticketId: $e');
    }
  }

  // Get message stream for a ticket
  Stream<SupportMessage> getTicketStream(int ticketId) {
    _log('Requesting stream for ticket $ticketId');
    if (!_ticketStreams.containsKey(ticketId)) {
      _log('Creating new stream for ticket $ticketId');
      _ticketStreams[ticketId] = StreamController<SupportMessage>.broadcast();
    }
    return _ticketStreams[ticketId]!.stream;
  }

  // Handle incoming message
  void _handleNewMessage(int ticketId, String data) {
    try {
      final json = parseEventData(data);
      _log('Parsed event data: $json');
      final message = SupportMessage.fromJson(json);
      
      if (_ticketStreams.containsKey(ticketId)) {
        _ticketStreams[ticketId]!.add(message);
        _log('Message added to stream for ticket $ticketId');
      } else {
        _log('No stream found for ticket $ticketId');
      }
    } catch (e, stackTrace) {
      _log('Error parsing message: $e\n$stackTrace');
    }
  }

  // Handle read receipt event
  void _handleReadEvent(int ticketId, String data) {
    try {
      final json = parseEventData(data);
      final readTicketId = json['ticket_id'] as int?;
      final readerId = json['reader_id'] as int?;
      if (readTicketId != null && readerId != null) {
        _readCallbacks[readTicketId]?.call(readTicketId, readerId);
      }
    } catch (e) {
      _log('Error handling read event: $e');
    }
  }

  // Parse Pusher event data
  Map<String, dynamic> parseEventData(String data) {
    String decoded = data;
    // Remove escaped quotes
    while (decoded.startsWith('"') && decoded.endsWith('"')) {
      decoded = decoded.substring(1, decoded.length - 1).replaceAll('\\"', '"');
    }
    final result = const JsonDecoder().convert(decoded);
    return Map<String, dynamic>.from(result as Map);
  }

  void _log(String message) {
    if (kDebugMode) {
      print('[PusherSupportService] $message');
    }
  }

  @override
  void onClose() {
    for (var stream in _ticketStreams.values) {
      stream.close();
    }
    _ticketStreams.clear();
    super.onClose();
  }
}
