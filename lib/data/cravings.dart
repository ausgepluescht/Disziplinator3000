import 'package:flutter/material.dart';

/// Was dich gerade lockt. Jede Kategorie bringt eigene
/// Formulierungen für die Techniken 2, 3, 8 und 9 mit.
class Craving {
  final String id;
  final String label;
  final IconData icon;

  /// Notfall-Sprint, Schritt 1: Auslöser sofort aus dem Weg räumen.
  final List<String> removeTrigger;

  /// Technik 2: Abstrakt machen.
  final List<String> abstract;

  /// Technik 3: Eklig machen.
  final List<String> disgust;

  /// Technik 9: Alternativen, die sofort verfügbar sind und nichts kosten.
  final List<String> alternatives;

  /// Selbst angelegt? Dann enthalten die Listen nur die eigenen Einträge;
  /// fehlende Inhalte ergänzt [cravingById] aus „Etwas anderes“.
  final bool custom;

  const Craving({
    required this.id,
    required this.label,
    required this.icon,
    required this.removeTrigger,
    required this.abstract,
    required this.disgust,
    required this.alternatives,
    this.custom = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'removeTrigger': removeTrigger,
    'abstract': abstract,
    'disgust': disgust,
    'alternatives': alternatives,
  };

  factory Craving.fromJson(Map<String, dynamic> j) => Craving(
    id: j['id'] as String,
    label: j['label'] as String? ?? 'Eigene Kategorie',
    icon: Icons.label_outline_rounded,
    removeTrigger: (j['removeTrigger'] as List?)?.cast<String>() ?? const [],
    abstract: (j['abstract'] as List?)?.cast<String>() ?? const [],
    disgust: (j['disgust'] as List?)?.cast<String>() ?? const [],
    alternatives: (j['alternatives'] as List?)?.cast<String>() ?? const [],
    custom: true,
  );

  /// Eigene Einträge zuerst, danach die allgemeinen aus [fallback].
  Craving mergedWith(Craving fallback) => Craving(
    id: id,
    label: label,
    icon: icon,
    removeTrigger: [...removeTrigger, ...fallback.removeTrigger],
    abstract: [...abstract, ...fallback.abstract],
    disgust: [...disgust, ...fallback.disgust],
    alternatives: [...alternatives, ...fallback.alternatives],
    custom: true,
  );
}

const builtinCravings = <Craving>[
  Craving(
    id: 'handy',
    label: 'Handy & Social Media',
    icon: Icons.smartphone_outlined,
    removeTrigger: [
      'Leg das Handy in einen anderen Raum. Jetzt, nicht gleich.',
      'Schließ die App und leg das Handy mit dem Display nach unten weg.',
      'Schalte den Graustufen-Modus ein oder nimm die App vom Startbildschirm.',
    ],
    abstract: [
      'Eine Glasscheibe mit bunten Pixeln, programmiert von Leuten, deren Gehalt von deiner Bildschirmzeit abhängt.',
      'Ein Algorithmus, der dir Ausschnitte aus dem Leben von Fremden zeigt, die du nie treffen wirst.',
      'Ein Spielautomat, der statt Münzen deine Aufmerksamkeit schluckt.',
      'Dopamin-Häppchen im Zwei-Sekunden-Takt. An keines davon wirst du dich morgen erinnern.',
    ],
    disgust: [
      'Dein Display: Wie oft hast du es heute angefasst? Und wie oft geputzt? Stell dir den Schmierfilm unter dem Mikroskop vor.',
      'Stell dir vor, jemand filmt dich die nächste Stunde beim Scrollen. Krummer Rücken, leerer Blick, offener Mund. Morgen zeigt er das Video deinen Freunden.',
      'Stell dir vor, jedes Like ist ein kleiner Tropfen Spucke eines Fremden auf deinem Display.',
    ],
    alternatives: [
      '10 Seiten in einem Buch lesen, das schon bereitliegt',
      'Fenster auf und 2 Minuten rausschauen',
      'Jemanden anrufen, statt Fremden zuzuschauen',
      'Kurz aufräumen: eine Fläche, fünf Minuten',
    ],
  ),
  Craving(
    id: 'essen',
    label: 'Essen & Süßes',
    icon: Icons.cookie_outlined,
    removeTrigger: [
      'Wirf den Snack weg oder pack ihn ganz hinten in den Schrank, außer Sichtweite.',
      'Raus aus der Küche. Tür zu.',
      'Putz dir die Zähne. Danach schmeckt nichts mehr richtig.',
    ],
    abstract: [
      'Brauner Industriebrei aus Zucker, Palmfett und Aromen, im Labor auf den perfekten Kick getrimmt.',
      'Ein Produkt, dessen Rezept so lange optimiert wurde, bis dein Gehirn nicht mehr Stopp sagen kann.',
      '400 Kalorien, die in 90 Sekunden weg sind und dich 30 Minuten später müde machen.',
      'Bunte Verpackung, Füllstoffe, Zucker. Der Hersteller hat mehr Geld ins Design gesteckt als in die Zutaten.',
    ],
    disgust: [
      'Stell dir vor, eine Handvoll Kakerlaken krabbelt gerade über genau dieses Essen.',
      'Stell dir ein langes, fremdes Haar darin vor, das du erst beim Runterschlucken bemerkst.',
      'Stell dir vor, jemand hat schon einmal davon abgebissen und es zurückgelegt.',
      'Stell dir die Fabrikhalle vor: Fett tropft von Förderbändern, die seit Wochen niemand geputzt hat.',
    ],
    alternatives: [
      'Ein großes Glas Wasser trinken, dann 10 Minuten warten',
      'Ein Stück Obst oder eine Handvoll Nüsse',
      'Tee kochen: das Ritual statt des Snacks',
      '15 Minuten zügig spazieren gehen',
    ],
  ),
  Craving(
    id: 'kaufen',
    label: 'Spontan kaufen',
    icon: Icons.shopping_bag_outlined,
    removeTrigger: [
      'Tab schließen. Warenkorb leeren.',
      'Lösch die gespeicherten Zahlungsdaten aus dem Shop.',
      'Melde dich vom Newsletter ab, der dich gerade dorthin gelockt hat.',
    ],
    abstract: [
      'Massenware, tausendfach in einer Fabrik zusammengenäht, mit einem Logo drauf, das dir ein Gefühl verkaufen soll.',
      'Ein Gegenstand, der in drei Wochen in einer Schublade liegt.',
      'Du tauschst gerade mehrere Stunden Arbeitszeit gegen einen kurzen Kick beim Auspacken.',
      'Ein Bild, das ein Marketingteam so lange getestet hat, bis du klickst.',
    ],
    disgust: [
      'Stell dir die Retourenhalle vor: Hunderte anprobierte, verschwitzte Teile. Deins könnte eins davon sein.',
      'Stell dir vor, wie das Ding in einem Jahr verstaubt in der Ecke liegt und du dich bei jedem Blick ein bisschen schämst.',
      'Stell dir den Geruch vor, wenn es nach Wochen im Container ausgepackt wird.',
    ],
    alternatives: [
      'Auf eine 72-Stunden-Liste schreiben und dann entscheiden',
      'Etwas reparieren oder benutzen, das du schon hast',
      'Den Betrag stattdessen für dein Warum zurücklegen',
      'Den Schrank öffnen und drei Dinge aussortieren',
    ],
  ),
  Craving(
    id: 'serie',
    label: 'Serien & YouTube',
    icon: Icons.tv_outlined,
    removeTrigger: [
      'Schalte das Gerät aus, nicht nur auf Pause. Fernbedienung in die Schublade.',
      'Schalte die automatische Wiedergabe aus. Jetzt.',
      'Klapp den Laptop zu und bring ihn in einen anderen Raum.',
    ],
    abstract: [
      'Bewegte Lichtpunkte, die dir Geschichten über Menschen zeigen, die es nicht gibt.',
      'Eine Autoplay-Funktion, die nur einen Zweck hat: dass du sitzen bleibst.',
      'Drei Stunden, an die du dich in einem Jahr nicht mehr erinnern wirst.',
    ],
    disgust: [
      'Stell dir dich nach der fünften Folge vor: Krümel auf dem Shirt, steifer Nacken, es ist 1 Uhr nachts.',
      'Stell dir das Sofapolster vor, in dem du gerade versinkst. Wann wurde es zuletzt gewaschen?',
      'Stell dir vor, wie du dich morgen früh fühlst, wenn der Wecker klingelt und du weißt, warum du so müde bist.',
    ],
    alternatives: [
      'Nur noch eine Folge, dann Gerät aus und Buch auf',
      'Musik an und nebenbei etwas Kleines erledigen',
      'Jemanden treffen oder anrufen',
      'Früher ins Bett gehen',
    ],
  ),
  Craving(
    id: 'zocken',
    label: 'Zocken',
    icon: Icons.sports_esports_outlined,
    removeTrigger: [
      'Zieh den Stecker der Konsole. Controller in einen anderen Raum.',
      'Lösch das Spiel vom Startbildschirm deines Handys.',
      'Leg feste Spielzeiten in den Kalender. Außerhalb davon bleibt das Gerät aus.',
    ],
    abstract: [
      'Ein Belohnungssystem aus Zahlen und Lichteffekten, das dir Fortschritt vorgaukelt, den es außerhalb des Bildschirms nicht gibt.',
      'Deine Spielfigur steigt ein Level auf, während dein echtes Leben auf Level 1 wartet.',
      'Ein Produkt, das ein Team von Psychologen auf möglichst lange Spielzeit optimiert hat.',
    ],
    disgust: [
      'Stell dir deinen Controller unter dem Mikroskop vor: Schweiß, Hautschuppen und Chipskrümel von Monaten.',
      'Stell dir vor, wie du nach vier Stunden aufstehst: Kopfschmerzen, trockene Augen, der Abend ist vorbei.',
    ],
    alternatives: [
      'Ein Brett- oder Kartenspiel mit echten Menschen',
      'Ein echtes Projekt mit sichtbarem Fortschritt: Instrument, Sport, Werkstatt',
      'Rausgehen und eine Runde laufen',
    ],
  ),
  Craving(
    id: 'substanz',
    label: 'Rauchen & Alkohol',
    icon: Icons.smoking_rooms_outlined,
    removeTrigger: [
      'Zigaretten oder Flaschen aus dem Blickfeld räumen, besser noch aus der Wohnung.',
      'Gib das Feuerzeug weg.',
      'Verlass den Ort, an dem du sonst rauchst oder trinkst.',
    ],
    abstract: [
      'Ein Röllchen aus getrockneten Blättern und Zusatzstoffen, dessen Rauch du freiwillig in deine Lunge ziehst.',
      'Ethanol mit Geschmack. Ein Zellgift, das man dir als Feierabend verkauft.',
      'Ein Konzern hat längst ausgerechnet, wie viel du in deinem Leben noch dafür ausgeben wirst.',
    ],
    disgust: [
      'Stell dir den Aschenbecher am Morgen danach vor. Und den Geruch in deinen Haaren und Klamotten.',
      'Stell dir eine Raucherlunge im Glas vor, schwarz und verklebt.',
      'Stell dir den schalen Rest im Glas vom Vorabend vor, mit einer toten Fliege darin.',
    ],
    alternatives: [
      'Kaltes Wasser mit Zitrone, langsam trinken',
      '10 tiefe Atemzüge am offenen Fenster',
      'Kaugummi oder etwas für die Hände',
      'Den Buddy anrufen',
    ],
  ),
  Craving(
    id: 'porno',
    label: 'Pornos',
    icon: Icons.no_adult_content_outlined,
    removeTrigger: [
      'Leg Handy oder Laptop sofort weg und verlass den Raum. Licht an, Tür auf.',
      'Schließ alle Tabs und Apps. Kein „nur noch kurz schauen“.',
      'Aktiviere einen Inhaltsfilter, zum Beispiel in den Bildschirmzeit- oder Jugendschutz-Einstellungen deines Handys.',
    ],
    abstract: [
      'Pixel auf einer Glasscheibe. Fremde Menschen, die dafür bezahlt werden, eine Rolle zu spielen.',
      'Eine Industrie, die an deinen Klicks verdient und ihre Seiten darauf trimmt, dass du nicht aufhörst.',
      'Ein Algorithmus, der dir immer stärkere Reize vorschlägt, weil die alten nicht mehr reichen.',
      'Drehbuch, Scheinwerfer, Schnitt und Nachbearbeitung. Mit echter Nähe hat das so viel zu tun wie ein Werbespot mit einem Abendessen.',
    ],
    disgust: [
      'Stell dir vor, dein Browserverlauf erscheint morgen früh auf dem großen Bildschirm im Meeting.',
      'Stell dir vor, jemand, den du respektierst, steht genau jetzt hinter dir und schaut auf deinen Bildschirm.',
      'Stell dir den Moment 20 Minuten danach vor: leer, müde, und der Abend ist trotzdem weg.',
    ],
    alternatives: [
      'Kalt duschen',
      '20 Liegestütze oder Kniebeugen, sofort',
      '10 Minuten an die frische Luft',
      'Jemanden anrufen oder anschreiben',
      'Ins Wohnzimmer wechseln, das Handy bleibt im Flur',
    ],
  ),
  Craving(
    id: 'aufschieben',
    label: 'Aufschieben',
    icon: Icons.hourglass_empty_rounded,
    removeTrigger: [
      'Schließ alles außer dem einen Fenster, das du für die Aufgabe brauchst.',
      'Handy in einen anderen Raum, Timer auf 25 Minuten.',
      'Schreib nur den allerersten Schritt auf und erledige ihn sofort. Mehr nicht.',
    ],
    abstract: [
      'Die Aufgabe ist kein Berg. Sie ist ein Dokument, ein Anruf, drei Sätze, 25 Minuten.',
      'Du gehst nicht der Aufgabe aus dem Weg, sondern ein paar Minuten Unbehagen.',
      'Die Ausrede ist ein Satz in deinem Kopf, kein Naturgesetz.',
    ],
    disgust: [
      'Stell dir den Moment heute um 23 Uhr vor: Aufgabe unerledigt, schweres Gefühl im Bauch, Licht aus, Gedankenkarussell an.',
      'Stell dir vor, die Aufgabe fängt an zu riechen, und zwar jeden Tag ein bisschen fauliger, den sie liegen bleibt.',
      'Stell dir vor, wie du morgen jemandem erklären musst, warum es schon wieder nicht fertig ist.',
    ],
    alternatives: [
      'Nur 5 Minuten anfangen, danach darfst du aufhören',
      'Die Aufgabe in den kleinsten möglichen Schritt zerlegen',
      'Jemandem schreiben, bis wann du es erledigt hast',
      'Den Ort wechseln: Café, Bibliothek, anderer Raum',
    ],
  ),
  Craving(
    id: 'sonst',
    label: 'Etwas anderes',
    icon: Icons.blur_on_rounded,
    removeTrigger: [
      'Räum den Auslöser aus dem Blickfeld. Sofort, ohne nachzudenken.',
      'Wechsle den Raum.',
      'Bring so viele Schritte wie möglich zwischen dich und den Auslöser.',
    ],
    abstract: [
      'Beschreib es so nüchtern wie in einem Laborbericht: Material, Funktion, wer daran verdient.',
      'Was bleibt davon übrig, wenn du das Versprechen weglässt, das es dir macht?',
    ],
    disgust: [
      'Stell dir vor, Kakerlaken krabbeln über genau das, was du gerade willst.',
      'Stell dir vor, jemand filmt dich in diesem Moment und zeigt das Video morgen allen.',
    ],
    alternatives: ['15 Minuten zügig gehen', 'Jemanden anrufen', 'Etwas lesen, das schon bereitliegt'],
  ),
];

/// Selbst angelegte Kategorien. Der Store hält diese Liste aktuell.
final List<Craving> customCravings = [];

Craving get _other => builtinCravings.last;

/// Alle Kategorien zur Auswahl: feste, dann eigene, „Etwas anderes“ zuletzt.
List<Craving> get cravings => [...builtinCravings.where((c) => c.id != 'sonst'), ...customCravings, _other];

/// Eine Kategorie mit vollständigen Inhalten. Eigene Kategorien werden mit
/// den allgemeinen Formulierungen aus „Etwas anderes“ aufgefüllt.
Craving cravingById(String? id) {
  for (final c in builtinCravings) {
    if (c.id == id) return c;
  }
  for (final c in customCravings) {
    if (c.id == id) return c.mergedWith(_other);
  }
  return _other;
}
