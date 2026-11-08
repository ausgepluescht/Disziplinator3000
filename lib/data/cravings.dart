import 'package:flutter/material.dart';

/// Wonach es dich gerade zieht. Jede Kategorie bringt eigene
/// Formulierungen für die Techniken 2, 3, 8 und 9 mit.
class Craving {
  final String id;
  final String label;
  final IconData icon;

  /// Urge Sprint, Schritt 1: Auslöser sofort aus dem Weg räumen.
  final List<String> removeTrigger;

  /// Technik 2: Mach es abstrakt.
  final List<String> abstract;

  /// Technik 3: Mach es eklig.
  final List<String> disgust;

  /// Technik 9: Alternativen, die sofort verfügbar sind und nichts kosten.
  final List<String> alternatives;

  const Craving({
    required this.id,
    required this.label,
    required this.icon,
    required this.removeTrigger,
    required this.abstract,
    required this.disgust,
    required this.alternatives,
  });
}

const cravings = <Craving>[
  Craving(
    id: 'handy',
    label: 'Handy & Social Media',
    icon: Icons.smartphone_outlined,
    removeTrigger: [
      'Handy in einen anderen Raum legen. Jetzt, nicht gleich.',
      'App schließen und das Handy mit dem Display nach unten weglegen.',
      'Graustufen-Modus einschalten oder die App vom Startbildschirm entfernen.',
    ],
    abstract: [
      'Eine Glasscheibe mit farbigen Pixeln, programmiert von Leuten, deren Gehalt von deiner Bildschirmzeit abhängt.',
      'Ein Algorithmus, der dir Ausschnitte aus dem Leben von Fremden zeigt, die du nie treffen wirst.',
      'Ein Spielautomat, der statt Münzen deine Aufmerksamkeit frisst.',
      'Dopamin-Häppchen im Takt von zwei Sekunden. Kein einziges davon wirst du morgen noch erinnern.',
    ],
    disgust: [
      'Dein Display: Wie oft hast du es heute angefasst? Wie oft hast du es geputzt? Stell dir den Film darauf unter dem Mikroskop vor.',
      'Stell dir vor, jemand filmt dich die nächste Stunde beim Scrollen. Krummer Rücken, leerer Blick, offener Mund. Und zeigt das Video morgen deinen Freunden.',
      'Stell dir vor, jeder Like ist ein kleiner Tropfen Sabber von einem Fremden auf deinem Display.',
    ],
    alternatives: [
      '10 Seiten in einem Buch lesen, das schon griffbereit liegt',
      'Fenster auf, 2 Minuten rausschauen',
      'Jemanden anrufen statt Fremden zuzuschauen',
      'Kurz aufräumen: eine Fläche, fünf Minuten',
    ],
  ),
  Craving(
    id: 'essen',
    label: 'Essen & Süßes',
    icon: Icons.cookie_outlined,
    removeTrigger: [
      'Den Snack wegwerfen oder ganz hinten in den Schrank, außer Sichtweite.',
      'Raus aus der Küche. Tür zu.',
      'Zähne putzen. Danach schmeckt nichts mehr richtig.',
    ],
    abstract: [
      'Brauner Industriebrei aus Zucker, Palmfett und Aromastoffen, entwickelt im Labor auf den perfekten Kick.',
      'Ein Produkt, dessen Rezept so lange optimiert wurde, bis dein Gehirn nicht mehr Stopp sagen kann.',
      '400 Kalorien, die in 90 Sekunden weg sind und dich in 30 Minuten müde machen.',
      'Bunte Verpackung, Füllstoff, Zuckerwasser. Der Hersteller hat mehr ins Design gesteckt als in die Zutaten.',
    ],
    disgust: [
      'Stell dir vor, eine Handvoll Kakerlaken krabbelt gerade über genau dieses Essen.',
      'Stell dir ein langes, fremdes Haar darin vor, das du erst beim Runterschlucken bemerkst.',
      'Stell dir vor, jemand hat das gerade schon einmal angebissen und zurückgelegt.',
      'Stell dir die Fabrikhalle vor: Fett tropft von Förderbändern, die seit Wochen keiner geputzt hat.',
    ],
    alternatives: [
      'Großes Glas Wasser trinken, dann 10 Minuten warten',
      'Ein Stück Obst oder eine Handvoll Nüsse',
      'Tee kochen, das Ritual statt dem Snack',
      '15 Minuten zügig spazieren',
    ],
  ),
  Craving(
    id: 'kaufen',
    label: 'Spontan kaufen',
    icon: Icons.shopping_bag_outlined,
    removeTrigger: [
      'Tab schließen. Warenkorb leeren.',
      'Gespeicherte Zahlungsdaten aus dem Shop löschen.',
      'Newsletter abbestellen, der dich gerade dorthin gelockt hat.',
    ],
    abstract: [
      'Ein Stück Massenware, in einer Fabrik zu tausenden zusammengenäht, mit einer Marke drauf, die dir ein Gefühl verkaufen soll.',
      'Ein Gegenstand, der in drei Wochen in einer Schublade liegt.',
      'Du tauschst gerade X Stunden deiner Arbeitszeit gegen einen kurzen Kick beim Auspacken.',
      'Ein Bild, das ein Marketingteam so lange getestet hat, bis du klickst.',
    ],
    disgust: [
      'Stell dir die Retourenhalle vor: Hunderte anprobierte, verschwitzte Teile, das hier könnte eins davon sein.',
      'Stell dir vor, wie das Ding in einem Jahr verstaubt in der Ecke liegt und du dich bei jedem Blick ein bisschen schämst.',
      'Stell dir vor, wie es riecht, wenn es nach Wochen im Container aus China ausgepackt wird.',
    ],
    alternatives: [
      'Auf eine 72-Stunden-Liste schreiben und später entscheiden',
      'Etwas reparieren oder nutzen, das du schon hast',
      'Den Betrag in die Sparkasse für dein Warum überweisen',
      'Schrank öffnen und drei Dinge aussortieren',
    ],
  ),
  Craving(
    id: 'serie',
    label: 'Serien & YouTube',
    icon: Icons.tv_outlined,
    removeTrigger: [
      'Gerät ausschalten, nicht nur pausieren. Fernbedienung in eine Schublade.',
      'Autoplay ausschalten. Jetzt.',
      'Laptop zuklappen und in einen anderen Raum tragen.',
    ],
    abstract: [
      'Bewegte Lichtpunkte, die dir Geschichten von Leuten zeigen, die es nicht gibt.',
      'Ein Autoplay-Mechanismus, dessen einziger Zweck ist, dass du nicht aufstehst.',
      'Drei Stunden, die du in einem Jahr nicht mehr benennen könntest.',
    ],
    disgust: [
      'Stell dir dich nach der fünften Folge vor: Krümel auf dem Shirt, steifer Nacken, es ist 1 Uhr nachts.',
      'Stell dir das Sofapolster vor, in dem du gerade versinkst. Wann wurde es zuletzt gewaschen?',
      'Stell dir das Gefühl morgen früh vor, wenn der Wecker klingelt und du weißt, warum du so müde bist.',
    ],
    alternatives: [
      'Eine einzige Folge, dann Gerät aus und Buch auf',
      'Musik an und dabei etwas Kleines erledigen',
      'Jemanden treffen oder anrufen',
      'Früher ins Bett, Schlaf ist der beste Binge',
    ],
  ),
  Craving(
    id: 'zocken',
    label: 'Zocken',
    icon: Icons.sports_esports_outlined,
    removeTrigger: [
      'Konsole vom Strom trennen. Controller in einen anderen Raum.',
      'Spiel vom Startbildschirm des Handys löschen.',
      'Feste Spielzeit in den Kalender, außerhalb davon bleibt das Gerät aus.',
    ],
    abstract: [
      'Ein Belohnungssystem aus Zahlen und Lichteffekten, das dir Fortschritt vorgaukelt, der außerhalb des Bildschirms nicht existiert.',
      'Ein Level-Up für eine Figur, während dein echtes Leben auf Level 1 wartet.',
      'Ein Produkt, das ein Team von Psychologen auf maximale Spielzeit optimiert hat.',
    ],
    disgust: [
      'Stell dir deinen Controller unter dem Mikroskop vor: Schweiß, Hautschuppen, Chipskrümel von Monaten.',
      'Stell dir vor, wie du nach vier Stunden aufstehst: Kopfschmerzen, trockene Augen, verpasster Abend.',
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
      'Zigaretten oder Flaschen aus dem Blickfeld, besser aus der Wohnung.',
      'Feuerzeug weggeben.',
      'Den Ort wechseln, an dem du sonst rauchst oder trinkst.',
    ],
    abstract: [
      'Ein Röhrchen mit getrocknetem Blattwerk und Zusatzstoffen, dessen Rauch du freiwillig in deine Lunge ziehst.',
      'Ethanol mit Geschmack. Ein Zellgift, das man dir als Feierabend verkauft.',
      'Ein Konzern hat ausgerechnet, wie viel du in deinem Leben noch dafür ausgibst.',
    ],
    disgust: [
      'Stell dir den Aschenbecher am Morgen danach vor. Den Geruch in deinen Haaren und Klamotten.',
      'Stell dir eine Raucherlunge im Glas vor, schwarz und verklebt.',
      'Stell dir den schalen Rest im Glas vom Vorabend vor, mit einer toten Fliege darin.',
    ],
    alternatives: [
      'Kaltes Wasser mit Zitrone, langsam trinken',
      '10 tiefe Atemzüge am offenen Fenster',
      'Kaugummi oder etwas zum Knabbern für die Hände',
      'Buddy anrufen',
    ],
  ),
  Craving(
    id: 'aufschieben',
    label: 'Aufschieben',
    icon: Icons.hourglass_empty_rounded,
    removeTrigger: [
      'Alles schließen außer dem einen Fenster, das du für die Aufgabe brauchst.',
      'Handy in einen anderen Raum, Timer auf 25 Minuten.',
      'Nur den allerersten Schritt aufschreiben und sofort machen. Nicht mehr.',
    ],
    abstract: [
      'Die Aufgabe ist kein Berg. Sie ist ein Dokument, ein Anruf, drei Sätze, 25 Minuten.',
      'Was du vermeidest, ist nicht die Aufgabe. Es ist ein Gefühl von ein paar Minuten Unbehagen.',
      'Die Ausrede ist ein Satz in deinem Kopf, kein Naturgesetz.',
    ],
    disgust: [
      'Stell dir den Moment heute um 23 Uhr vor: Aufgabe unerledigt, schweres Gefühl im Bauch, Licht aus, Gedankenkarussell an.',
      'Stell dir vor, wie die Aufgabe jeden Tag ein bisschen fauliger riecht, je länger sie liegt.',
      'Stell dir vor, wie du morgen jemandem erklären musst, warum es wieder nicht fertig ist.',
    ],
    alternatives: [
      'Nur 5 Minuten anfangen, dann darfst du aufhören',
      'Die Aufgabe in den kleinsten möglichen Schritt zerlegen',
      'Jemandem schreiben, bis wann du es erledigt hast',
      'An einen anderen Ort wechseln: Café, Bibliothek, anderer Raum',
    ],
  ),
  Craving(
    id: 'sonst',
    label: 'Etwas anderes',
    icon: Icons.blur_on_rounded,
    removeTrigger: [
      'Den Auslöser aus dem Blickfeld räumen. Sofort, ohne nachzudenken.',
      'Den Raum wechseln.',
      'Zwischen dich und den Auslöser so viele Schritte bringen wie möglich.',
    ],
    abstract: [
      'Beschreib es so nüchtern wie ein Laborbericht: Material, Funktion, wer daran verdient.',
      'Was ist es, wenn man ihm das Versprechen abzieht, das es dir macht?',
    ],
    disgust: [
      'Stell dir vor, Kakerlaken krabbeln über genau das, was du gerade willst.',
      'Stell dir vor, jemand filmt dich in diesem Moment und zeigt das Video morgen allen.',
    ],
    alternatives: ['15 Minuten zügig gehen', 'Jemanden anrufen', 'Etwas lesen, das griffbereit liegt'],
  ),
];

Craving cravingById(String? id) => cravings.firstWhere((c) => c.id == id, orElse: () => cravings.last);
