import 'dart:math';

enum Operation { plus, minus, times }

enum PracticeMode { training, challenge, placement }

class Level {
  final Operation operation;
  final int limit;
  const Level(this.operation, this.limit);
  String get id => '${operation.name}_$limit';
  String get symbol => switch (operation) {
    Operation.plus => '+',
    Operation.minus => '−',
    Operation.times => '×',
  };
  int get index => levels.indexWhere((l) => l.id == id);
  String title(bool en) {
    final name = switch (operation) {
      Operation.plus => en ? 'Addition' : 'Addition',
      Operation.minus => en ? 'Subtraction' : 'Subtraktion',
      Operation.times => en ? 'Multiplication' : 'Multiplikation',
    };
    return '$name ${en ? 'to' : 'bis'} $limit';
  }
}

const levels = [
  Level(Operation.plus, 10),
  Level(Operation.plus, 20),
  Level(Operation.plus, 100),
  Level(Operation.minus, 10),
  Level(Operation.minus, 20),
  Level(Operation.minus, 100),
  Level(Operation.times, 10),
  Level(Operation.times, 20),
  Level(Operation.times, 100),
];

class Question {
  final Level level;
  final int a;
  final int b;
  const Question(this.level, this.a, this.b);
  int get answer => switch (level.operation) {
    Operation.plus => a + b,
    Operation.minus => a - b,
    Operation.times => a * b,
  };
  String get key => '${level.id}:$a:$b';
  String get expression => '$a ${level.symbol} $b';
  static Question fromKey(String key) {
    final parts = key.split(':');
    return Question(
      levels.firstWhere((l) => l.id == parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}

class TaskProgress {
  int attempts = 0;
  int correct = 0;
  int milliseconds = 0;
  int recentCorrect = 0;
  double meanSeconds = 0;
  bool lastCorrect = false;
  double get accuracy => attempts == 0 ? 0 : correct / attempts;
  bool get needsPractice =>
      attempts > 0 && (recentCorrect < 2 || meanSeconds > 12);
  double get weight =>
      1 + (1 - accuracy) * 4 + (lastCorrect ? 0 : 3) + min(meanSeconds / 12, 3);
  void record(bool right, int ms) {
    attempts++;
    if (right) correct++;
    milliseconds += ms;
    recentCorrect = right ? recentCorrect + 1 : 0;
    meanSeconds = attempts == 1
        ? ms / 1000
        : meanSeconds * .65 + ms / 1000 * .35;
    lastCorrect = right;
  }

  Map<String, dynamic> toJson() => {
    'attempts': attempts,
    'correct': correct,
    'milliseconds': milliseconds,
    'recentCorrect': recentCorrect,
    'meanSeconds': meanSeconds,
    'lastCorrect': lastCorrect,
  };
  TaskProgress();
  TaskProgress.fromJson(Map<String, dynamic> j) {
    attempts = j['attempts'] as int;
    correct = j['correct'] as int;
    milliseconds = j['milliseconds'] as int;
    recentCorrect = j['recentCorrect'] as int;
    meanSeconds = (j['meanSeconds'] as num).toDouble();
    lastCorrect = j['lastCorrect'] as bool;
  }
}

class SessionResult {
  final String levelId;
  final PracticeMode mode;
  final DateTime date;
  final int attempts, correct, seconds;
  final bool completed;
  SessionResult(
    this.levelId,
    this.mode,
    this.date,
    this.attempts,
    this.correct,
    this.seconds,
    this.completed,
  );
  Map<String, dynamic> toJson() => {
    'level': levelId,
    'mode': mode.name,
    'date': date.toIso8601String(),
    'attempts': attempts,
    'correct': correct,
    'seconds': seconds,
    'completed': completed,
  };
  SessionResult.fromJson(Map<String, dynamic> j)
    : levelId = j['level'] as String,
      mode = PracticeMode.values.byName(j['mode'] as String),
      date = DateTime.parse(j['date'] as String),
      attempts = j['attempts'] as int,
      correct = j['correct'] as int,
      seconds = j['seconds'] as int,
      completed = j['completed'] as bool;
}

class Learner {
  final String id;
  String name;
  int points = 0;
  bool assessed = false;
  final Set<String> unlocked = {};
  final Map<String, int> feedings = {};
  final Map<String, TaskProgress> tasks = {};
  final List<SessionResult> sessions = [];
  Learner(this.id, this.name);
  int get attempts => tasks.values.fold(0, (a, p) => a + p.attempts);
  int get correct => tasks.values.fold(0, (a, p) => a + p.correct);
  int get milliseconds => tasks.values.fold(0, (a, p) => a + p.milliseconds);
  Iterable<TaskProgress> progress(Level level) => tasks.entries
      .where((e) => e.key.startsWith('${level.id}:'))
      .map((e) => e.value);
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points,
    'assessed': assessed,
    'unlocked': unlocked.toList(),
    'feedings': feedings,
    'tasks': tasks.map((k, v) => MapEntry(k, v.toJson())),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };
  factory Learner.fromJson(Map<String, dynamic> j) {
    final p = Learner(j['id'] as String, j['name'] as String);
    p.points = j['points'] as int;
    p.assessed = j['assessed'] as bool;
    p.unlocked.addAll((j['unlocked'] as List).cast<String>());
    p.feedings.addAll(Map<String, int>.from(j['feedings'] as Map));
    (j['tasks'] as Map<String, dynamic>).forEach(
      (k, v) => p.tasks[k] = TaskProgress.fromJson(
        Map<String, dynamic>.from(v as Map),
      ),
    );
    p.sessions.addAll(
      (j['sessions'] as List).map(
        (s) => SessionResult.fromJson(Map<String, dynamic>.from(s as Map)),
      ),
    );
    return p;
  }
}

/// Transparent rules, not a clinically validated assessment. All levels remain selectable.
class AdaptiveEngine {
  final Random random;
  AdaptiveEngine([Random? random]) : random = random ?? Random();

  Question next(
    Level level,
    Learner learner, {
    String? previous,
    bool assessment = false,
  }) {
    final weak = learner.tasks.entries
        .where(
          (e) =>
              e.key.startsWith('${level.id}:') &&
              e.key != previous &&
              e.value.needsPractice,
        )
        .toList();
    if (!assessment && weak.isNotEmpty && random.nextDouble() < .6) {
      var choice =
          random.nextDouble() *
          weak.fold<double>(0, (a, e) => a + e.value.weight);
      for (final e in weak) {
        choice -= e.value.weight;
        if (choice <= 0) return Question.fromKey(e.key);
      }
      return Question.fromKey(weak.last.key);
    }
    final stats = learner.progress(level).toList();
    final attempts = stats.fold(0, (a, p) => a + p.attempts);
    final correct = stats.fold(0, (a, p) => a + p.correct);
    final avg = attempts == 0
        ? 0
        : stats.fold(0, (a, p) => a + p.milliseconds) / attempts / 1000;
    // Temporarily reduce the number range when a learner struggles, then expand again.
    final cap =
        !assessment && attempts >= 5 && (correct / attempts < .6 || avg > 25)
        ? max(5, level.limit ~/ 2)
        : level.limit;
    Question question;
    var tries = 0;
    do {
      if (level.operation == Operation.times) {
        final a = 1 + random.nextInt(min(10, cap));
        final b = random.nextInt(min(10, cap ~/ a) + 1);
        question = Question(level, a, b);
      } else {
        final a = random.nextInt(cap + 1);
        final b = random.nextInt(
          (level.operation == Operation.plus ? cap - a : a) + 1,
        );
        question = Question(level, a, b);
      }
    } while (question.key == previous && ++tries < 20);
    return question;
  }

  int challengeSeconds(Level level, Learner learner) {
    final p = learner.progress(level).toList();
    final n = p.fold(0, (a, p) => a + p.attempts);
    if (n < 5) return 120;
    final seconds = p.fold(0, (a, p) => a + p.milliseconds) / n / 1000;
    return (seconds * 15).round().clamp(120, 240);
  }

  List<Level> prerequisites(Level l) {
    final result = <Level>[];
    final previousLimit = l.limit == 100 ? 20 : 10;
    if (l.limit > 10) result.add(Level(l.operation, previousLimit));
    if (l.operation != Operation.plus) {
      result.add(Level(Operation.plus, l.limit));
    }
    return result;
  }

  bool ready(Level l, Learner learner) {
    if (learner.unlocked.contains(l.id)) return true;
    final stats = learner.progress(l).toList();
    final n = stats.fold(0, (a, p) => a + p.attempts);
    if (n < 5) return false;
    return stats.fold(0, (a, p) => a + p.correct) / n >= .8 &&
        stats.fold(0, (a, p) => a + p.milliseconds) / n <= 12000;
  }

  Level recommend(Learner p) {
    // Prerequisites precede new topics. Established but insecure topics receive review.
    for (final l in levels) {
      if (!ready(l, p)) {
        for (final prerequisite in prerequisites(l)) {
          if (!ready(prerequisite, p)) return prerequisite;
        }
        return l;
      }
    }
    final sorted = [...levels]
      ..sort(
        (a, b) => p
            .progress(b)
            .where((v) => v.needsPractice)
            .length
            .compareTo(p.progress(a).where((v) => v.needsPractice).length),
      );
    return sorted.first;
  }
}

class PracticeSession {
  final Learner learner;
  final Level level;
  final PracticeMode mode;
  final AdaptiveEngine engine;
  late Question question;
  late final int timeLimit;
  int attempts = 0, correct = 0, streak = 0, bestStreak = 0;
  int elapsedMs = 0, questionMs = 0;
  bool finished = false,
      successful = false,
      awaitingNext = false,
      paused = false;
  bool? lastRight;
  PracticeSession(this.learner, this.level, this.mode, this.engine) {
    timeLimit = engine.challengeSeconds(level, learner);
    question = engine.next(
      mode == PracticeMode.placement ? levels.first : level,
      learner,
      assessment: mode != PracticeMode.training,
    );
  }
  int get remaining => max(0, timeLimit - elapsedMs ~/ 1000);
  void tick(int ms) {
    if (finished || paused || awaitingNext) return;
    elapsedMs += ms;
    questionMs += ms;
    if (mode == PracticeMode.challenge && elapsedMs >= timeLimit * 1000) {
      finished = true;
    }
  }

  bool? submit(String value) {
    if (finished || paused || awaitingNext) return null;
    final answer = int.tryParse(value.trim());
    if (answer == null) return null;
    final right = answer == question.answer;
    learner.tasks
        .putIfAbsent(question.key, TaskProgress.new)
        .record(right, questionMs);
    attempts++;
    if (right) {
      correct++;
      streak++;
      learner.points += 2;
    } else {
      streak = 0;
    }
    bestStreak = max(streak, bestStreak);
    lastRight = right;
    awaitingNext = true;
    successful = mode == PracticeMode.challenge && streak >= 10;
    if (successful ||
        (mode == PracticeMode.training && attempts >= 10) ||
        (mode == PracticeMode.placement && attempts >= levels.length)) {
      finished = true;
      if (successful && learner.unlocked.add(level.id)) learner.points += 10;
      if (mode == PracticeMode.placement) learner.assessed = true;
    }
    return right;
  }

  void next() {
    if (finished || !awaitingNext) return;
    question = engine.next(
      mode == PracticeMode.placement ? levels[attempts] : level,
      learner,
      previous: question.key,
      assessment: mode != PracticeMode.training,
    );
    questionMs = 0;
    awaitingNext = false;
    lastRight = null;
  }

  SessionResult result() => SessionResult(
    level.id,
    mode,
    DateTime.now(),
    attempts,
    correct,
    elapsedMs ~/ 1000,
    finished,
  );
}
