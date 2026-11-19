import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../app/theme/lembar_theme.dart';
import '../../courses/data/course.dart';
import '../../courses/ui/course_components.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/formatting.dart';
import '../../shared/ui/lembar_widgets.dart';
import '../video_session.dart';

class VideoPanel extends StatelessWidget {
  const VideoPanel({
    super.key,
    required this.lesson,
    required this.coverKey,
    required this.session,
  });
  final Lesson lesson;
  final String coverKey;
  final VideoSession session;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: session,
    builder: (context, _) {
      final labels = AppLocalizations.of(context);
      if (session.failed) {
        return StatusPanel(
          title: labels.videoError,
          description: labels.videoErrorBody,
          icon: Icons.error_outline,
          actionLabel: labels.retry,
          onDark: true,
          onAction: () => unawaited(session.open(lesson, resumePosition: true)),
        );
      }
      final value = session.value;
      final duration = value?.duration ?? lesson.duration;
      final position = value?.position ?? Duration.zero;
      final playing = value?.isPlaying ?? false;
      final completed = value?.isCompleted ?? false;
      final buffering = value?.isBuffering ?? false;
      final colors = context.colors;
      final presentation = (session.initializing || buffering)
          ? _MediaProgress(
              label: session.initializing
                  ? labels.videoLoading
                  : labels.videoBuffering,
            )
          : _MediaStage(
              controller: session.controller,
              coverKey: coverKey,
              lesson: lesson,
              showPoster: !playing && position == Duration.zero && !completed,
              completed: completed,
              onPlay: () => unawaited(session.toggle()),
            );
      return ClipRRect(
        borderRadius: BorderRadius.circular(LembarMetrics.mediaRadius),
        child: ColoredBox(
          color: colors.videoPanel,
          child: Column(
            children: [
              AspectRatio(aspectRatio: 16 / 9, child: presentation),
              _Transport(
                key: ValueKey(lesson.id),
                duration: duration,
                position: position,
                enabled: !session.initializing && !buffering,
                onPauseOrPlay: () => unawaited(session.toggle()),
                onSeek: (position) => unawaited(session.seek(position)),
                onSkip: (amount) => unawaited(session.skip(amount)),
                playing: playing,
                completed: completed,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MediaStage extends StatelessWidget {
  const _MediaStage({
    required this.controller,
    required this.coverKey,
    required this.lesson,
    required this.showPoster,
    required this.completed,
    required this.onPlay,
  });
  final VideoPlayerController? controller;
  final String coverKey;
  final Lesson lesson;
  final bool showPoster;
  final bool completed;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final video = controller;
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.center,
      children: [
        if (showPoster || video == null)
          _LessonPoster(lesson: lesson, coverKey: coverKey)
        else
          Center(
            child: AspectRatio(
              aspectRatio: video.value.aspectRatio,
              child: VideoPlayer(video),
            ),
          ),
        if (showPoster || completed)
          Align(
            alignment: coverKey == 'design' && showPoster
                ? const Alignment(0.55, 0)
                : Alignment.center,
            child: _PlaybackButton(
              label: completed ? labels.replay : labels.play,
              icon: completed ? Icons.replay : Icons.play_arrow_rounded,
              primary: true,
              onPressed: onPlay,
            ),
          ),
      ],
    );
  }
}

class _LessonPoster extends StatelessWidget {
  const _LessonPoster({required this.lesson, required this.coverKey});
  final Lesson lesson;
  final String coverKey;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (coverKey != 'design') return CourseCover(coverKey: coverKey);
    return ColoredBox(
      color: colors.videoPoster,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: Image.asset(
              'assets/brand/lesson-editor.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.46,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: ExcludeSemantics(
                  child: Text(
                    lesson.title,
                    style: context.type.headlineMedium?.copyWith(
                      color: colors.onDark,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaProgress extends StatelessWidget {
  const _MediaProgress({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.colors.videoControl,
    child: Center(
      child: Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.colors.action,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: context.type.bodySmall?.copyWith(
                color: context.colors.onVideo,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _Transport extends StatefulWidget {
  const _Transport({
    super.key,
    required this.duration,
    required this.position,
    required this.enabled,
    required this.onPauseOrPlay,
    required this.onSeek,
    required this.onSkip,
    required this.playing,
    required this.completed,
  });
  final Duration duration;
  final Duration position;
  final bool enabled;
  final VoidCallback onPauseOrPlay;
  final ValueChanged<Duration> onSeek;
  final ValueChanged<Duration> onSkip;
  final bool playing;
  final bool completed;

  @override
  State<_Transport> createState() => _TransportState();
}

class _TransportState extends State<_Transport> {
  static const tenSeconds = Duration(seconds: 10);
  double? _drag;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    final end = widget.duration.inMilliseconds <= 0
        ? 1.0
        : widget.duration.inMilliseconds.toDouble();
    final position = (_drag ?? widget.position.inMilliseconds.toDouble()).clamp(
      0.0,
      end,
    );
    final timestamp = playbackTime(Duration(milliseconds: position.round()));
    final timeStyle = context.type.labelSmall?.copyWith(color: colors.onVideo);
    final action = widget.completed
        ? labels.replay
        : widget.playing
        ? labels.pause
        : labels.play;
    final icon = widget.completed
        ? Icons.replay
        : widget.playing
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: colors.action,
              inactiveTrackColor: colors.videoTrack,
              thumbColor: colors.action,
              overlayColor: colors.action.withValues(alpha: 0.16),
              disabledActiveTrackColor: colors.videoTrack,
              disabledInactiveTrackColor: colors.videoControl,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 5,
                disabledThumbRadius: 4,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 13),
              padding: EdgeInsets.zero,
            ),
            child: Semantics(
              label: labels.seek,
              child: Slider(
                value: position,
                max: end,
                semanticFormatterCallback: (value) =>
                    playbackTime(Duration(milliseconds: value.round())),
                onChanged: widget.enabled
                    ? (value) => setState(() => _drag = value)
                    : null,
                onChangeEnd: widget.enabled
                    ? (value) {
                        widget.onSeek(Duration(milliseconds: value.round()));
                        setState(() => _drag = null);
                      }
                    : null,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timestamp, style: timeStyle),
              Text(playbackTime(widget.duration), style: timeStyle),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PlaybackButton(
                label: labels.backTen,
                icon: Icons.replay_10,
                onPressed: widget.enabled
                    ? () => widget.onSkip(-tenSeconds)
                    : null,
              ),
              const SizedBox(width: 12),
              _PlaybackButton(
                label: action,
                icon: icon,
                primary: true,
                onPressed: widget.enabled ? widget.onPauseOrPlay : null,
              ),
              const SizedBox(width: 12),
              _PlaybackButton(
                label: labels.forwardTen,
                icon: Icons.forward_10,
                onPressed: widget.enabled
                    ? () => widget.onSkip(tenSeconds)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaybackButton extends StatelessWidget {
  const _PlaybackButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton.filled(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: primary ? colors.action : colors.videoControl,
        foregroundColor: primary ? colors.ink : colors.onVideo,
        disabledBackgroundColor: colors.videoControl,
        disabledForegroundColor: colors.videoTrack,
        minimumSize: const Size.square(LembarMetrics.tap),
      ),
      icon: Icon(icon, size: 24),
    );
  }
}
