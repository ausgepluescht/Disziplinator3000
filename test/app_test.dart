import 'package:disziplinator/data/cravings.dart';
import 'package:disziplinator/data/impulses.dart';
import 'package:disziplinator/data/techniques.dart';
import 'package:disziplinator/main.dart';
import 'package:disziplinator/screens/sos.dart';
import 'package:disziplinator/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Store> _store() async {
  SharedPreferences.setMockInitialValues({});
  final s = Store();
  await s.load();
  return s;
}

void main() {
  test('Zehn Techniken, jede mit Impulsen', () {
    expect(techniques.length, 10);
    for (final t in techniques) {
      expect(t.prompts, isNotEmpty, reason: t.title);
    }
  });

  test('Stapel ersetzt Platzhalter und enthält Sätze aus dem Warum', () async {
    final s = await _store();
    s.name = 'Martin';
    s.why = 'Ich will mit meinen Kindern noch mit 70 wandern gehen. Das ist mir wichtig.';
    final deck = buildDeck(s);
    expect(deck.any((i) => i.text.contains('{')), isFalse);
    expect(deck.any((i) => i.text.contains('Martin')), isTrue);
    expect(deck.any((i) => i.kind == 'warum'), isTrue);
  });

  test('Pornos ist eine feste Kategorie mit vollständigen Inhalten', () {
    final c = cravingById('porno');
    expect(c.label, 'Pornos');
    expect(c.removeTrigger, isNotEmpty);
    expect(c.alternatives, isNotEmpty);
    expect(cravings.last.id, 'sonst');
  });

  test('Eigene Kategorie wird gespeichert, geladen und aufgefüllt', () async {
    final s = await _store();
    s.saveCustomCraving(
      const Craving(
        id: 'c_1',
        label: 'Nachts Essen bestellen',
        icon: Icons.label_outline_rounded,
        removeTrigger: ['Liefer-App löschen'],
        abstract: [],
        disgust: [],
        alternatives: ['Brot schmieren'],
        custom: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    // Neu laden wie nach einem App-Neustart
    final s2 = Store();
    customCravings.clear();
    await s2.load();
    expect(cravings.map((c) => c.label), contains('Nachts Essen bestellen'));
    expect(cravings.last.id, 'sonst');

    final c = cravingById('c_1');
    expect(c.removeTrigger.first, 'Liefer-App löschen');
    expect(c.alternatives.first, 'Brot schmieren');
    expect(c.abstract, isNotEmpty, reason: 'leere Felder kommen aus „Etwas anderes“');
    expect(buildDeck(s2, craving: 'c_1').any((i) => i.text == c.abstract.first), isTrue);

    s2.deleteCustomCraving('c_1');
    expect(cravingById('c_1').id, 'sonst');
  });

  test('Serie zählt nur Tage ohne Nachgeben', () async {
    final s = await _store();
    final now = DateTime.now();
    s.logs = [
      LogEntry(at: now, craving: 'handy', before: 7, outcome: 'resisted'),
      LogEntry(at: now.subtract(const Duration(days: 1)), craving: 'handy', before: 7, outcome: 'resisted'),
      LogEntry(at: now.subtract(const Duration(days: 2)), craving: 'essen', before: 7, outcome: 'gave_in'),
    ];
    expect(s.streak, 2);
  });

  testWidgets('Akut-Modus läuft bis zum Protokoll durch', (tester) async {
    final s = await _store();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(DisziplinatorApp(store: s));
    expect(find.text('Was lockt dich gerade?'), findsOneWidget);

    await tester.tap(find.text('Ich werde gerade schwach.'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Essen & Süßes'));
    await tester.ensureVisible(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    expect(find.text('Auslöser weg. Jetzt.'), findsOneWidget);
    await tester.tap(find.textContaining('Putz dir die Zähne'));
    await tester.pump();
    await tester.tap(find.text('Erledigt. Weiter'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Die Welle ist vorbei'),
      300,
      scrollable: find.descendant(of: find.byType(SosScreen), matching: find.byType(Scrollable)).first,
    );
    await tester.tap(find.text('Die Welle ist vorbei'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('Widerstanden'));
    await tester.pumpAndSettle();

    expect(s.logs.length, 1);
    expect(s.logs.first.resisted, isTrue);
    expect(s.logs.first.before, 7);
    expect(s.logs.first.after, 3);
    expect(s.logs.first.used, contains('Auslöser entfernt'));
  });
}
