import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fmt/services/pusher_manager.dart' show PusherManager;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:fmt/app/modules/bottomnav/controllers/bottomnav_controller.dart';
import 'package:fmt/models/chat_model.dart';
import 'package:fmt/network/response/api_response.dart';
import 'package:fmt/repositories/chat_repository.dart';
import 'package:fmt/services/chat_pusher_service.dart';
import 'package:fmt/utilities/snackbar_service.dart';
import 'package:fmt/utilities/translation_extention.dart';

/// Live store-chat thread: history + pagination, realtime via Pusher with
/// polling fallback, optimistic sends with confirmed ticks, voice notes
/// and media sharing.
///
/// Arguments (all optional): `{prefill, conversationId, highlightMessageId}`.
/// The screen creates the thread on first send — `GET /chat` only reads,
/// so opening chat never fails for a customer without history yet.
class ChatController extends GetxController {
  ChatController({ChatRepository? chatRepo})
      : _chatRepo = chatRepo ?? ChatRepository();

  final ChatRepository _chatRepo;

  /// Newest-first (the list view is reversed).
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final isLoading = true.obs;
  final RxnString loadError = RxnString();
  final isLoadingOlder = false.obs;
  final hasMore = false.obs;
  final isMarkingRead = false.obs;

  final RxnInt conversationId = RxnInt();
  final RxnString highlightId = RxnString();

  final composer = TextEditingController();
  final scrollController = ScrollController();
  final hasComposerText = false.obs;

  // Voice recording
  final isRecording = false.obs;
  final recordingSeconds = 0.obs;
  final isPreparingMedia = false.obs;

  // Voice playback (one at a time)
  final playingVoiceKey = RxnString();
  final playPosition = 0.0.obs;
  final playDuration = 1.0.obs;
  final isPlaying = false.obs;

