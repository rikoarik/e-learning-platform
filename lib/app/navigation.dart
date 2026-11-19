import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

abstract final class LembarRoutes {
  static const catalog = 'catalog';
  static const account = 'account';
  static const course = 'course';
  static const lesson = 'lesson';
  static const courseId = 'courseId';
  static const lessonId = 'lessonId';
  static const notice = 'notice';
  static const missingLesson = 'lesson-unavailable';

  static void openCatalog(BuildContext context) => context.goNamed(catalog);

  static void openCourse(
    BuildContext context,
    String id, {
    bool lessonUnavailable = false,
  }) => context.goNamed(
    course,
    pathParameters: {courseId: id},
    queryParameters: {if (lessonUnavailable) notice: missingLesson},
  );

  static void openLesson(BuildContext context, String course, String lesson) =>
      context.goNamed(
        LembarRoutes.lesson,
        pathParameters: {courseId: course, lessonId: lesson},
      );
}
