import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/student_screens.dart';
import '../courses/ui/catalog_screen.dart';
import '../courses/ui/course_detail_screen.dart';
import '../l10n/app_localizations.dart';
import '../player/ui/lesson_screen.dart';
import '../shared/ui/lembar_widgets.dart';
import 'navigation.dart';
import 'ui/main_tabs.dart';

GoRouter createRouter({
  required bool Function() isSignedIn,
  required String initialLocation,
}) {
  final root = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: root,
    initialLocation: initialLocation,
    redirect: (_, state) {
      final onLogin = state.matchedLocation == '/login';
      if (!isSignedIn() && !onLogin) {
        return Uri(
          path: '/login',
          queryParameters: {
            if (state.uri.path.startsWith('/courses/'))
              'from': state.uri.toString(),
          },
        ).toString();
      }
      if (isSignedIn() && onLogin) {
        final from = Uri.tryParse(state.uri.queryParameters['from'] ?? '');
        final allowed =
            from != null &&
            !from.hasScheme &&
            !from.hasAuthority &&
            from.path.startsWith('/courses/');
        return allowed ? from.toString() : '/courses';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, _) => const SignInScreen()),
      ShellRoute(
        builder: (_, state, child) =>
            MainTabs(showAccount: state.uri.path == '/account', child: child),
        routes: [
          GoRoute(
            path: '/account',
            name: LembarRoutes.account,
            builder: (_, _) => const AccountScreen(),
          ),
          GoRoute(
            path: '/courses',
            name: LembarRoutes.catalog,
            builder: (_, _) => const CatalogScreen(),
            routes: [
              GoRoute(
                parentNavigatorKey: root,
                path: ':${LembarRoutes.courseId}',
                name: LembarRoutes.course,
                builder: (_, state) => CourseDetailScreen(
                  courseId: state.pathParameters[LembarRoutes.courseId]!,
                  lessonUnavailable:
                      state.uri.queryParameters[LembarRoutes.notice] ==
                      LembarRoutes.missingLesson,
                ),
                routes: [
                  GoRoute(
                    parentNavigatorKey: root,
                    path: 'lessons/:${LembarRoutes.lessonId}',
                    name: LembarRoutes.lesson,
                    builder: (_, state) => LessonScreen(
                      courseId: state.pathParameters[LembarRoutes.courseId]!,
                      lessonId: state.pathParameters[LembarRoutes.lessonId]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, _) {
      final labels = AppLocalizations.of(context);
      return Scaffold(
        body: SafeArea(
          child: ContentWidth(
            child: ListView(
              padding: pageInsets.copyWith(top: 20),
              children: [
                StatusPanel(
                  title: labels.routeUnavailable,
                  description: labels.routeUnavailableBody,
                  icon: Icons.info_outline,
                  actionLabel: labels.goToCatalog,
                  onAction: () => LembarRoutes.openCatalog(context),
                  actionIcon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
