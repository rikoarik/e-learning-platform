import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart'
    show NavigationBar, TextField, ListView, Scrollable, SizedBox, Widget;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lembar/auth/demo_session.dart';
import 'package:lembar/courses/data/course.dart';
import 'package:lembar/courses/data/course_repository.dart';
import 'package:lembar/courses/state/course_providers.dart';
import 'package:lembar/courses/ui/course_detail_screen.dart';
import 'package:lembar/main.dart';

void main() {
  final fixture = File('assets/data/courses.json').readAsStringSync();
  final repository = AssetCourseRepository(bundle: _FixtureBundle(fixture));

  Widget app([String path = '/courses']) => ProviderScope(
    retry: (_, _) => null,
    overrides: [
      courseRepositoryProvider.overrideWithValue(repository),
      sessionProvider.overrideWith(_SignedInSession.new),
    ],
    child: LembarApp(initialLocation: path),
  );

  test('maps every catalog lesson to its own public YouTube ID', () async {
    final catalog = await repository.listCourses();
    expect(catalog.map((course) => course.lessonCount), [5, 2, 2]);
    expect(catalog.map((course) => course.duration.inSeconds), [
      3077,
      1417,
      3265,
    ]);
    final courses = await Future.wait(
      catalog.map((course) => repository.getCourse(course.id)),
    );
    final videos = <String>{};
    for (final course in courses) {
      expect(
        course.lessons.map((lesson) => lesson.order),
        List.generate(course.lessons.length, (index) => index + 1),
      );
      for (final lesson in course.lessons) {
        expect(lesson.courseId, course.summary.id);
        expect(lesson.youtubeChannel, isNotEmpty);
        expect(lesson.youtubeVideoId, matches(RegExp(r'^[A-Za-z0-9_-]{11}$')));
        expect(videos.add(lesson.youtubeVideoId!), isTrue);
        expect(lesson.videoUri, isNull);
        expect(lesson.videoAsset, isNull);
      }
    }
    expect(courses.first.lessons.first.youtubeVideoId, 'OgNq2UYpf2o');
    expect(videos, hasLength(9));
  });

  test('rejects a lesson combining an embed with an MP4', () async {
    final conflicting = AssetCourseRepository(
      bundle: _FixtureBundle(
        fixture.replaceFirst(
          '"youtubeVideoId": "OgNq2UYpf2o"',
          '"youtubeVideoId": "OgNq2UYpf2o", "videoUrl": "https://example.com/lesson.mp4"',
        ),
      ),
    );
    await expectLater(
      conflicting.listCourses(),
      throwsA(
        isA<CourseException>().having(
          (error) => error.failure,
          'failure',
          CourseFailure.invalidData,
        ),
      ),
    );
  });

  test('turns malformed fixtures into a typed failure', () async {
    final invalid = AssetCourseRepository(bundle: _FixtureBundle('[]'));
    await expectLater(
      invalid.listCourses(),
      throwsA(
        isA<CourseException>().having(
          (error) => error.failure,
          'failure',
          CourseFailure.invalidData,
        ),
      ),
    );
  });

  testWidgets('opens course from catalog and returns through the same route', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Katalog'), findsNWidgets(2));
    await tester.tap(find.text('Dasar Desain UI'));
    await tester.pumpAndSettle();
    expect(find.text('Mulai lesson pertama'), findsOneWidget);
    expect(find.text('Daftar lesson'), findsOneWidget);
    await tester.tap(find.byTooltip('Kembali'));
    await tester.pumpAndSettle();
    expect(find.text('Katalog'), findsNWidgets(2));
    expect(find.text('Mulai lesson pertama'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('invalid lesson returns to course without creating a player', (
    tester,
  ) async {
    await tester.pumpWidget(
      app('/courses/dasar-desain-ui/lessons/lesson-tidak-ada'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lesson tidak tersedia.'), findsOneWidget);
    expect(find.text('Mulai lesson pertama'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows an offline message and retries into empty catalog', (
    tester,
  ) async {
    final repository = _RetryRepository();
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          courseRepositoryProvider.overrideWithValue(repository),
          sessionProvider.overrideWith(_SignedInSession.new),
        ],
        child: const LembarApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Koneksi terputus'), findsOneWidget);
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada course'), findsOneWidget);
    expect(repository.calls, 2);
    await tester.drag(find.byType(ListView), const Offset(0, 320));
    await tester.pumpAndSettle();
    expect(repository.calls, 3);
  });

  testWidgets(
    'guards routes, validates demo login, opens account and logs out',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        const ProviderScope(
          child: LembarApp(initialLocation: '/courses/dasar-desain-ui'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Masuk ke Lembar'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.enterText(
        find.byType(TextField).first,
        DemoAccount.student.email,
      );
      await tester.enterText(find.byType(TextField).last, 'invalid');
      await tester.tap(find.byTooltip('Tampilkan kata sandi'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).last).obscureText,
        isFalse,
      );
      await tester.tap(find.byTooltip('Sembunyikan kata sandi'));
      await tester.pump();

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();
      expect(
        find.text('Email atau kata sandi demo tidak cocok.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Masuk dengan akun demo'));
      await tester.pumpAndSettle();
      expect(find.text('Mulai lesson pertama'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Akun'));
      await tester.pumpAndSettle();
      expect(find.text(DemoAccount.student.email), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.text('3 course · 9 lesson'), findsOneWidget);
      await tester.tap(find.text('Ke katalog'));
      await tester.pumpAndSettle();
      expect(find.text('Katalog'), findsNWidgets(2));
      expect(find.text('Dasar Desain UI'), findsOneWidget);
      await tester.tap(find.text('Akun'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Keluar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keluar'));
      await tester.pumpAndSettle();
      expect(find.text('Masuk ke Lembar'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );

  testWidgets('pull to refresh reads course detail again', (tester) async {
    final bundle = _FixtureBundle(fixture);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          courseRepositoryProvider.overrideWithValue(
            AssetCourseRepository(bundle: bundle),
          ),
          sessionProvider.overrideWith(_SignedInSession.new),
        ],
        child: const LembarApp(initialLocation: '/courses/dasar-desain-ui'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CourseDetailScreen), findsOneWidget);
    final before = bundle.loads;
    await tester.drag(
      find.byType(ListView).hitTestable(),
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    expect(bundle.loads, before + 1);
    expect(find.text('Mulai lesson pertama'), findsOneWidget);
  });

  testWidgets('fits a compact viewport with large text', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.8;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Katalog'), findsNWidgets(2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app('/courses/dasar-desain-ui'));
    await tester.pumpAndSettle();
    expect(find.byType(CourseDetailScreen), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(app('/account'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(const ProviderScope(child: LembarApp()));
    await tester.pumpAndSettle();
    expect(find.text('Masuk ke Lembar'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Masuk dengan akun demo'),
      140,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });
}

class _SignedInSession extends DemoSession {
  @override
  Student build() => DemoAccount.student;
}

class _RetryRepository implements CourseRepository {
  int calls = 0;
  @override
  Future<List<CourseSummary>> listCourses() async {
    if (calls++ == 0) throw const CourseException(CourseFailure.offline);
    return [];
  }

  @override
  Future<Course> getCourse(String id) async =>
      throw const CourseException(CourseFailure.notFound);
}

class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle(this.json);
  final String json;
  int loads = 0;

  @override
  Future<ByteData> load(String key) async {
    loads++;
    return ByteData.sublistView(utf8.encode(json));
  }
}
