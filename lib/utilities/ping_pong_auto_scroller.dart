import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Smooth marquee-style ping-pong auto-scroll for a horizontal [ListView].
///
/// Driven by a vsync ticker (one tiny step every frame, scaled by the real
/// frame delta), so motion is butter-smooth like a website marquee instead
/// of ticking on a coarse timer. The list drifts in one direction and
/// gracefully reverses at each end.
///
/// It never fights the user: finger drags/flings are observed through
/// [handleNotification] (wire it to a [NotificationListener] around the
/// list) and the drift pauses, resuming only after [resumeDelay] of
/// complete calm.
///
/// Every frame is defensively guarded (attached clients, laid-out content,
/// positive scroll range, disposal races) so this is a no-op — never a
/// crash — for short/empty lists, rebuilds, or dead controllers.
class PingPongAutoScroller {
  PingPongAutoScroller({
    required this.vsync,
    this.pixelsPerSecond = 60.0,
    this.resumeDelay = const Duration(seconds: 2),
  });

  final TickerProvider vsync;

  /// Drift speed in logical pixels per second (~100–140 reads as marquee).
  final double pixelsPerSecond;

  /// Idle time after the last user scroll before drifting resumes.
  final Duration resumeDelay;

  final ScrollController scrollController = ScrollController();

  Ticker? _ticker;
  bool _forward = true;
  bool _disposed = false;
  bool _userHolding = false;
  DateTime? _resumeAt;
  Duration? _lastElapsed;

  /// Starts the drift loop. Safe to call once from `onInit`.
  void start() {
    if (_disposed || _ticker != null) return;
    _ticker = vsync.createTicker(_onTick)..start();
  }

  /// Feed scroll notifications from a [NotificationListener] wrapping the
  /// list. Returns false so notifications keep bubbling.
  ///
  /// Only a real finger drag pauses the drift: a [ScrollEndNotification]
  /// is honored solely when a drag-start was seen first. This matters
  /// because `ScrollController.jumpTo` itself dispatches a full
  /// start/update/end sequence every call — honoring its end
  /// unconditionally re-arms the pause on every frame and the marquee
  /// degrades to one step per [resumeDelay] (clock ticking).
  bool handleNotification(ScrollNotification notification) {
    if (_disposed) return false;
    if (notification.depth != 0) return false;
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      _userHolding = true;
    } else if (notification is ScrollEndNotification) {
      if (_userHolding) {
        _userHolding = false;
        _resumeAt = DateTime.now().add(resumeDelay);
      }
    }
    return false;
  }

  void _onTick(Duration elapsed) {
    if (_disposed) return;
    final last = _lastElapsed;
    _lastElapsed = elapsed;
    if (last == null) return;
    // Real frame delta, clamped so jank/background gaps never teleport.
    final dt = (elapsed - last).inMicroseconds / Duration.microsecondsPerSecond;
    if (dt <= 0 || dt > 0.1) return;
    if (_userHolding) return;
    if (_resumeAt != null && DateTime.now().isBefore(_resumeAt!)) return;
    if (!scrollController.hasClients) return;
    ScrollPosition position;
    try {
      position = scrollController.position;
    } catch (_) {
      // Detached between the hasClients check and the read.
      return;
    }
    // Not laid out yet (first frames, hidden subtree).
    if (!position.hasContentDimensions || !position.hasPixels) return;
    // Mid overscroll from a user fling — leave it alone.
    if (position.outOfRange) return;

    final max = position.maxScrollExtent;
    // Nothing to scroll (short/empty list).
    if (max <= 0) return;

    final step = pixelsPerSecond * dt;
    var next = position.pixels + (_forward ? step : -step);

    if (next >= max) {
      next = max;
      _forward = false;
    } else if (next <= position.minScrollExtent) {
      next = position.minScrollExtent;
      _forward = true;
    }
    next = next.clamp(position.minScrollExtent, max);

    try {
      scrollController.jumpTo(next);
    } catch (_) {
      // Controller detached/disposed mid-frame — ignore.
    }
  }

  /// Stops the loop and disposes the ticker + scroll controller.
  void dispose() {
    _disposed = true;
    try {
      _ticker?.stop();
    } catch (_) {
      // Already stopped — ignore.
    }
    try {
      _ticker?.dispose();
    } catch (_) {
      // Already disposed (e.g. by the provider mixin) — ignore.
    }
    _ticker = null;
    try {
      scrollController.dispose();
    } catch (_) {
      // Already disposed — ignore.
    }
  }
}
