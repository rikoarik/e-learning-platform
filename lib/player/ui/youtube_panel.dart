import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../app/theme/lembar_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/lembar_widgets.dart';
import 'youtube_link.dart';

class YoutubePanel extends StatefulWidget {
  const YoutubePanel({super.key, required this.videoId, this.channel});
  final String videoId;
  final String? channel;

  @override
  State<YoutubePanel> createState() => _YoutubePanelState();
}

class _YoutubePanelState extends State<YoutubePanel> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _events;
  Timer? _timeout;
  MaterialPageRoute<void>? _nativeFullscreenRoute;
  late final AppLifecycleListener _lifecycle;
  bool _loading = true;
  bool _buffering = false;
  bool _failed = false;
  bool _landscapeRequested = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) {
        final player = _controller;
        if (state != AppLifecycleState.resumed && player != null && !_loading) {
          unawaited(_pause(player));
        }
      },
    );
    _load();
  }

  void _load() {
    final player = YoutubePlayerController(
      key: widget.videoId,
      params: const YoutubePlayerParams(
        origin: 'https://id.lembar.lembar',
        interfaceLanguage: 'id',
        captionLanguage: 'id',
        showControls: true,
        showFullscreenButton: true,
      ),
    );
    _controller = player;
    final webView = player.webViewController.platform;
    if (webView is AndroidWebViewController) {
      unawaited(
        webView.setCustomWidgetCallbacks(
          onShowCustomWidget: (view, exitFullscreen) {
            if (!mounted || _controller != player) {
              exitFullscreen();
              return;
            }
            _showNativeFullscreen(view, exitFullscreen);
          },
          onHideCustomWidget: () {
            if (_controller == player) _removeNativeFullscreen();
          },
        ),
      );
    }
    _timeout = Timer(
      const Duration(seconds: 24),
      () => _fail(player, 'initialization timeout'),
    );
    _events = player.stream.listen((value) {
      if (!mounted || _controller != player) return;
      _setFullscreenOrientation(
        _nativeFullscreenRoute != null || value.fullScreenOption.enabled,
      );
      if (value.hasError) {
        _fail(player, value.error);
        return;
      }
      if (value.playerState == PlayerState.unknown) return;
      if (_loading) _timeout?.cancel();
      final buffering = value.playerState == PlayerState.buffering;
      if (buffering && !_buffering) {
        _timeout = Timer(
          const Duration(seconds: 24),
          () => _fail(player, 'buffering timeout'),
        );
      } else if (!buffering) {
        _timeout?.cancel();
      }
      if (_loading || buffering != _buffering) {
        setState(() {
          _loading = false;
          _buffering = buffering;
        });
      }
      if (value.playerState == PlayerState.playing &&
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        unawaited(_pause(player));
      }
    });
    unawaited(_cue(player));
  }

  void _showNativeFullscreen(Widget view, VoidCallback exitFullscreen) {
    if (_nativeFullscreenRoute != null) {
      exitFullscreen();
      return;
    }
    final route = MaterialPageRoute<void>(
      builder: (_) => view,
      fullscreenDialog: true,
    );
    _nativeFullscreenRoute = route;
    _setFullscreenOrientation(true);
    unawaited(
      Navigator.of(context).push(route).then((_) {
        if (_nativeFullscreenRoute != route) return;
        _removeNativeFullscreen();
        exitFullscreen();
      }),
    );
  }

  void _removeNativeFullscreen() {
    final route = _nativeFullscreenRoute;
    if (route == null) return;
    _nativeFullscreenRoute = null;
    _setFullscreenOrientation(
      _controller?.value.fullScreenOption.enabled ?? false,
    );
    // The player can be disposed while the navigator is updating its routes.
    scheduleMicrotask(() {
      if (route.isActive) route.navigator?.removeRoute(route);
    });
  }

  void _setFullscreenOrientation(bool fullscreen) {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) ||
        _landscapeRequested == fullscreen) {
      return;
    }
    _landscapeRequested = fullscreen;
    unawaited(
      SystemChrome.setPreferredOrientations(
        fullscreen
            ? const [
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]
            : const [],
      ),
    );
  }

  Future<void> _cue(YoutubePlayerController player) async {
    try {
      await player.cueVideoById(videoId: widget.videoId);
    } on Exception catch (error) {
      _fail(player, error);
    }
  }

  Future<void> _pause(YoutubePlayerController player) async {
    try {
      await player.pauseVideo();
    } on Exception catch (error) {
      _fail(player, error);
    }
  }

  void _fail(YoutubePlayerController player, Object reason) {
    if (!mounted || _controller != player) return;
    assert(() {
      debugPrint('YouTube ${widget.videoId}: $reason');
      return true;
    }());
    _release();
    setState(() => _failed = true);
  }

  void _release() {
    _timeout?.cancel();
    final events = _events;
    _events = null;
    if (events != null) unawaited(events.cancel());
    final player = _controller;
    _controller = null;
    _removeNativeFullscreen();
    _setFullscreenOrientation(false);
    if (player != null) unawaited(_close(player));
  }

  Future<void> _close(YoutubePlayerController player) async {
    try {
      await player.close();
    } on Exception catch (error) {
      debugPrint('YouTube controller release: $error');
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final player = _controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (player != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(LembarMetrics.mediaRadius),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = math.max(200.0, constraints.maxWidth * 9 / 16);
                return YoutubePlayer(
                  key: ObjectKey(player),
                  controller: player,
                  backgroundColor: context.colors.videoPanel,
                  aspectRatio: constraints.maxWidth / height,
                  autoFullScreen: false,
                  enableFullScreenOnVerticalDrag: false,
                );
              },
            ),
          )
        else if (_failed)
          StatusPanel(
            title: labels.videoError,
            description: labels.videoErrorBody,
            icon: Icons.error_outline,
            actionLabel: labels.retry,
            onDark: true,
            onAction: () => setState(() {
              _failed = false;
              _loading = true;
              _buffering = false;
              _load();
            }),
          ),
        const SizedBox(height: 10),
        Semantics(
          liveRegion: _loading || _buffering,
          child: Text(
            _failed
                ? labels.youtubeBody
                : _loading
                ? labels.videoLoading
                : _buffering
                ? labels.videoBuffering
                : widget.channel == null
                ? labels.youtubeSource
                : labels.youtubeCredit(widget.channel!),
            style: context.type.bodySmall?.copyWith(
              color: context.colors.muted,
            ),
          ),
        ),
        const SizedBox(height: 8),
        YoutubeLink(videoId: widget.videoId, label: labels.openYouTube),
      ],
    );
  }
}
