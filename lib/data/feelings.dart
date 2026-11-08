/// Werkzeuge im Akut-Modus, die zu einem Gefühl passen.
enum SosTool { surf, move, game, why, alt, buddy, seesaw, council }

/// Ein Gefühl, das hinter einem Verlangen stecken kann.
class Feeling {
  final String id;
  final String label;

  /// Frage, die genau dieses Gefühl ernst nimmt.
  final String prompt;

  /// Technik, aus der die Frage stammt (für die Karte im Stapel).
  final int tech;

  /// Welche Werkzeuge bei diesem Gefühl am ehesten helfen.
  final List<SosTool> tools;

  const Feeling(this.id, this.label, this.prompt, this.tech, this.tools);
}

const feelings = <Feeling>[
  Feeling('muede', 'Müde', 'Du bist müde. Würde dir Schlaf oder eine echte Pause gerade mehr geben als das hier?', 6, [
    SosTool.alt,
    SosTool.council,
  ]),
  Feeling('langeweile', 'Gelangweilt', 'Langeweile ist kein Notfall. Was würde dich jetzt wirklich interessieren?', 9, [
    SosTool.game,
    SosTool.alt,
  ]),
  Feeling(
    'stress',
    'Gestresst',
    'Stress will Entlastung, keine Betäubung. Was würde dich gerade wirklich entlasten?',
    8,
    [SosTool.move, SosTool.surf],
  ),
  Feeling(
    'einsam',
    'Einsam',
    'Einsamkeit lässt sich nicht wegklicken. Wem könntest du jetzt schreiben oder wen anrufen?',
    9,
    [SosTool.buddy, SosTool.alt],
  ),
  Feeling('frust', 'Frustriert', 'Frust braucht ein Ventil. Kannst du ihn rauslaufen, statt ihn zu betäuben?', 8, [
    SosTool.move,
    SosTool.council,
  ]),
  Feeling('traurig', 'Traurig', 'Traurigkeit will gesehen werden, nicht betäubt. Was brauchst du gerade wirklich?', 6, [
    SosTool.buddy,
    SosTool.why,
  ]),
  Feeling(
    'unruhig',
    'Unruhig',
    'Unruhe ist eine Welle im Körper. Kannst du sie zwei Minuten lang beobachten, ohne zu handeln?',
    1,
    [SosTool.surf, SosTool.move],
  ),
  Feeling(
    'angst',
    'Ängstlich',
    'Angst will, dass du flüchtest. Was passiert, wenn du stattdessen kurz hinschaust?',
    1,
    [SosTool.surf, SosTool.buddy],
  ),
  Feeling(
    'ueberfordert',
    'Überfordert',
    'Überforderung schrumpft, wenn du nur den nächsten Schritt anschaust. Welcher ist es?',
    5,
    [SosTool.surf, SosTool.seesaw],
  ),
  Feeling('leer', 'Leer', 'Leere füllt sich nicht durch Konsum. Was hat dich zuletzt wirklich erfüllt?', 7, [
    SosTool.why,
    SosTool.buddy,
  ]),
  Feeling(
    'verdient',
    'Hab ich mir verdient',
    'Du hast dir etwas verdient. Aber ist das hier wirklich eine Belohnung oder nur Gewohnheit?',
    5,
    [SosTool.seesaw, SosTool.council],
  ),
];

Feeling? feelingById(String id) {
  for (final f in feelings) {
    if (f.id == id) return f;
  }
  return null;
}

/// Die Bezeichnungen zu gespeicherten IDs, unbekannte werden übersprungen.
List<String> feelingLabels(Iterable<String> ids) => [for (final id in ids) ?feelingById(id)?.label];