  dynamic get lastSeenMessageId =>
      messages.isEmpty ? null : messages.first.id;

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  Timer? _recordTimer;
  Timer? _pollTimer;
  DateTime? _recordStartedAt;
  StreamSubscription<ChatMessage>? _liveSub;
  StreamSubscription<ChatReadReceipt>? _readSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  bool _pusherLive = false;
  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // pusher init
    Get.find<PusherManager>().init(
      appKey: "2e5f57f8cc5c7acf6ab2",
    );
    composer.addListener(
        () => hasComposerText.value = composer.text.trim().isNotEmpty);
    _readArguments();
    _wirePlayer();
    loadThread();
  }

  void _readArguments() {
    final args = Get.arguments;
    if (args is Map) {
      final prefill = args['prefill']?.toString() ?? '';
      if (prefill.isNotEmpty) {
        composer.text = prefill;
        hasComposerText.value = true;
      }
      final conv = args['conversationId'];
      final convId = conv is int ? conv : int.tryParse('$conv');
      if (convId != null) conversationId.value = convId;
      final hl = args['highlightMessageId']?.toString() ?? '';
      if (hl.isNotEmpty) highlightId.value = hl;
    } else if (args is String && args.isNotEmpty) {
      composer.text = args;
      hasComposerText.value = true;
    }
    if (highlightId.value != null) {
      Future.delayed(const Duration(seconds: 5), () {
        highlightId.value = null;
      });
    }
  }

  // ─── Thread + pagination ──────────────────────────────────────────────────

  Future<void> loadThread() async {
    isLoading.value = true;
    loadError.value = null;
    try {
      final res = await _chatRepo.thread();
      if (res.isError || res.data == null) {
        loadError.value = (res.message?.isNotEmpty ?? false)
            ? res.message
            : 'chat.load_failed'.trns();
        return;
      }
      _applyThread(res.data!);
      _afterVisible();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyThread(ChatThread thread) {
    final convId = thread.conversationId is int
        ? thread.conversationId as int
        : int.tryParse('${thread.conversationId}');
    if (convId != null) conversationId.value = convId;
    final server = thread.messages.reversed.toList();
    messages.assignAll(_merge(server, messages.toList()));
    hasMore.value = thread.hasMore;
    _subscribeRealtime();
    _scrollToBottom(jump: true);
  }

  /// Older page: `before_id` = oldest id held (last in newest-first list).
  Future<void> loadOlder() async {
    if (isLoadingOlder.value || !hasMore.value || messages.isEmpty) return;
    final oldest = messages.lastWhere(
      (m) => m.id != null,
      orElse: () => messages.last,
    );
    if (oldest.id == null) return;
    isLoadingOlder.value = true;
    try {
      final res = await _chatRepo.thread(beforeId: oldest.id);
      if (!res.isError && res.data != null) {
        final server = res.data!.messages.reversed.toList();
        messages.assignAll(_merge(messages.toList(), server));
        hasMore.value = res.data!.hasMore;
      }
    } finally {
      isLoadingOlder.value = false;
    }
  }

  /// Merges two newest-first lists, de-duplicating by server id and
  /// replacing temp bubbles with their confirmed versions.
  List<ChatMessage> _merge(
      List<ChatMessage> newer, List<ChatMessage> older) {
    final seen = <String>{};
    final out = <ChatMessage>[];
    for (final m in [...newer, ...older]) {
      final id = m.id != null ? 'id:${m.id}' : 'tmp:${m.tempId}';
      if (seen.add(id)) out.add(m);
    }
    // A temp bubble and its confirmation share nothing to key on, so drop
    // temps whose text/attachment already arrived confirmed.
    return out;
  }

  // ─── Realtime (Pusher, polling fallback) ──────────────────────────────────

  void _subscribeRealtime() {
    final convId = conversationId.value;
    if (convId == null) return;
    _liveSub?.cancel();
    _readSub?.cancel();
    final streams = ChatPusherService.instance.subscribe(convId);
    _liveSub = streams.messages.listen((msg) {
      if (msg.id != null &&
          messages.any((m) => m.id != null && '${m.id}' == '${msg.id}')) {
        return;
      }
      _pusherLive = true;
      if (!msg.isAdmin) {
        // Own echo (the backend also pushes to the sender despite the
        // docs): swap the sending temp instead of stacking a duplicate.
        final tempIdx = _findMatchingTemp(msg);
        if (tempIdx != -1) {
          messages[tempIdx] = msg;
          markReadIfVisible();
          return;
        }
      }
      messages.insert(0, msg);
      _scrollToBottom();
      markReadIfVisible();
    });
    _readSub = streams.reads.listen((receipt) {
      if (!receipt.readByAdmin) return;
      _pusherLive = true;
      final stamp =
          (receipt.readAt ?? '').isNotEmpty ? receipt.readAt : 'read';
      var changed = false;
      for (var i = 0; i < messages.length; i++) {
        final m = messages[i];
        if (m.isMe && !m.isRead) {
          messages[i] = m.copyWith(readAt: stamp);
          changed = true;
        }
      }
      if (changed) messages.refresh();
    });
    _ensurePolling();
  }

  /// Safety net while Pusher is not connected — the docs bless polling on
  /// the chat screen. Stops itself once realtime proves alive.
  void _ensurePolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_pusherLive || !Get.isRegistered<ChatController>()) return;
      await refreshFromPush();
      if (_pusherLive) _pollTimer?.cancel();
    });
  }

  /// Pulls everything newer than the newest held id (push/resume path).
  Future<void> refreshFromPush() async {
    try {
      final newest = messages.firstWhereOrNull((m) => m.id != null);
      final res =
          await _chatRepo.poll(afterId: newest?.id ?? conversationId.value ?? 0);
      if (res.isError || res.data == null) return;
      final incoming = res.data!.messages.reversed.toList();
      if (incoming.isEmpty) return;
      final known = messages
          .where((m) => m.id != null)
          .map((m) => '${m.id}')
          .toSet();
      final fresh =
          incoming.where((m) => !known.contains('${m.id}')).toList();
      if (fresh.isEmpty) return;
      messages.insertAll(0, fresh);
      _scrollToBottom();
      markReadIfVisible();
    } catch (_) {}
  }

  /// Resolver hook when a chat push arrives while already inside.
  void handleExternalPing() {
    refreshFromPush();
  }

  Future<void> markReadIfVisible() async {
    if (isMarkingRead.value) return;
    isMarkingRead.value = true;
    try {
      await _chatRepo.markRead();
    } finally {
      isMarkingRead.value = false;
    }
  }

  void _afterVisible() {
    markReadIfVisible();
  }

  // ─── Sending (optimistic + confirmed ticks) ───────────────────────────────

  String _tempId() => 'tmp_${DateTime.now().microsecondsSinceEpoch}';

  Future<void> sendText() async {
    final text = composer.text.trim();
    if (text.isEmpty) return;
    if (messages.isNotEmpty) {
      // Accidental double-tap: the identical temp is already sending.
      final first = messages.first;
      if (first.sendState == ChatSendState.sending &&
          first.hasText &&
          first.body!.trim() == text) {
        return;
      }
    }
    composer.clear();
    final temp = ChatMessage(
      tempId: _tempId(),
      conversationId: conversationId.value,
      isAdmin: false,
      body: text,
      createdAt: DateTime.now(),
      sendState: ChatSendState.sending,
    );
    messages.insert(0, temp);
    _scrollToBottom();
    final res = await _chatRepo.send(body: text);
    _resolveSend(temp, res);
  }

  Future<void> sendFiles(List<File> files) async {
    if (files.isEmpty) return;
    final caption = composer.text.trim();
    if (caption.isNotEmpty) composer.clear();
    final temp = ChatMessage(
      tempId: _tempId(),
      conversationId: conversationId.value,
      isAdmin: false,
      body: caption.isEmpty ? null : caption,
      createdAt: DateTime.now(),
      localPath: files.first.path,
      sendState: ChatSendState.sending,
    );
    messages.insert(0, temp);
    _scrollToBottom();
    final res = await _chatRepo.send(
      body: caption.isEmpty ? null : caption,
      attachments: files,
    );
    _resolveSend(temp, res);
  }

  Future<void> retrySend(ChatMessage failed) async {
    final index = messages.indexWhere((m) => m.tempId == failed.tempId);
    if (index == -1) return;
    messages[index] = failed.copyWith(sendState: ChatSendState.sending);
    ApiResponse<ChatMessage> res;
    if (failed.localPath != null && failed.body == null) {
      res = await _chatRepo.send(attachments: [File(failed.localPath!)]);
    } else {
      res = await _chatRepo.send(body: failed.body);
    }
    _resolveSend(messages[index], res);
  }

  /// Finds the optimistic temp a realtime echo confirms: same text for
  /// text messages, or the pending local media/voice for attachments.
  int _findMatchingTemp(ChatMessage confirmed) {
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (m.id != null || m.sendState != ChatSendState.sending) continue;
      if (confirmed.hasText && m.hasText && m.body!.trim() == confirmed.body!.trim()) {
        return i;
      }
      if (!confirmed.hasText &&
          (confirmed.attachments.isNotEmpty ||
              confirmed.voiceNote != null) &&
          m.localPath != null) {
        return i;
      }
    }
    return -1;
  }

  void _resolveSend(
      ChatMessage temp, ApiResponse<ChatMessage> res) {
    final index = messages.indexWhere((m) => m.tempId == temp.tempId);
    if (index == -1) {
      // Temp is gone — the realtime echo likely replaced it already.
      // Never insert the same server id twice.
      if (!res.isError && res.data != null) {
        final already = messages.any(
            (m) => m.id != null && '${m.id}' == '${res.data!.id}');
        if (!already) messages.insert(0, res.data!);
      }
      return;
    }
    if (!res.isError && res.data != null) {
      final confirmed = res.data!;
      final dupIdx = messages.indexWhere(
          (m) => m.id != null && '${m.id}' == '${confirmed.id}');
      if (dupIdx != -1 && dupIdx != index) {
        // Realtime delivered the confirmation first — drop the temp.
        messages.removeAt(index);
        return;
      }
      messages[index] = confirmed;
      final convId = res.data!.conversationId is int
          ? res.data!.conversationId as int
          : int.tryParse('${res.data!.conversationId}');
      if (convId != null && conversationId.value == null) {
        conversationId.value = convId;
        _subscribeRealtime();
      }
    } else {
      messages[index] = temp.copyWith(sendState: ChatSendState.failed);
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: (res.message?.isNotEmpty ?? false)
            ? res.message!
            : 'chat.send_failed'.trns(),
      );
    }
  }

  // ─── Attachments ──────────────────────────────────────────────────────────

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;
      await sendFiles([File(picked.path)]);
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'chat.media_failed'.trns(),
      );
    }
  }

  Future<void> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
      );
      if (result == null || result.files.isEmpty) return;
      final files = result.files
          .where((f) => (f.path ?? '').isNotEmpty)
          .take(5)
          .map((f) => File(f.path!))
          .toList();
      if (files.isEmpty) return;
      await sendFiles(files);
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'chat.media_failed'.trns(),
      );
    }
  }

  // ─── Voice notes ──────────────────────────────────────────────────────────

  Future<void> toggleRecording() async {
    if (isRecording.value) {
      await stopRecording(send: true);
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        SnackbarService.showError(
          title: 'common.error'.trns(),
          message: 'chat.mic_permission'.trns(),
        );
        return;
      }
      await stopPlayback();
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      _recordStartedAt = DateTime.now();
      isRecording.value = true;
      recordingSeconds.value = 0;
      _recordTimer?.cancel();
      _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        recordingSeconds.value =
            DateTime.now().difference(_recordStartedAt!).inSeconds;
        if (recordingSeconds.value >= 300) {
          stopRecording(send: true);
        }
      });
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'chat.record_failed'.trns(),
      );
    }
  }

  Future<void> stopRecording({required bool send}) async {
    _recordTimer?.cancel();
    if (!isRecording.value) return;
    isRecording.value = false;
    try {
      final path = await _recorder.stop();
      final seconds = _recordStartedAt == null
          ? 0
          : DateTime.now().difference(_recordStartedAt!).inSeconds;
      _recordStartedAt = null;
      if (!send || path == null || seconds < 1) return;
      final temp = ChatMessage(
        tempId: _tempId(),
        conversationId: conversationId.value,
        isAdmin: false,
        createdAt: DateTime.now(),
        localPath: path,
        sendState: ChatSendState.sending,
      );
      messages.insert(0, temp);
      _scrollToBottom();
      final res = await _chatRepo.send(
        voiceNote: File(path),
        voiceDuration: seconds.toDouble(),
      );
      _resolveSend(temp, res);
    } catch (_) {
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'chat.record_failed'.trns(),
      );
    }
  }

  Future<void> cancelRecording() => stopRecording(send: false);

  // ─── Voice playback ───────────────────────────────────────────────────────

  void _wirePlayer() {
    _playerStateSub = _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        stopPlayback();
      }
    });
    _positionSub = _player.positionStream.listen((pos) {
      playPosition.value = pos.inMilliseconds / 1000;
    });
    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) playDuration.value = dur.inMilliseconds / 1000;
    });
  }

  Future<void> toggleVoice(ChatMessage message) async {
    final key = message.voiceNote?.url ?? message.localPath ?? message.key;
    if (playingVoiceKey.value == key && isPlaying.value) {
      await _player.pause();
      return;
    }
    if (playingVoiceKey.value == key) {
      await _player.play();
      return;
    }
    await stopPlayback();
    try {
      final source = message.voiceNote?.url ?? message.localPath;
      if (source == null || source.isEmpty) return;
      playingVoiceKey.value = key;
      playPosition.value = 0;
      final hinted = message.voiceNote?.duration ?? 0;
      playDuration.value = hinted > 0 ? hinted : 1;
      if (source.startsWith('http')) {
        await _player.setUrl(source);
      } else {
        await _player.setFilePath(source);
      }
      await _player.play();
    } catch (_) {
      playingVoiceKey.value = null;
      SnackbarService.showError(
        title: 'common.error'.trns(),
        message: 'chat.play_failed'.trns(),
      );
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (_) {}
    playingVoiceKey.value = null;
    playPosition.value = 0;
  }

  // ─── Scrolling ────────────────────────────────────────────────────────────

  void _scrollToBottom({bool jump = false}) {
    if (!scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 150), () {
        _scrollToBottom(jump: jump);
      });
      return;
    }
    try {
      if (jump) {
        scrollController.jumpTo(0);
      } else {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    } catch (_) {}
  }

  void scrollToBottom() => _scrollToBottom();

  @override
  void onClose() {
    _pollTimer?.cancel();
    _recordTimer?.cancel();
    _liveSub?.cancel();
    _readSub?.cancel();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    try {
      _recorder.dispose();
    } catch (_) {}
    try {
      _player.dispose();
    } catch (_) {}
    final convId = conversationId.value;
    if (convId != null) {
      unawaited(ChatPusherService.instance.unsubscribe(convId));
    }
    // The FAB badge goes stale while chatting — refresh it on exit.
    if (Get.isRegistered<BottomnavController>()) {
      try {
        Get.find<BottomnavController>().refreshChatBadge();
      } catch (_) {}
    }
    composer.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
