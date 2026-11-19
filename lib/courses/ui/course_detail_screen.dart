import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/theme/lembar_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/formatting.dart';
import '../../shared/ui/lembar_widgets.dart';
import '../data/course.dart';
import '../state/course_providers.dart';
import 'course_components.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({
    super.key,
    required this.courseId,
    this.lessonUnavailable = false,
  });
  final String courseId;
  final bool lessonUnavailable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = AppLocalizations.of(context);
    final provider = courseProvider(courseId);
    final result = ref.watch(provider);
    final first = result.asData?.value.lessons.firstOrNull;
    final compact =
        MediaQuery.sizeOf(context).height < 500 ||
        MediaQuery.textScalerOf(context).scale(15) > 25;
    final start = first == null
        ? null
        : LembarButton(
            label: labels.startFirstLesson,
            icon: Icons.arrow_forward,
            onPressed: () =>
                LembarRoutes.openLesson(context, courseId, first.id),
          );
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: Column(
            children: [
              ScreenHeader(
                title: labels.catalogTitle,
                onBack: () => LembarRoutes.openCatalog(context),
              ),
              Expanded(
                child: RefreshableList(
                  scrollKey: PageStorageKey('course-$courseId'),
                  onRefresh: () async {
                    try {
                      ref.invalidate(provider);
                      await ref.read(provider.future);
                    } on Exception {
                      // The provider exposes failures through the list state.
                    }
                  },
                  padding: pageInsets.copyWith(top: 6, bottom: 16),
                  children: [
                    if (lessonUnavailable) ...[
                      Semantics(
                        liveRegion: true,
                        child: ColoredBox(
                          color: context.colors.selected,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(labels.lessonUnavailable),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    result.when(
                      skipLoadingOnRefresh: true,
                      loading: () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Bone(
                            height: 152,
                            radius: LembarMetrics.mediaRadius,
                          ),
                          const SizedBox(height: 22),
                          const Bone(width: 210, height: 34),
                          const SizedBox(height: 16),
                          const Bone(height: 15),
                          const SizedBox(height: 16),
                          Text(labels.detailLoading),
                        ],
                      ),
                      error: (error, _) => CourseLoadError(
                        error: error,
                        detail: true,
                        onCatalog: () => LembarRoutes.openCatalog(context),
                        onRetry: () => ref.invalidate(provider),
                      ),
                      data: (course) => _CourseContent(
                        course: course,
                        onSelect: (lesson) => LembarRoutes.openLesson(
                          context,
                          courseId,
                          lesson.id,
                        ),
                      ),
                    ),
                    if (compact && start != null) start,
                  ],
                ),
              ),
              if (!compact && start != null)
                Padding(
                  padding: pageInsets.copyWith(bottom: 8),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      start,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseContent extends StatelessWidget {
  const _CourseContent({required this.course, required this.onSelect});
  final Course course;
  final ValueChanged<Lesson> onSelect;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final data = course.summary;
    final muted = context.colors.muted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 350 / 152,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(LembarMetrics.mediaRadius),
            child: CourseCover(coverKey: data.coverKey),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          data.category.toUpperCase(),
          style: context.type.labelSmall?.copyWith(color: muted),
        ),
        const SizedBox(height: 8),
        Semantics(
          header: true,
          child: Text(data.title, style: context.type.headlineLarge),
        ),
        const SizedBox(height: 12),
        Text(
          course.description,
          style: context.type.bodyMedium?.copyWith(color: muted),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            _Meta(
              icon: Icons.layers_outlined,
              label: labels.lessonCount(data.lessonCount),
            ),
            if (data.lessonCount > 0)
              _Meta(
                icon: Icons.schedule,
                label: courseDuration(labels, data.duration),
              ),
          ],
        ),
        const SizedBox(height: 22),
        const Divider(height: 1),
        const SizedBox(height: 14),
        Semantics(
          header: true,
          child: Text(labels.lessonsTitle, style: context.type.titleLarge),
        ),
        const SizedBox(height: 12),
        if (course.lessons.isEmpty)
          StatusPanel(
            title: labels.courseEmpty,
            description: labels.courseEmptyBody,
            icon: Icons.video_library_outlined,
          )
        else
          LessonList(lessons: course.lessons, onSelect: onSelect),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 17),
      const SizedBox(width: 7),
      Flexible(child: Text(label, style: context.type.bodySmall)),
    ],
  );
}
