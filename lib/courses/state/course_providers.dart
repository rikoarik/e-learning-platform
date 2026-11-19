import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/course.dart';
import '../data/course_repository.dart';

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => AssetCourseRepository(
    bundle: rootBundle,
    videoBaseUrl: const String.fromEnvironment('LESSON_VIDEO_BASE_URL'),
  ),
);

final catalogProvider = FutureProvider.autoDispose<List<CourseSummary>>(
  (ref) => ref.watch(courseRepositoryProvider).listCourses(),
);

final courseProvider = FutureProvider.autoDispose.family<Course, String>(
  (ref, id) => ref.watch(courseRepositoryProvider).getCourse(id),
);
