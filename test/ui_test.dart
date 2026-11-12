import 'dart:io';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/data/store.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/domain/learning.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/main.dart';
import 'package:mathe_lern_app_adaptiv_android_ios/ui/app.dart';

class MemoryStore extends LearningStore {
  MemoryStore() : super(Directory.systemTemp);
  @override
  Future<void> save() async {}
}

void main() {
  testWidgets(
    'small phone: create profile, start practice, pause, answer, leave without duplicate history',
    (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStore();
      await tester.pumpWidget(MathApp(store: store));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Los geht’s'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mia');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();
      expect(find.text('Hallo, Mia!'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.ensureVisible(find.text('Empfohlenes Training'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Empfohlenes Training'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.textContaining('ohne Zeitdruck'), findsOneWidget);
      await tester.tap(find.byTooltip('Pause'));
      await tester.pump();
      expect(find.text('Pause – deine Zeit steht still.'), findsOneWidget);
      await tester.tap(find.text('Weiter'));
      await tester.pump();
      final expression =
          (tester.widgetList<Text>(find.byType(Text)).map((w) => w.data ?? ''))
              .firstWhere((v) => v.endsWith('= ?'));
      final numbers = RegExp(
        r'\d+',
      ).allMatches(expression).map((m) => int.parse(m.group(0)!)).toList();
      for (final digit in '${numbers[0] + numbers[1]}'.split('')) {
        await tester.tap(find.text(digit).last);
        await tester.pump();
      }
      await tester.tap(find.text('✓'));
      await tester.pump();
      expect(find.text('Richtig! +2 Punkte'), findsOneWidget);
      expect(store.current!.correct, 1);
      expect(store.current!.sessions.single.correct, 1);
      await tester.tap(find.byTooltip('Zurück'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beenden'));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(store.current!.points, 2);
      expect(store.current!.sessions.length, 1);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 2));
    },
  );
  for (final size in [const Size(320, 568), const Size(1024, 768)]) {
    testWidgets('home and keypad fit viewport $size with scrolling', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStore();
      store.profiles.add(Learner('1', 'Alex'));
      store.selectedId = '1';
      await tester.pumpWidget(MathApp(store: store));
      await tester.pumpAndSettle();
      expect(tester.takeException(), null);
      await tester.ensureVisible(find.text('Empfohlenes Training'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Empfohlenes Training'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(PracticePage), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
