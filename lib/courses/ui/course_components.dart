import 'package:flutter/material.dart';

import '../../app/theme/lembar_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/formatting.dart';
import '../../shared/ui/lembar_widgets.dart';
import '../data/course.dart';
import '../data/course_repository.dart';

class CourseCover extends StatelessWidget {
  const CourseCover({super.key, required this.coverKey});

  final String coverKey;

  static const _assets = {
    'design': 'assets/course-covers/desain-ui.jpg',
    'photo': 'assets/course-covers/fotografi-ponsel.jpg',
    'writing': 'assets/course-covers/menulis-web.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _assets[coverKey];
    final fallback = ColoredBox(
      color: context.colors.selected,
      child: Center(
        child: Icon(Icons.layers_outlined, color: context.colors.muted),
      ),
    );
    return ExcludeSemantics(
      child: asset == null
          ? fallback
          : Image.asset(
              asset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
    );
  }
}

class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(label.toUpperCase(), style: context.type.labelSmall),
    ),
  );
}

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.onOpen,
    this.featured = false,
  });

  final CourseSummary course;
  final VoidCallback onOpen;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    final metadata = labels.courseMetadata(
      labels.lessonCount(course.lessonCount),
      courseDuration(labels, course.duration),
    );
    final border = BorderRadius.circular(
      featured ? LembarMetrics.cardRadius : LembarMetrics.smallRadius,
    );
    return Semantics(
      label: labels.openCourse(course.title),
      button: true,
      child: Material(
        color: featured ? colors.ink : colors.surface,
        borderRadius: border,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: border,
          onTap: onOpen,
          child: featured
              ? _featured(context, metadata)
              : _compact(context, metadata),
        ),
      ),
    );
  }

  Widget _featured(BuildContext context, String metadata) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 350 / 178,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CourseCover(coverKey: course.coverKey),
              Positioned(
                left: 14,
                top: 14,
                child: CategoryTag(label: course.category),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course.title,
                style: context.type.headlineMedium?.copyWith(
                  color: colors.onDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                course.summary,
                style: context.type.bodySmall?.copyWith(color: colors.onVideo),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      metadata.toUpperCase(),
                      style: context.type.labelSmall?.copyWith(
                        color: colors.onVideo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.action,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox.square(
                      dimension: LembarMetrics.tap,
                      child: Icon(
                        Icons.north_east,
                        color: colors.ink,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _compact(BuildContext context, String metadata) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        SizedBox.square(
          dimension: 74,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CourseCover(coverKey: course.coverKey),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title, style: context.type.titleMedium),
              const SizedBox(height: 4),
              Text(
                course.summary,
                style: context.type.bodySmall?.copyWith(
                  color: context.colors.muted,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                metadata.toUpperCase(),
                style: context.type.labelSmall?.copyWith(
                  color: context.colors.muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.north_east, size: 18),
      ],
    ),
  );
}

enum LessonRowState { available, selected, playing }

class LessonRow extends StatelessWidget {
  const LessonRow({
    super.key,
    required this.lesson,
    required this.onTap,
    this.state = LessonRowState.available,
  });

  final Lesson lesson;
  final VoidCallback? onTap;
  final LessonRowState state;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final colors = context.colors;
    final active = state != LessonRowState.available;
    final radius = BorderRadius.circular(LembarMetrics.smallRadius);
    return Semantics(
      selected: active,
      button: true,
      child: Material(
        color: active ? colors.selected : colors.surface,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  SizedBox.square(
                    dimension: 36,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: active ? colors.ink : colors.slot,
                        borderRadius: radius,
                      ),
                      child: Center(
                        child: active
                            ? Icon(
                                Icons.play_arrow_rounded,
                                color: colors.action,
                              )
                            : Text(
                                twoDigits(lesson.order),
                                style: context.type.labelSmall?.copyWith(
                                  color: colors.muted,
                                  fontSize: 10,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: context.type.bodySmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (active)
                          Text(
                            (state == LessonRowState.playing
                                    ? labels.playing
                                    : labels.selected)
                                .toUpperCase(),
                            style: context.type.labelSmall?.copyWith(
                              color: colors.muted,
                              fontSize: 9,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    playbackTime(lesson.duration),
                    style: context.type.labelSmall?.copyWith(
                      color: colors.muted,
                    ),
                  ),
                  if (!active) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.chevron_right, color: colors.muted, size: 17),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LessonList extends StatelessWidget {
  const LessonList({
    super.key,
    required this.lessons,
    required this.onSelect,
    this.activeId,
    this.playing = false,
  });

  final List<Lesson> lessons;
  final ValueChanged<Lesson> onSelect;
  final String? activeId;
  final bool playing;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final lesson in lessons) ...[
        LessonRow(
          lesson: lesson,
          state: lesson.id == activeId
              ? playing
                    ? LessonRowState.playing
                    : LessonRowState.selected
              : LessonRowState.available,
          onTap: lesson.id == activeId ? null : () => onSelect(lesson),
        ),
        if (lesson.id != activeId)
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Divider(height: 1),
          ),
        const SizedBox(height: 4),
      ],
    ],
  );
}

class CourseLoadError extends StatelessWidget {
  const CourseLoadError({
    super.key,
    required this.error,
    required this.onRetry,
    this.onCatalog,
    this.detail = false,
  });

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback? onCatalog;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final labels = AppLocalizations.of(context);
    final failure = error is CourseException
        ? (error as CourseException).failure
        : null;
    return switch (failure) {
      CourseFailure.notFound when onCatalog != null => StatusPanel(
        title: labels.courseUnavailable,
        description: labels.courseUnavailableBody,
        icon: Icons.layers_outlined,
        actionLabel: labels.goToCatalog,
        actionIcon: Icons.arrow_forward,
        onAction: onCatalog,
      ),
      CourseFailure.offline => StatusPanel(
        title: labels.offline,
        description: labels.offlineBody,
        icon: Icons.wifi_off,
        actionLabel: labels.retry,
        onAction: onRetry,
      ),
      _ => StatusPanel(
        title: labels.courseError,
        description: detail ? labels.detailErrorBody : labels.catalogErrorBody,
        icon: Icons.error_outline,
        actionLabel: labels.retry,
        onAction: onRetry,
      ),
    };
  }
}
