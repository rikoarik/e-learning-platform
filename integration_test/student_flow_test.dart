import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SizedBox;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lembar/courses/data/course_repository.dart';
import 'package:lembar/courses/state/course_providers.dart';
import 'package:lembar/main.dart' as app;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every catalog lesson cues its own YouTube video in the app', (
    tester,
  ) async {
    final repository = AssetCourseRepository(bundle: rootBundle);
    final catalog = await repository.listCourses();
    await tester.pumpWidget(const ProviderScope(child: app.LembarApp()));
    await _tapVisible(tester, find.text('Masuk dengan akun demo'));

    for (final summary in catalog) {
      final course = await repository.getCourse(summary.id);
      await _tapVisible(tester, find.text(summary.title));
      await tester.pumpAndSettle();

      for (final lesson in course.lessons) {
        await _tapVisible(tester, find.text(lesson.title));
        final finder = find.byType(YoutubePlayer);
        await _until(tester, () {
          final player = tester.widgetList<YoutubePlayer>(finder).firstOrNull;
          return player?.controller.key == lesson.youtubeVideoId ||
              find.text('Video gagal diputar').evaluate().isNotEmpty;
        }, lesson.title);
        final player = tester.widgetList<YoutubePlayer>(finder).firstOrNull;
        expect(player, isNotNull, reason: lesson.title);
        final controller = player!.controller;
        await _until(
          tester,
          () =>
              controller.value.hasError ||
              controller.value.playerState == PlayerState.cued ||
              find.text('Video gagal diputar').evaluate().isNotEmpty,
          'YouTube cue for ${lesson.title}: ${lesson.youtubeVideoId}',
        );
        expect(
          controller.value.playerState,
          PlayerState.cued,
          reason: '${lesson.title}: ${controller.value.error}',
        );
        expect(find.text('Buka di YouTube'), findsOneWidget);
        await _tapVisible(tester, find.byTooltip('Kembali'));
        await _until(
          tester,
          () => finder.evaluate().isEmpty,
          'close ${lesson.title}',
        );
      }

      await _tapVisible(tester, find.byTooltip('Kembali'));
    }

    await _until(
      tester,
      () => find.text('Course lainnya').evaluate().isNotEmpty,
      'return to the catalog',
    );
    await _closeTestApp(tester);
  });

  testWidgets('switching lessons replaces the YouTube controller', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: app.LembarApp()));
    await _tapVisible(tester, find.text('Masuk dengan akun demo'));
    await _tapVisible(tester, find.text('Dasar Desain UI'));
    await _tapVisible(tester, find.text('Mulai lesson pertama'));
    final finder = find.byType(YoutubePlayer);
    await _until(tester, () => finder.evaluate().isNotEmpty, 'first player');
    final intro = tester.widget<YoutubePlayer>(finder).controller;
    await _tapVisible(tester, find.text('Mengenal antarmuka Figma'));
    await _until(
      tester,
      () =>
          tester
              .widgetList<YoutubePlayer>(finder)
              .firstOrNull
              ?.controller
              .key ==
          '6R4KAr3yg1M',
      'second player',
    );
    expect(tester.widget<YoutubePlayer>(finder).controller, isNot(same(intro)));
    expect(find.text('LESSON 02 / 05'), findsOneWidget);
    await _closeTestApp(tester);
  });

  testWidgets('unavailable video exposes retry and keeps lesson navigation', (
    tester,
  ) async {
    final json = await rootBundle.loadString('assets/data/courses.json');
    final repository = AssetCourseRepository(
      bundle: _FixtureBundle(json.replaceFirst('OgNq2UYpf2o', '___________')),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [courseRepositoryProvider.overrideWithValue(repository)],
        child: const app.LembarApp(),
      ),
    );
    await _tapVisible(tester, find.text('Masuk dengan akun demo'));
    await _tapVisible(tester, find.text('Dasar Desain UI'));
    await _tapVisible(tester, find.text('Mulai lesson pertama'));
    final finder = find.byType(YoutubePlayer);
    await _until(tester, () => finder.evaluate().isNotEmpty, 'initial player');
    final first = tester.widget<YoutubePlayer>(finder).controller;
    await _until(
      tester,
      () => find.text('Video gagal diputar').evaluate().isNotEmpty,
      'video error',
    );
    expect(find.text('Buka di YouTube'), findsOneWidget);
    await _tapVisible(tester, find.text('Coba lagi'));
    await _until(tester, () => finder.evaluate().isNotEmpty, 'retried player');
    final retried = tester.widget<YoutubePlayer>(finder).controller;
    expect(retried, isNot(same(first)));
    expect(retried.key, first.key);
    await _tapVisible(tester, find.byTooltip('Kembali'));
    await _until(
      tester,
      () => finder.evaluate().isEmpty,
      'close retried player',
    );
    await _closeTestApp(tester);
  });
}

Future<void> _closeTestApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await _until(tester, () => finder.evaluate().isNotEmpty, finder.toString());
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await _until(
    tester,
    () => finder.hitTestable().evaluate().isNotEmpty,
    finder.toString(),
  );
  await tester.tap(finder.hitTestable());
}

Future<void> _until(
  WidgetTester tester,
  bool Function() ready,
  String step,
) async {
  for (var attempt = 0; attempt < 240; attempt++) {
    if (ready()) return;
    await tester.pump(const Duration(milliseconds: 150));
  }
  fail('Student flow timed out at $step.');
}

class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle(this.json);
  final String json;

  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(utf8.encode(json));
}
