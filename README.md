# Disziplinator 3000

Ein Werkzeugkasten für den Moment, in dem die Disziplin rutscht. Flutter-App, kein Login, keine Cloud: Alles bleibt auf deinem Handy.

Die Inhalte basieren auf [diesem YouTube-Video](https://www.youtube.com/watch?v=y7e3VLr1hgI) über zehn Techniken der Selbstkontrolle, ergänzt um Quellen und einen kritischen Blick auf jede Technik.

| Start | Akut-Modus | Technik (dunkel) |
|---|---|---|
| ![Start](docs/home.png) | ![Akut](docs/akut.png) | ![Technik](docs/technik_dunkel.png) |

## Was die App kann

**Akut-Modus** (die schwarze Kachel oben): in vier Schritten durch das Verlangen.
1. *Was zieht?* Kategorie wählen, Stärke 0 bis 10.
2. *Auslöser weg.* Konkrete Handgriffe passend zur Kategorie.
3. *Welle brechen.* Wisch-Stapel mit Fragen und Bildern plus Werkzeuge: Surfen, Bewegen, Kopf füllen, Warum lesen, Alternative ziehen, Buddy anrufen, Wippe, Rat der Ichs.
4. *Ausgang.* Stärke danach, widerstanden oder nachgegeben. Nach dem Nachgeben bietet die App direkt den Cue-Audit an.

**Impuls-Stapel**: Karten mit Fragen zum Hinterfragen. Nach links wischen für die nächste, nach rechts zum Merken. Sätze aus deinem eigenen Warum-Brief tauchen im Stapel mit auf (schwarze Karten).

**Die 10 Techniken**, jede mit Erklärung, Forschung, „Kritisch hinterfragt“ und eigenem Werkzeug:

| Nr. | Technik | Werkzeug |
|---|---|---|
| 01 | Urge Surfing | Surf-Timer mit Welle und Körperfragen, wird jedes Mal eine Minute länger (bis 30 Min.) |
| 02 | Abstrakt machen | Nüchterne Beschreibungen je Kategorie, eigene Version merken |
| 03 | Eklig machen | Ekel-Bilder je Kategorie |
| 04 | Batman-Technik | Name und Alter Ego für die dritte Person, Solomon-Modus |
| 05 | Entscheidungs-Wippe | 8 Felder mit Gewichten, die Wippe kippt live |
| 06 | Rat der Ichs | Jetzt-Ich, Heute-Abend-Ich, Zukunfts-Ich, 80-jähriges Ich und Hamster stimmen ab |
| 07 | Why-Motor | Brief an dich selbst mit Leitfragen, Lesemodus |
| 08 | Urge Sprint | Auslöser weg, Bewegungs-Timer, 3-Minuten-Musterspiel fürs Arbeitsgedächtnis |
| 09 | Bessere Optionen | Eigene Alternativen, Zufallsziehung, Buddy mit Anruf und SMS |
| 10 | Unsichtbar machen | Cue-Audit: Verlangen, Gefühl, Gedanke, Situation, Umbau |

**Protokoll**: Quote, Serie, häufigster Auslöser, kritischste Uhrzeit, was bei dir wirklich hilft.

## Design

Schwarz-Weiß, Hell- und Dunkelmodus (folgt dem System oder fest einstellbar). Drei Schriften mit klaren Rollen:

- **Inter** für Struktur: Titel, Knöpfe, Fließtext
- **Lora kursiv** für Fragen, Gedanken und Zitate
- **JetBrains Mono** für Nummern, Zeiten und Etiketten

Die Schriften liegen in `assets/fonts` (SIL Open Font License), die App funktioniert komplett offline.

## Auf das Handy bringen

### Android, ohne eigene Entwicklungsumgebung (empfohlen)
Bei jedem Push baut GitHub Actions die App und legt sie als Release ab.
1. Am Handy im Browser öffnen: `github.com/ausgepluescht/Disziplinator3000/releases/latest`
2. Unter *Assets* auf `Disziplinator.apk` tippen und herunterladen.
3. Die Datei öffnen. Android fragt einmal, ob der Browser Apps installieren darf: erlauben.
4. Installieren. Die App erscheint als „Disziplinator“ mit schwarzem D3K-Symbol.

Updates: neue APK genauso installieren, deine Daten bleiben erhalten. Play Protect warnt eventuell, weil die App nicht aus dem Play Store kommt: „Trotzdem installieren“.

### Android, lokal
```bash
flutter pub get
```
```bash
flutter build apk --release
```
Die APK liegt danach unter `build/app/outputs/flutter-apk/app-release.apk`. Oder mit angeschlossenem Handy direkt `flutter run --release`.

### iPhone
Braucht einen Mac mit Xcode: `ios/Runner.xcworkspace` öffnen, eigenes Team unter *Signing* wählen, auf das Gerät installieren. Mit einem kostenlosen Apple-Account läuft die App 7 Tage, dann neu installieren.

## Technik

- Flutter (Dart), Material 3, keine State-Management-Bibliothek
- Speicherung lokal über `shared_preferences`, ein JSON-Dokument
- `url_launcher` für Anruf und SMS an den Buddy
- Inhalte in `lib/data/techniques.dart` und `lib/data/cravings.dart`, leicht erweiterbar
- Tests: `flutter test`
