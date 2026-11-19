import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lembar/courses/data/course_repository.dart';

import '../../support/fixture_bundle.dart';

void main() {
  group('Bundled catalog', () {
    final fixture = File('assets/data/courses.json').readAsStringSync();
    final repository = AssetCourseRepository(bundle: FixtureBundle(fixture));
    test('validates catalog metadata and unique YouTube IDs', () async {
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
          expect(
            lesson.youtubeVideoId,
            matches(RegExp(r'^[A-Za-z0-9_-]{11}$')),
          );
          expect(videos.add(lesson.youtubeVideoId!), isTrue);
          expect(lesson.videoUri, isNull);
          expect(lesson.videoAsset, isNull);
        }
      }
      expect(courses.first.lessons.first.youtubeVideoId, 'OgNq2UYpf2o');
      expect(videos, hasLength(9));
    });
  });

  group('AssetCourseRepository', () {
    test('orders lessons by order and derives course metadata', () async {
      final repository = _repository([
        _course('design', [
          _lesson('second', order: 2, duration: 35),
          _lesson('first', order: 1, duration: 45),
        ]),
      ]);

      final summary = (await repository.listCourses()).single;
      final detail = await repository.getCourse(summary.id);

      expect(summary.lessonCount, 2);
      expect(summary.duration, const Duration(seconds: 80));
      expect(detail.lessons.map((lesson) => lesson.id), ['first', 'second']);
      expect(detail.lessonById('first'), same(detail.lessons.first));
      expect(detail.lessonById('missing'), isNull);
    });

    test('allows an empty catalog and courses without lessons', () async {
      expect(await _repository([]).listCourses(), isEmpty);

      final course = await _repository([_course('design', [])])
          .getCourse('design');

      expect(course.lessons, isEmpty);
      expect(course.summary.lessonCount, 0);
      expect(course.summary.duration, Duration.zero);
    });

    test('reports an unknown course as not found', () async {
      final repository = _repository([_course('design', [])]);

      await expectLater(
        repository.getCourse('missing'),
        throwsA(_courseFailure(CourseFailure.notFound)),
      );
    });

    test('reports an unreadable catalog asset as unavailable', () async {
      final repository = AssetCourseRepository(bundle: _MissingBundle());

      await expectLater(
        repository.listCourses(),
        throwsA(_courseFailure(CourseFailure.unavailable)),
      );
    });

    test(
      'reports invalid JSON and an invalid root type as invalid data',
      () async {
        for (final json in ['{"data":', '[]']) {
          final repository = AssetCourseRepository(bundle: FixtureBundle(json));

          await expectLater(
            repository.listCourses(),
            throwsA(_courseFailure(CourseFailure.invalidData)),
          );
        }
      },
    );

    final invalidCatalogs = <String, List<Map<String, Object?>>>{
      'duplicate course IDs': [_course('design', []), _course('design', [])],
      'duplicate lesson IDs across courses': [
        _course('design', [_lesson('intro')]),
        _course('photo', [_lesson('intro', courseId: 'photo')]),
      ],
      'duplicate lesson orders in a course': [
        _course('design', [_lesson('intro'), _lesson('layout')]),
      ],
      'lesson owned by another course': [
        _course('design', [_lesson('intro', courseId: 'photo')]),
      ],
      'non-positive lesson order': [
        _course('design', [_lesson('intro', order: 0)]),
      ],
      'non-positive duration': [
        _course('design', [_lesson('intro', duration: 0)]),
      ],
      'invalid YouTube ID': [
        _course('design', [_lesson('intro', youtubeId: 'short')]),
      ],
      'YouTube and MP4 on one lesson': [
        _course('design', [
          _lesson('intro', videoUrl: 'https://media.example.test/intro.mp4'),
        ]),
      ],
      'insecure MP4 URL': [
        _course('design', [
          _lesson(
            'intro',
            youtubeId: null,
            videoUrl: 'http://media.example.test/intro.mp4',
          ),
        ]),
      ],
      'no media source': [
        _course('design', [_lesson('intro', youtubeId: null)]),
      ],
    };

    for (final MapEntry(key: reason, value: courses)
        in invalidCatalogs.entries) {
      test('rejects $reason', () async {
        await expectLater(
          _repository(courses).listCourses(),
          throwsA(_courseFailure(CourseFailure.invalidData)),
        );
      });
    }

    test('resolves MP4 overrides without changing YouTube lessons', () async {
      final repository = _repository([
        _course('design', [
          _lesson('offline', youtubeId: null, videoAsset: 'assets/video.mp4'),
          _lesson('intro', order: 2),
        ]),
      ], videoBaseUrl: 'https://media.example.test/lessons');

      final course = await repository.getCourse('design');

      expect(
        course.lessons.first.videoUri,
        Uri.parse('https://media.example.test/lessons/offline.mp4'),
      );
      expect(course.lessons.last.youtubeVideoId, 'OgNq2UYpf2o');
      expect(course.lessons.last.videoUri, isNull);
    });
  });
}

Matcher _courseFailure(CourseFailure expected) => isA<CourseException>().having(
  (error) => error.failure,
  'failure',
  expected,
);

AssetCourseRepository _repository(
  List<Map<String, Object?>> courses, {
  String videoBaseUrl = '',
}) => AssetCourseRepository(
  bundle: FixtureBundle(jsonEncode({'data': courses})),
  videoBaseUrl: videoBaseUrl,
);

Map<String, Object?> _course(String id, List<Map<String, Object?>> lessons) => {
  'id': id,
  'title': 'Course $id',
  'summary': 'Ringkasan course',
  'description': 'Deskripsi course',
  'category': 'Desain',
  'coverKey': 'design',
  'lessons': lessons,
};

Map<String, Object?> _lesson(
  String id, {
  String courseId = 'design',
  int order = 1,
  int duration = 60,
  String? youtubeId = 'OgNq2UYpf2o',
  String? videoUrl,
  String? videoAsset,
}) => {
  'id': id,
  'courseId': courseId,
  'order': order,
  'title': 'Lesson $id',
  'description': 'Deskripsi lesson',
  'durationSeconds': duration,
  'youtubeVideoId': ?youtubeId,
  'videoUrl': ?videoUrl,
  'videoAsset': ?videoAsset,
};

class _MissingBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async => throw FlutterError('Missing $key');
}
