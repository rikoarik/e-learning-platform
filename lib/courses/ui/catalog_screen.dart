import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/navigation.dart';
import '../../app/theme/lembar_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/lembar_widgets.dart';
import '../state/course_providers.dart';
import 'course_components.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = AppLocalizations.of(context);
    final result = ref.watch(catalogProvider);
    return Scaffold(
      body: SafeArea(
        child: ContentWidth(
          child: RefreshableList(
            scrollKey: const PageStorageKey('catalog-scroll'),
            onRefresh: () async {
              try {
                ref.invalidate(catalogProvider);
                await ref.read(catalogProvider.future);
              } on Exception {
                // The provider exposes failures through the list state.
              }
            },
            padding: pageInsets.copyWith(top: 8, bottom: 24),
            children: [
              const LembarWordmark(),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        labels.catalogTitle,
                        style: context.type.displayMedium,
                      ),
                    ),
                  ),
                  if (result.asData?.value case final courses?)
                    CategoryTag(label: labels.courseCount(courses.length)),
                ],
              ),
              const SizedBox(height: 24),
              ...result.when(
                skipLoadingOnRefresh: true,
                loading: () => [
                  const Bone(height: 306, radius: LembarMetrics.cardRadius),
                  const SizedBox(height: 16),
                  Text(labels.catalogLoading, style: context.type.bodySmall),
                ],
                error: (error, _) => [
                  CourseLoadError(
                    error: error,
                    onRetry: () => ref.invalidate(catalogProvider),
                  ),
                ],
                data: (courses) {
                  if (courses.isEmpty) {
                    return [
                      StatusPanel(
                        title: labels.catalogEmpty,
                        description: labels.catalogEmptyBody,
                        icon: Icons.layers_outlined,
                      ),
                    ];
                  }
                  return [
                    CourseCard(
                      course: courses.first,
                      featured: true,
                      onOpen: () =>
                          LembarRoutes.openCourse(context, courses.first.id),
                    ),
                    if (courses.length > 1) ...[
                      const SizedBox(height: 32),
                      Semantics(
                        header: true,
                        child: Text(
                          labels.otherCourses,
                          style: context.type.titleLarge,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final (index, course)
                          in courses.skip(1).indexed) ...[
                        if (index > 0) const Divider(height: 1),
                        CourseCard(
                          course: course,
                          onOpen: () =>
                              LembarRoutes.openCourse(context, course.id),
                        ),
                      ],
                    ],
                  ];
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
