class Lesson {
  const Lesson({
    required this.id,
    required this.courseId,
    required this.order,
    required this.title,
    required this.description,
    required this.duration,
    required this.videoAsset,
    this.videoUri,
    this.youtubeVideoId,
    this.youtubeChannel,
    this.youtubeReferenceId,
  });

  final String id;
  final String courseId;
  final int order;
  final String title;
  final String description;
  final Duration duration;
  final String? videoAsset;
  final Uri? videoUri;
  final String? youtubeVideoId;
  final String? youtubeChannel;
  final String? youtubeReferenceId;
}

class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.coverKey,
    required this.lessonCount,
    required this.duration,
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final String coverKey;
  final int lessonCount;
  final Duration duration;
}

class Course {
  Course({
    required this.summary,
    required this.description,
    required List<Lesson> lessons,
  }) : lessons = List.unmodifiable(lessons);

  final CourseSummary summary;
  final String description;
  final List<Lesson> lessons;

  Lesson? lessonById(String id) {
    for (final lesson in lessons) {
      if (lesson.id == id) return lesson;
    }
    return null;
  }
}
