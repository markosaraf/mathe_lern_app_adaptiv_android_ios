import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/domain/learning.dart';

void main() {
  test(
    'all nine original groups generate valid tasks without immediate repeats',
    () {
      final p = Learner('a', 'Alex');
      final e = AdaptiveEngine(Random(2));
      expect(levels.length, 9);
      for (final l in levels) {
        String? previous;
        for (var i = 0; i < 500; i++) {
          final q = e.next(l, p, previous: previous);
          expect(q.answer, inInclusiveRange(0, l.limit));
          expect(q.key, isNot(previous));
          expect(q.a, greaterThanOrEqualTo(0));
          expect(q.b, greaterThanOrEqualTo(0));
          previous = q.key;
        }
      }
    },
  );
  test(
    'slow or incorrect tasks receive more practice; consecutive recovery clears weakness',
    () {
      final p = Learner('a', 'Alex');
      final e = AdaptiveEngine(Random(12));
      final weak = TaskProgress()..record(false, 30000);
      final strong = TaskProgress()
        ..record(true, 1000)
        ..record(true, 1000);
      p.tasks['plus_10:2:3'] = weak;
      p.tasks['plus_10:4:1'] = strong;
      var repetitions = 0;
      for (var i = 0; i < 500; i++) {
        if (e.next(levels.first, p).key == 'plus_10:2:3') repetitions++;
      }
      expect(repetitions, greaterThan(250));
      expect(strong.needsPractice, false);
      for (var i = 0; i < 5; i++) {
        weak.record(true, 1000);
      }
      expect(weak.needsPractice, false);
    },
  );
  test(
    'struggling learner gets smaller numbers and a bounded longer challenge',
    () {
      final p = Learner('a', 'Alex');
      p.tasks['plus_100:70:20'] = TaskProgress();
      for (var i = 0; i < 8; i++) {
        p.tasks.values.first.record(false, 30000);
      }
      final e = AdaptiveEngine(Random(7));
      for (var i = 0; i < 100; i++) {
        expect(
          e.next(levels[2], p, previous: 'plus_100:70:20').answer,
          lessThanOrEqualTo(50),
        );
      }
      expect(e.challengeSeconds(levels[2], p), 240);
      expect(e.recommend(p).id, 'plus_10');
    },
  );
  test(
    'challenge allows more than ten attempts, resets streak, awards cat once',
    () {
      final p = Learner('a', 'Alex');
      final e = AdaptiveEngine(Random(4));
      var s = PracticeSession(p, levels.first, PracticeMode.challenge, e);
      expect(s.submit(''), null);
      expect(s.attempts, 0);
      for (var i = 0; i < 3; i++) {
        s.tick(1000);
        s.submit('${s.question.answer}');
        s.next();
      }
      s.submit('${s.question.answer + 1}');
      expect(s.streak, 0);
      s.next();
      for (var i = 0; i < 10; i++) {
        s.tick(1000);
        s.submit('${s.question.answer}');
        s.next();
      }
      expect(s.attempts, 14);
      expect(s.successful, true);
      expect(p.unlocked, {'plus_10'});
      expect(p.points, 36);
      s.submit('0');
      expect(p.points, 36);
      s = PracticeSession(p, levels.first, PracticeMode.challenge, e);
      for (var i = 0; i < 10; i++) {
        s.submit('${s.question.answer}');
        s.next();
      }
      expect(p.points, 56); // No duplicate unlock bonus.
    },
  );
  test(
    'pause and feedback do not consume time; timeout cannot award more points',
    () {
      final p = Learner('a', 'Alex');
      final s = PracticeSession(
        p,
        levels.first,
        PracticeMode.challenge,
        AdaptiveEngine(Random(3)),
      );
      s.tick(1000);
      s.paused = true;
      s.tick(60000);
      expect(s.elapsedMs, 1000);
      expect(s.submit('${s.question.answer}'), null);
      s.paused = false;
      s.submit('${s.question.answer}');
      s.tick(60000);
      expect(s.elapsedMs, 1000);
      expect(s.submit('${s.question.answer}'), null);
      s.next();
      s.tick(120000);
      expect(s.finished, true);
      expect(s.successful, false);
      expect(s.submit('1'), null);
      expect(p.points, 2);
    },
  );
  test('assessment visits every group once and does not unlock cats', () {
    final p = Learner('a', 'Alex');
    final s = PracticeSession(
      p,
      levels.first,
      PracticeMode.placement,
      AdaptiveEngine(Random(8)),
    );
    final seen = <String>[];
    for (var i = 0; i < 9; i++) {
      seen.add(s.question.level.id);
      s.tick(2000);
      s.submit('${s.question.answer}');
      s.next();
    }
    expect(seen, levels.map((l) => l.id));
    expect(p.assessed, true);
    expect(p.unlocked, isEmpty);
    expect(s.finished, true);
    expect(p.tasks.length, 9);
    expect(p.correct, 9);
  });
}
