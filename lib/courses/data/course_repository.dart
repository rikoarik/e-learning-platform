import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'course.dart';

abstract interface class CourseRepository {
  Future<List<CourseSummary>> listCourses();
  Future<Course> getCourse(String courseId);
}

enum CourseFailure { notFound, offline, unavailable, invalidData }

class CourseException implements Exception {
  const CourseException(this.failure);

  final CourseFailure failure;

  @override
  String toString() => 'CourseException(${failure.name})';
}

class AssetCourseRepository implements CourseRepository {
  const AssetCourseRepository({
    required this.bundle,
    this.videoBaseUrl = '',
    this.assetPath = 'assets/data/courses.json',
  });

  final AssetBundle bundle;
  final String videoBaseUrl;
  final String assetPath;

  @override
  Future<List<CourseSummary>> listCourses() async =>
      List.unmodifiable((await _readCourses()).map((course) => course.summary));

  @override
  Future<Course> getCourse(String courseId) async {
    for (final course in await _readCourses()) {
      if (course.summary.id == courseId) return course;
    }
    throw const CourseException(CourseFailure.notFound);
  }

  Future<List<Course>> _readCourses() async {
    final String raw;
    try {
      raw = await bundle.loadString(assetPath, cache: false);
    } on FlutterError {
      throw const CourseException(CourseFailure.unavailable);
    }
    try {
      final data = _object(jsonDecode(raw));
      final ids = <String>{};
      final lessonIds = <String>{};
      final courses = _items(data['data']).map(_course).toList();
      if (courses.any((course) => !ids.add(course.summary.id))) {
        throw const FormatException('Duplicate course ID');
      }
      if (courses
          .expand((course) => course.lessons)
          .any((lesson) => !lessonIds.add(lesson.id))) {
        throw const FormatException('Duplicate lesson ID');
      }
      return courses;
    } on FormatException {
      throw const CourseException(CourseFailure.invalidData);
    }
  }

  Course _course(Map<String, Object?> json) {
    final id = _string(json, 'id');
    final lessonIds = <String>{};
    final orders = <int>{};
    final lessons =
        _items(json['lessons']).map((item) => _lesson(item, id)).toList()
          ..sort((first, second) => first.order.compareTo(second.order));
    if (lessons.any(
      (lesson) => !lessonIds.add(lesson.id) || !orders.add(lesson.order),
    )) {
      throw const FormatException('Duplicate lesson ID or order');
    }
    return Course(
      summary: CourseSummary(
        id: id,
        title: _string(json, 'title'),
        summary: _string(json, 'summary'),
        category: _string(json, 'category'),
        coverKey: _string(json, 'coverKey'),
        lessonCount: lessons.length,
        duration: lessons.fold(
          Duration.zero,
          (total, lesson) => total + lesson.duration,
        ),
      ),
      description: _string(json, 'description'),
      lessons: lessons,
    );
  }

  Lesson _lesson(Map<String, Object?> json, String courseId) {
    final id = _string(json, 'id');
    if (_string(json, 'courseId') != courseId) {
      throw const FormatException('Lesson belongs to a different course');
    }
    final youtubeVideoId = _youtubeId(json, 'youtubeVideoId');
    final youtubeChannel = json['youtubeChannel'] == null
        ? null
        : _string(json, 'youtubeChannel');
    final youtubeReferenceId = _youtubeId(json, 'youtubeReferenceId');
    final videoAsset = json['videoAsset'] == null
        ? null
        : _string(json, 'videoAsset');
    final Uri? videoUri;
    if (youtubeVideoId != null) {
      if (videoAsset != null || json['videoUrl'] != null) {
        throw const FormatException('Conflicting lesson media sources');
      }
      videoUri = null;
    } else if (videoBaseUrl.isNotEmpty) {
      final base = _https(videoBaseUrl);
      if (base.hasQuery || base.hasFragment) {
        throw const FormatException('Invalid video base URL');
      }
      final directory = base.path.endsWith('/') ? base.path : '${base.path}/';
      videoUri = base
          .replace(path: directory)
          .resolve('${Uri.encodeComponent(id)}.mp4');
    } else {
      videoUri = json['videoUrl'] == null
          ? null
          : _https(_string(json, 'videoUrl'));
    }
    if (videoAsset == null && videoUri == null && youtubeVideoId == null) {
      throw const FormatException('Missing lesson media');
    }
    return Lesson(
      id: id,
      courseId: courseId,
      order: _positiveInt(json, 'order'),
      title: _string(json, 'title'),
      description: _string(json, 'description'),
      duration: Duration(seconds: _positiveInt(json, 'durationSeconds')),
      videoAsset: videoAsset,
      videoUri: videoUri,
      youtubeVideoId: youtubeVideoId,
      youtubeChannel: youtubeChannel,
      youtubeReferenceId: youtubeReferenceId,
    );
  }
}

final _youtubeIdPattern = RegExp(r'^[A-Za-z0-9_-]{11}$');

String? _youtubeId(Map<String, Object?> json, String key) {
  if (json[key] == null) return null;
  final id = _string(json, key);
  if (!_youtubeIdPattern.hasMatch(id)) {
    throw FormatException('Invalid YouTube ID in $key');
  }
  return id;
}

Map<String, Object?> _object(Object? value) {
  if (value is Map<String, Object?>) return value;
  throw const FormatException('Expected JSON object');
}

Iterable<Map<String, Object?>> _items(Object? value) {
  if (value is List<Object?>) return value.map(_object);
  throw const FormatException('Expected JSON list');
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) return value;
  throw FormatException('Invalid $key');
}

int _positiveInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is int && value > 0) return value;
  throw FormatException('Invalid $key');
}

Uri _https(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
    throw const FormatException('Invalid HTTPS media URL');
  }
  return uri;
}
