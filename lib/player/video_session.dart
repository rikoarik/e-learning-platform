import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';

import '../courses/data/course.dart';

class VideoSession extends ChangeNotifier {
  VideoPlayerController? _controller;
  var _release = Future<void>.value();
  var _generation = 0;
  var _disposed = false;
  var _foreground = true;
  var _initialized = false;
  var _failed = false;
  var _lastPosition = Duration.zero;

  VideoPlayerController? get controller => _initialized ? _controller : null;
  VideoPlayerValue? get value => controller?.value;
  bool get initializing => !_initialized && !_failed;
  bool get failed => _failed || (_controller?.value.hasError ?? false);

  Future<void> open(Lesson lesson, {bool resumePosition = false}) async {
    if (_disposed) return;
    final generation = ++_generation;
    final resumeAt = resumePosition ? _lastPosition : Duration.zero;
    _lastPosition = resumeAt;
    _initialized = false;
    _failed = false;
    _detachController();
    notifyListeners();

    await _release;
    if (!_isCurrent(generation)) return;
    try {
      // The screen owns pausing and requires an explicit Play after resuming.
      final options = VideoPlayerOptions(allowBackgroundPlayback: true);
      final uri = lesson.videoUri;
      final media = uri == null
          ? VideoPlayerController.asset(
              lesson.videoAsset!,
              videoPlayerOptions: options,
            )
          : VideoPlayerController.networkUrl(uri, videoPlayerOptions: options);
      _controller = media;
      media.addListener(_onControllerChange);
      await media.initialize().timeout(const Duration(seconds: 20));
      if (!_isCurrent(generation)) return;
      if (resumeAt > Duration.zero) {
        await media.seekTo(_clamp(resumeAt, media.value.duration));
      }
      if (!_isCurrent(generation)) return;
      _initialized = true;
      notifyListeners();
    } catch (error) {
      if (!_isCurrent(generation)) return;
      _fail(error);
    }
  }

  Future<void> toggle() async {
    final media = controller;
    if (media == null || failed || !_foreground) return;
    final generation = _generation;
    await _run(generation, () async {
      if (media.value.isPlaying) {
        await media.pause();
        return;
      }
      if (media.value.isCompleted ||
          media.value.position >= media.value.duration) {
        await media.seekTo(Duration.zero);
      }
      if (_isCurrent(generation) && _foreground) await media.play();
    });
  }

  Future<void> seek(Duration requested) async {
    final media = controller;
    if (media == null || failed) return;
    await _run(
      _generation,
      () => media.seekTo(_clamp(requested, media.value.duration)),
    );
  }

  Future<void> skip(Duration amount) async {
    final position = value?.position;
    if (position != null) await seek(position + amount);
  }

  void setForeground(bool active) {
    _foreground = active;
    final media = _controller;
    if (!active && (media?.value.isPlaying ?? false)) {
      unawaited(_run(_generation, media!.pause));
    }
  }

  Future<void> _run(int generation, Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (_isCurrent(generation)) _fail(error);
    }
  }

  void _fail(Object error) {
    ++_generation;
    _initialized = false;
    _failed = true;
    _detachController();
    if (kDebugMode) debugPrint('Lesson playback: $error');
    notifyListeners();
  }

  void _onControllerChange() {
    final media = _controller;
    if (_disposed || media == null) return;
    final value = media.value;
    if (value.hasError) {
      _fail(StateError(value.errorDescription ?? 'Playback error'));
      return;
    }
    if (!_initialized) return;
    _lastPosition = value.position;
    notifyListeners();
  }

  bool _isCurrent(int generation) => !_disposed && generation == _generation;

  void _detachController() {
    final previous = _controller;
    if (previous == null) return;
    previous.removeListener(_onControllerChange);
    _controller = null;
    _release = _release
        .then((_) async {
          try {
            if (previous.value.isInitialized && previous.value.isPlaying) {
              await previous.pause();
            }
          } finally {
            await previous.dispose();
          }
        })
        .catchError((Object error, StackTrace stack) {
          if (kDebugMode) debugPrint('Video controller release: $error');
        });
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _detachController();
    super.dispose();
  }
}

Duration _clamp(Duration position, Duration end) {
  if (position < Duration.zero) return Duration.zero;
  if (position > end) return end;
  return position;
}
