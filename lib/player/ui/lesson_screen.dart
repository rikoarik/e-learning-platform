import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/theme/lembar_theme.dart';
import '../../courses/data/course.dart';
import '../../courses/state/course_providers.dart';
import '../../courses/ui/course_components.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/formatting.dart';
import '../../shared/ui/lembar_widgets.dart';
import '../video_session.dart';
import 'video_panel.dart';
import 'youtube_link.dart';
import 'youtube_panel.dart';

class LessonScreen extends ConsumerWidget {
  const LessonScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = courseProvider(courseId);
    final labels = AppLocalizations.of(context);
    final state = ref.watch(provider);
    void toDetail() => LembarRoutes.openCourse(context, courseId);
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            children: [
              ScreenHeader(
                title: state.asData?.value.summary.title ?? labels.lessonsTitle,
                onBack: toDetail,
              ),
              Expanded(
                child: state.when(
                  skipLoadingOnRefresh: false,
                  loading: () => ListView(
                    padding: pageInsets,
                    children: [
                      const Bone(
                        height: 196,
                        radius: LembarMetrics.mediaRadius,
                      ),
                      const SizedBox(height: 16),
                      Text(labels.detailLoading),
                    ],
                  ),
                  error: (error, _) => ListView(
                    padding: pageInsets,
                    children: [
                      CourseLoadError(
                        error: error,
                        detail: true,
                        onRetry: () => ref.invalidate(provider),
                        onCatalog: () => LembarRoutes.openCatalog(context),
                      ),
                    ],
                  ),
                  data: (course) {
                    final lesson = course.lessonById(lessonId);
                    if (lesson == null) {
                      return _MissingLesson(courseId: courseId);
                    }
                    return _LessonContent(
                      key: ValueKey(lesson.youtubeVideoId),
                      course: course,
                      lesson: lesson,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingLesson extends StatefulWidget {
  const _MissingLesson({required this.courseId});
  final String courseId;

  @override
  State<_MissingLesson> createState() => _MissingLessonState();
}

class _MissingLessonState extends State<_MissingLesson> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        LembarRoutes.openCourse(
          context,
          widget.courseId,
          lessonUnavailable: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: pageInsets,
    child: Text(AppLocalizations.of(context).lessonUnavailable),
  );
}

class _LessonContent extends StatefulWidget {
  const _LessonContent({super.key, required this.course, required this.lesson});
  final Course course;
  final Lesson lesson;
  @override
  State<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends State<_LessonContent> {
  final _video = VideoSession();
  late final AppLifecycleListener _lifecycle;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onStateChange: (state) =>
          _video.setForeground(state == AppLifecycleState.resumed),
    );
    final state = WidgetsBinding.instance.lifecycleState;
    _video.setForeground(state == null || state == AppLifecycleState.resumed);
    if (widget.lesson.youtubeVideoId == null) {
      unawaited(_video.open(widget.lesson));
    }
  }

  @override
  void didUpdateWidget(covariant _LessonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.id != widget.lesson.id ||
        oldWidget.lesson.videoUri != widget.lesson.videoUri ||
        oldWidget.lesson.videoAsset != widget.lesson.videoAsset) {
      unawaited(_video.open(widget.lesson));
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _video.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final lesson = widget.lesson;
    final course = widget.course;
    return ListView(
      controller: _scroll,
      padding: pageInsets.copyWith(top: 6, bottom: 20),
      children: [
        if (lesson.youtubeVideoId case final videoId?)
          YoutubePanel(videoId: videoId, channel: lesson.youtubeChannel)
        else
          VideoPanel(
            lesson: lesson,
            coverKey: course.summary.coverKey,
            session: _video,
          ),
        const SizedBox(height: 18),
        Text(
          labels
              .lessonOrdinal(
                twoDigits(lesson.order),
                twoDigits(course.lessons.length),
              )
              .toUpperCase(),
          style: context.type.labelSmall?.copyWith(color: context.colors.muted),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(lesson.title, style: context.type.headlineMedium),
        ),
        const SizedBox(height: 10),
        Text(
          lesson.description,
          style: context.type.bodyMedium?.copyWith(color: context.colors.muted),
        ),
        if (lesson.youtubeReferenceId case final reference?) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: YoutubeLink(
              videoId: reference,
              label: labels.youtubeReference,
            ),
          ),
        ],
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        Semantics(
          header: true,
          child: Text(labels.lessonsTitle, style: context.type.titleLarge),
        ),
        const SizedBox(height: 8),
        ListenableBuilder(
          listenable: _video,
          builder: (_, _) => LessonList(
            lessons: course.lessons,
            activeId: lesson.id,
            playing: _video.value?.isPlaying ?? false,
            onSelect: (item) =>
                LembarRoutes.openLesson(context, course.summary.id, item.id),
          ),
        ),
      ],
    );
  }
}
