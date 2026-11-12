import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/data/store.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/domain/learning.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('mathe-test-');
  });
  tearDown(() async {
    await dir.delete(recursive: true);
  });
  test(
    'profiles, selection, language, progress and feeding survive restart',
    () async {
      final s = LearningStore(dir);
      await s.load();
      await expectLater(s.add('   '), throwsArgumentError);
      await s.add('Alex');
      final alex = s.current!;
      alex.points = 15;
      alex.unlocked.add('plus_10');
      alex.tasks['plus_10:2:3'] = TaskProgress()..record(true, 3200);
      alex.sessions.add(
        SessionResult(
          'plus_10',
          PracticeMode.training,
          DateTime(2026, 11, 12),
          1,
          1,
          3,
          false,
        ),
      );
      expect(await s.feed(alex, levels.first), true);
      expect(await s.feed(alex, levels[1]), false);
      await s.add('Sam');
      await s.setLanguage('en');
      await s.select(alex.id);
      await s.flushed;
      final restored = LearningStore(dir);
      await restored.load();
      expect(restored.error, null);
      expect(restored.profiles.length, 2);
      expect(restored.current!.name, 'Alex');
      expect(restored.en, true);
      expect(restored.current!.points, 10);
      expect(restored.current!.feedings['plus_10'], 1);
      expect(restored.current!.tasks.values.first.milliseconds, 3200);
      expect(restored.current!.sessions.single.correct, 1);
      await restored.remove(restored.current!);
      final again = LearningStore(dir);
      await again.load();
      expect(again.profiles.single.name, 'Sam');
      expect(await again.backup.readAsString(), isNot(contains('Alex')));
    },
  );
  test('serialized writes keep the most recent snapshot', () async {
    final s = LearningStore(dir);
    await s.add('Alex');
    final futures = <Future<void>>[];
    for (var i = 1; i <= 30; i++) {
      s.current!.points = i;
      futures.add(s.save());
    }
    await Future.wait(futures);
    final restored = LearningStore(dir);
    await restored.load();
    expect(restored.current!.points, 30);
  });
  test(
    'corrupt main file recovers from valid backup without discarding evidence',
    () async {
      final s = LearningStore(dir);
      await s.add('Alex');
      await s.save();
      await s.file.writeAsString('broken');
      final restored = LearningStore(dir);
      await restored.load();
      expect(restored.recovered, true);
      expect(restored.current!.name, 'Alex');
      expect(restored.error, null);
      expect(
        dir.listSync().where((f) => f.path.contains('.damaged-')),
        hasLength(1),
      );
    },
  );
  test(
    'unreadable files report a load error instead of silently resetting',
    () async {
      final s = LearningStore(dir);
      await s.file.writeAsString('broken');
      await s.load();
      expect(s.error, 'load');
    },
  );
}
