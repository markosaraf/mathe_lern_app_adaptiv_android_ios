import 'dart:async';
import 'dart:math';
import 'package:material_ui/material_ui.dart';
import '../data/store.dart';
import '../domain/learning.dart';

class Home extends StatefulWidget {
  final LearningStore store;
  const Home({super.key, required this.store});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  LearningStore get s => widget.store;
  String t(String de, String en) => s.tr(de, en);
  Future<void> editName([Learner? profile]) async {
    final controller = TextEditingController(text: profile?.name ?? '');
    String? error;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(
            profile == null
                ? t('Neues Profil', 'New profile')
                : t('Name ändern', 'Change name'),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            decoration: InputDecoration(
              labelText: t('Name oder Spitzname', 'Name or nickname'),
              errorText: error,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('Abbrechen', 'Cancel')),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isEmpty) {
                  update(
                    () => error = t(
                      'Bitte einen Namen eingeben.',
                      'Please enter a name.',
                    ),
                  );
                  return;
                }
                Navigator.pop(context, controller.text.trim());
              },
              child: Text(t('Speichern', 'Save')),
            ),
          ],
        ),
      ),
    );
    if (value != null) {
      if (profile == null) {
        await s.add(value);
      } else {
        await s.rename(profile, value);
      }
    }
    // Dialog exit animation may still reference its controller.
    Future.delayed(const Duration(seconds: 1), controller.dispose);
  }

  Future<void> profiles() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListenableBuilder(
          listenable: s,
          builder: (context, _) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t('Deine Profile', 'Your profiles'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    t(
                      'Nur auf diesem Gerät gespeichert. Keine Anmeldung.',
                      'Saved only on this device. No account needed.',
                    ),
                  ),
                  for (final p in s.profiles)
                    ListTile(
                      title: Text(p.name),
                      leading: Icon(
                        p.id == s.selectedId
                            ? Icons.check_circle
                            : Icons.person_outline,
                      ),
                      onTap: () {
                        s.select(p.id);
                        Navigator.pop(context);
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: t('Umbenennen', 'Rename'),
                            onPressed: () => editName(p),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: t('Löschen', 'Delete'),
                            onPressed: () async {
                              final yes = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    t('Profil löschen?', 'Delete profile?'),
                                  ),
                                  content: Text(
                                    t(
                                      'Alle Lernstände und Katzen von ${p.name} werden auf diesem Gerät gelöscht.',
                                      'All progress and cats for ${p.name} will be deleted on this device.',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(t('Abbrechen', 'Cancel')),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(t('Löschen', 'Delete')),
                                    ),
                                  ],
                                ),
                              );
                              if (yes == true) await s.remove(p);
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: () => editName(),
                    icon: const Icon(Icons.add),
                    label: Text(t('Profil hinzufügen', 'Add profile')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> start(Level level, PracticeMode mode) async {
    if (s.current == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PracticePage(
          store: s,
          learner: s.current!,
          level: level,
          mode: mode,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Widget panel(Widget child) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: child),
  );
  Widget title(String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Text(value, style: Theme.of(context).textTheme.headlineSmall),
  );
  @override
  Widget build(BuildContext context) {
    final p = s.current;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('Mathe mit Katzen', 'Math with Cats')),
        actions: [
          TextButton(
            onPressed: () => s.setLanguage(s.en ? 'de' : 'en'),
            child: Text(s.en ? 'DE' : 'EN'),
          ),
          IconButton(
            onPressed: profiles,
            tooltip: t('Profile', 'Profiles'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      bottomNavigationBar: p == null
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (v) => setState(() => tab = v),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.school_outlined),
                  label: t('Lernen', 'Learn'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.pets),
                  label: t('Katzen', 'Cats'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.bar_chart),
                  label: t('Statistik', 'Progress'),
                ),
              ],
            ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (s.error != null)
                      panel(
                        Column(
                          children: [
                            Text(
                              t(
                                'Speichern oder Laden fehlgeschlagen. Deine Datei wird nicht zurückgesetzt.',
                                'Saving or loading failed. Your file will not be reset.',
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  s.error == 'load' ? s.load() : s.save(),
                              child: Text(t('Erneut versuchen', 'Retry')),
                            ),
                          ],
                        ),
                      ),
                    if (s.error != 'load') ...[
                      if (s.recovered)
                        Text(
                          t(
                            'Lernstand aus der Sicherung wiederhergestellt.',
                            'Progress restored from the backup.',
                          ),
                        ),
                      if (p == null)
                        panel(
                          Column(
                            children: [
                              Image.asset('lib/images/cat1.png', height: 150),
                              title(
                                t(
                                  'Rechnen. Wachsen. Katzen sammeln.',
                                  'Calculate. Grow. Collect cats.',
                                ),
                              ),
                              Text(
                                t(
                                  'Erstelle ein Profil. Deine Aufgaben, Punkte und Katzen bleiben nach dem Schliessen erhalten.',
                                  'Create a profile. Your progress, points and cats stay saved after closing the app.',
                                ),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: () => editName(),
                                child: Text(t('Los geht’s', 'Get started')),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t('Hallo, ${p.name}!', 'Hello, ${p.name}!'),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            Chip(
                              avatar: const Icon(Icons.stars, size: 18),
                              label: Text(
                                '${p.points} ${t('Punkte', 'points')}',
                              ),
                            ),
                          ],
                        ),
                        if (tab == 0) ...learn(p),
                        if (tab == 1) ...cats(p),
                        if (tab == 2) ...stats(p),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> learn(Learner p) {
    final engine = AdaptiveEngine();
    final recommended = engine.recommend(p);
    return [
      panel(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('DEIN NÄCHSTER SCHRITT', 'YOUR NEXT STEP'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            title(recommended.title(s.en)),
            Text(
              t(
                'Wir wählen Aufgaben nach deinen Fehlern und deiner Antwortzeit. Schwierige Aufgaben kommen häufiger wieder.',
                'Questions adapt to your mistakes and response time. Difficult questions return more often.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => start(recommended, PracticeMode.training),
              icon: const Icon(Icons.play_arrow),
              label: Text(t('Empfohlenes Training', 'Recommended practice')),
            ),
          ],
        ),
      ),
      if (!p.assessed)
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('Wo stehst du?', 'Where shall we start?'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                t(
                  '9 Aufgaben ohne Zeitdruck helfen bei der Orientierung. Du kannst auch direkt üben.',
                  '9 untimed questions help find a starting point. You can also practise right away.',
                ),
              ),
              TextButton(
                onPressed: () => start(levels.first, PracticeMode.placement),
                child: Text(
                  t('Kurze Einstufung starten', 'Start short assessment'),
                ),
              ),
            ],
          ),
        ),
      title(t('Deine neun Rechengruppen', 'Your nine maths groups')),
      Text(
        t(
          'Alle Gruppen sind frei wählbar. 10 richtige Antworten hintereinander in der Challenge schalten eine Katze frei.',
          'Choose any group. 10 correct answers in a row in a challenge unlock a cat.',
        ),
      ),
      for (final l in levels)
        panel(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(child: Text(l.symbol)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.title(s.en),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (p.unlocked.contains(l.id))
                    const Icon(Icons.pets, color: Colors.teal),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                engine.ready(l, p)
                    ? t(
                        'Schon gut geübt – bleib dran!',
                        'Well practised — keep going!',
                      )
                    : t('Noch im Aufbau', 'Building confidence'),
              ),
              if (engine.prerequisites(l).any((x) => !engine.ready(x, p)))
                Text(
                  t('Hilfreich vorher: ', 'Helpful first: ') +
                      engine
                          .prerequisites(l)
                          .where((x) => !engine.ready(x, p))
                          .map((x) => x.title(s.en))
                          .join(', '),
                ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () => explain(l),
                    child: Text(t('Erklärung', 'Explanation')),
                  ),
                  FilledButton.tonal(
                    onPressed: () => start(l, PracticeMode.training),
                    child: Text(t('Üben', 'Practise')),
                  ),
                  TextButton(
                    onPressed: () => start(l, PracticeMode.challenge),
                    child: Text(
                      'Challenge · ${engine.challengeSeconds(l, p)} s',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    ];
  }

  void explain(Level l) {
    final text = switch (l.operation) {
      Operation.plus => t(
        'Addition bedeutet Zusammenzählen. 3 + 2 = 5. Starte bei 3 und zähle zwei Schritte weiter: 4, 5.',
        'Addition means putting amounts together. 3 + 2 = 5. Start at 3 and count two steps: 4, 5.',
      ),
      Operation.minus => t(
        'Subtraktion bedeutet Wegnehmen. 5 − 2 = 3. Starte bei 5 und zähle zwei Schritte zurück: 4, 3.',
        'Subtraction means taking away. 5 − 2 = 3. Start at 5 and count back two steps: 4, 3.',
      ),
      Operation.times => t(
        'Multiplikation bedeutet gleich grosse Gruppen zusammenzählen. 3 × 2 = 2 + 2 + 2 = 6.',
        'Multiplication adds equal groups. 3 × 2 = 2 + 2 + 2 = 6.',
      ),
    };
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.title(s.en)),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<Widget> cats(Learner p) => [
    title(t('Deine Katzen', 'Your cats')),
    Text(
      t(
        'Pro richtiger Antwort gibt es 2 Punkte. Eine neue Katze bringt 10 Bonuspunkte. Eine Portion Futter kostet 5 Punkte. Deine Katzen müssen nie hungern.',
        'Each correct answer earns 2 points. A new cat earns 10 bonus points. One serving costs 5 points. Your cats never go hungry.',
      ),
    ),
    for (final l in levels)
      panel(
        Row(
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: p.unlocked.contains(l.id)
                  ? Image.asset('lib/images/cat${l.index + 1}.png')
                  : const Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.title(s.en),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    p.unlocked.contains(l.id)
                        ? t(
                            '${p.feedings[l.id] ?? 0} Portionen gefüttert',
                            '${p.feedings[l.id] ?? 0} servings given',
                          )
                        : t(
                            'Gewinne die Challenge für diese Katze.',
                            'Win the challenge to unlock this cat.',
                          ),
                  ),
                  if (p.unlocked.contains(l.id))
                    FilledButton.tonalIcon(
                      onPressed: p.points < 5
                          ? null
                          : () async {
                              final fed = await s.feed(p, l);
                              if (fed && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      t(
                                        'Miau! Deine Katze freut sich über das Futter.',
                                        'Meow! Your cat enjoys the food.',
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                      icon: const Icon(Icons.restaurant),
                      label: Text(t('Füttern · 5 Punkte', 'Feed · 5 points')),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
  ];
  List<Widget> stats(Learner p) {
    final now = DateTime.now();
    final days = List.generate(
      7,
      (i) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i)),
    );
    final counts = days
        .map(
          (d) => p.sessions
              .where(
                (x) =>
                    x.date.year == d.year &&
                    x.date.month == d.month &&
                    x.date.day == d.day,
              )
              .fold(0, (a, x) => a + x.attempts),
        )
        .toList();
    final maximum = max(1, counts.reduce(max));
    return [
      title(t('Dein Lernfortschritt', 'Your learning progress')),
      panel(
        Text(
          t(
            '${p.attempts} Antworten · ${p.correct} richtig · ${p.unlocked.length}/9 Katzen',
            '${p.attempts} answers · ${p.correct} correct · ${p.unlocked.length}/9 cats',
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      title(t('Antworten der letzten 7 Tage', 'Answers in the last 7 days')),
      panel(
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            7,
            (i) => Expanded(
              child: Column(
                children: [
                  Text('${counts[i]}'),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: 8 + 70 * counts[i] / maximum,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Text(
                    '${days[i].day}.${days[i].month}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      for (final l in levels) ...[
        panel(
          Builder(
            builder: (context) {
              final values = p.progress(l).toList();
              final n = values.fold(0, (a, x) => a + x.attempts);
              final c = values.fold(0, (a, x) => a + x.correct);
              final ms = values.fold(0, (a, x) => a + x.milliseconds);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.title(s.en),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: n == 0 ? 0 : c / n,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n == 0
                        ? t('Noch keine Antworten', 'No answers yet')
                        : t(
                            '$c von $n richtig · Ø ${(ms / n / 1000).toStringAsFixed(1)} s pro Antwort',
                            '$c of $n correct · avg ${(ms / n / 1000).toStringAsFixed(1)} s per answer',
                          ),
                  ),
                  TextButton(
                    onPressed: () => start(l, PracticeMode.training),
                    child: Text(t('Weiterüben', 'Keep practising')),
                  ),
                ],
              );
            },
          ),
        ),
      ],
      title(t('Letzte Übungen', 'Recent sessions')),
      if (p.sessions.isEmpty)
        Text(
          t(
            'Deine Übungen erscheinen hier.',
            'Your sessions will appear here.',
          ),
        ),
      for (final r in p.sessions.reversed.take(20))
        ListTile(
          title: Text(
            r.mode == PracticeMode.placement
                ? t('Einstufung', 'Assessment')
                : levels.firstWhere((l) => l.id == r.levelId).title(s.en),
          ),
          subtitle: Text(
            '${r.date.day}.${r.date.month}.${r.date.year} · ${r.correct}/${r.attempts} · ${r.seconds}s · ${r.completed ? t('beendet', 'finished') : t('unterbrochen', 'stopped')}',
          ),
        ),
      Text(
        t(
          'Zeiten messen nur das aktive Antworten, nicht das Lesen von Rückmeldungen oder Pausen. Empfehlungen sind eine Orientierung, keine Schulnote.',
          'Times measure active answering, excluding feedback and pauses. Recommendations are guidance, not a school grade.',
        ),
      ),
    ];
  }
}

class PracticePage extends StatefulWidget {
  final LearningStore store;
  final Learner learner;
  final Level level;
  final PracticeMode mode;
  const PracticePage({
    super.key,
    required this.store,
    required this.learner,
    required this.level,
    required this.mode,
  });
  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage>
    with WidgetsBindingObserver {
  late final PracticeSession session;
  Timer? timer;
  final watch = Stopwatch();
  int lastMs = 0;
  String answer = '';
  bool recorded = false;
  int? sessionIndex;
  LearningStore get s => widget.store;
  String t(String de, String en) => s.tr(de, en);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    session = PracticeSession(
      widget.learner,
      widget.level,
      widget.mode,
      AdaptiveEngine(),
    );
    watch.start();
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      final before = session.remaining;
      final wasFinished = session.finished;
      advanceClock();
      if (session.remaining != before || session.finished != wasFinished) {
        setState(() {});
      }
    });
  }

  void advanceClock() {
    final now = watch.elapsedMilliseconds;
    session.tick(now - lastMs);
    lastMs = now;
    if (session.finished) record();
  }

  void record() {
    if (recorded) return;
    recorded = true;
    saveProgress();
  }

  void saveProgress() {
    if (session.attempts > 0) {
      if (sessionIndex == null) {
        sessionIndex = widget.learner.sessions.length;
        widget.learner.sessions.add(session.result());
      } else {
        widget.learner.sessions[sessionIndex!] = session.result();
      }
    }
    s.save();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      advanceClock();
      session.paused = true;
      s.save();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    watch.stop();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> leave() async {
    if (session.finished) {
      if (mounted) Navigator.pop(context);
      return;
    }
    advanceClock();
    setState(() => session.paused = true);
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('Übung beenden?', 'End practice?')),
        content: Text(
          t(
            'Deine bisherigen Antworten und Punkte bleiben gespeichert.',
            'Your answers and points so far remain saved.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('Weiterüben', 'Keep practising')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('Beenden', 'End')),
          ),
        ],
      ),
    );
    if (yes == true) {
      record();
      await s.flushed;
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      setState(() => session.paused = false);
    }
  }

  void submit() {
    advanceClock();
    if (session.submit(answer) == null) return;
    saveProgress();
    if (session.finished) record();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final q = session.question;
    return PopScope(
      canPop: session.finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) leave();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: leave,
            tooltip: t('Zurück', 'Back'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            widget.mode == PracticeMode.placement
                ? t('Einstufung', 'Assessment')
                : widget.level.title(s.en),
          ),
          actions: [
            if (!session.finished)
              IconButton(
                tooltip: t('Pause', 'Pause'),
                onPressed: () {
                  advanceClock();
                  setState(() => session.paused = !session.paused);
                },
                icon: Icon(session.paused ? Icons.play_arrow : Icons.pause),
              ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (s.error == 'save')
                    Text(
                      t(
                        'Speichern fehlgeschlagen. Bitte vor dem Schliessen erneut versuchen.',
                        'Saving failed. Please retry before closing.',
                      ),
                    ),
                  if (session.finished) ...[
                    Icon(
                      session.successful ? Icons.pets : Icons.auto_awesome,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Text(
                      session.successful
                          ? t('Challenge geschafft!', 'Challenge complete!')
                          : t('Gut geübt!', 'Good practice!'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      t(
                        '${session.correct} von ${session.attempts} richtig. Beste Serie: ${session.bestStreak}.',
                        '${session.correct} of ${session.attempts} correct. Best streak: ${session.bestStreak}.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (session.awaitingNext)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '${q.expression} = ${q.answer}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    if (session.successful)
                      Image.asset(
                        'lib/images/cat${widget.level.index + 1}.png',
                        height: 200,
                      ),
                    if (widget.mode == PracticeMode.challenge &&
                        !session.successful)
                      Text(
                        t(
                          'Die Zeit ist um. Deine Punkte bleiben. Im Training kannst du ohne Zeitdruck üben.',
                          'Time is up. You keep your points. Practice mode has no time limit.',
                        ),
                      ),
                    if (widget.mode == PracticeMode.placement)
                      Text(
                        t(
                              'Empfohlener Einstieg: ',
                              'Recommended starting point: ',
                            ) +
                            AdaptiveEngine()
                                .recommend(widget.learner)
                                .title(s.en),
                      ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: leave,
                      child: Text(t('Zur Übersicht', 'Back to overview')),
                    ),
                  ] else if (session.paused) ...[
                    const Icon(Icons.pause_circle_outline, size: 80),
                    Text(
                      t(
                        'Pause – deine Zeit steht still.',
                        'Paused — your timer is stopped.',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => setState(() => session.paused = false),
                      child: Text(t('Weiter', 'Resume')),
                    ),
                  ] else ...[
                    Text(
                      widget.mode == PracticeMode.challenge
                          ? t(
                              'Serie ${session.streak}/10 · noch ${session.remaining} s',
                              'Streak ${session.streak}/10 · ${session.remaining} s left',
                            )
                          : t(
                              'Aufgabe ${session.attempts + (session.awaitingNext ? 0 : 1)}/${widget.mode == PracticeMode.placement ? 9 : 10} · ohne Zeitdruck',
                              'Question ${session.attempts + (session.awaitingNext ? 0 : 1)}/${widget.mode == PracticeMode.placement ? 9 : 10} · no time limit',
                            ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          children: [
                            Text(q.level.title(s.en)),
                            const SizedBox(height: 16),
                            FittedBox(
                              child: Text(
                                '${q.expression} = ?',
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Semantics(
                              label: t('Deine Antwort', 'Your answer'),
                              liveRegion: true,
                              child: Text(
                                answer.isEmpty ? '…' : answer,
                                style: const TextStyle(
                                  fontSize: 38,
                                  color: Color(0xff26786f),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (session.awaitingNext) ...[
                      Text(
                        session.lastRight == true
                            ? t('Richtig! +2 Punkte', 'Correct! +2 points')
                            : t(
                                'Schau nochmals: ${q.expression} = ${q.answer}',
                                'Take another look: ${q.expression} = ${q.answer}',
                              ),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (session.lastRight == false)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(hint(q), textAlign: TextAlign.center),
                        ),
                      FilledButton(
                        onPressed: () {
                          session.next();
                          setState(() => answer = '');
                        },
                        child: Text(t('Nächste Aufgabe', 'Next question')),
                      ),
                    ] else ...[
                      for (final row in [
                        ['7', '8', '9'],
                        ['4', '5', '6'],
                        ['1', '2', '3'],
                        ['⌫', '0', '✓'],
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: row
                                .map(
                                  (key) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: FilledButton.tonal(
                                        onPressed: () {
                                          if (key == '✓') {
                                            submit();
                                          } else {
                                            setState(() {
                                              if (key == '⌫') {
                                                if (answer.isNotEmpty) {
                                                  answer = answer.substring(
                                                    0,
                                                    answer.length - 1,
                                                  );
                                                }
                                              } else if (answer.length < 4) {
                                                answer += key;
                                              }
                                            });
                                          }
                                        },
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(64, 60),
                                        ),
                                        child: Semantics(
                                          label: key == '⌫'
                                              ? t('Löschen', 'Delete')
                                              : key == '✓'
                                              ? t(
                                                  'Antwort prüfen',
                                                  'Check answer',
                                                )
                                              : key,
                                          child: Text(
                                            key,
                                            style: const TextStyle(
                                              fontSize: 28,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String hint(Question q) => switch (q.level.operation) {
    Operation.plus => t(
      'Starte bei ${q.a} und zähle ${q.b} dazu.',
      'Start at ${q.a} and add ${q.b}.',
    ),
    Operation.minus => t(
      'Starte bei ${q.a} und gehe ${q.b} Schritte zurück.',
      'Start at ${q.a} and count back ${q.b} steps.',
    ),
    Operation.times => t(
      '${q.a} Gruppen mit je ${q.b}: ${List.filled(q.a, '${q.b}').join(' + ')} = ${q.answer}.',
      '${q.a} groups of ${q.b}: ${List.filled(q.a, '${q.b}').join(' + ')} = ${q.answer}.',
    ),
  };
}
