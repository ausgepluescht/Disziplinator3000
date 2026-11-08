/// Werkzeug, das zu einer Technik gehört (eigener Bildschirm).
enum Tool { surf, reframe, distance, seesaw, council, why, sprint, alternatives, audit }

class Technique {
  final int nr;
  final String title;

  /// Das Motto aus dem Video, in Lora kursiv.
  final String motto;

  /// Ein Satz für die Kachel.
  final String short;
  final String explain;

  /// Was die Forschung dazu sagt.
  final String evidence;

  /// Gesunder Kritiker: wo die Technik ihre Grenzen hat.
  final String critique;

  /// Fragen für den Impuls-Stapel. Platzhalter: {name}, {ego}.
  final List<String> prompts;
  final Tool? tool;
  final String? toolLabel;

  const Technique({
    required this.nr,
    required this.title,
    required this.motto,
    required this.short,
    required this.explain,
    required this.evidence,
    required this.critique,
    required this.prompts,
    this.tool,
    this.toolLabel,
  });

  String get nrLabel => nr.toString().padLeft(2, '0');
}

const techniques = <Technique>[
  Technique(
    nr: 1,
    title: 'Urge Surfing',
    motto: 'Reite die Welle, statt gegen sie zu schwimmen.',
    short: 'Nicht wegdrücken. Neugierig hinspüren, bis die Welle bricht.',
    explain: 'Willenskraft gegen ein Verlangen ist wie ein Schwamm gegen eine Welle. Stattdessen lässt du das Verlangen da sein und beobachtest es im Körper: Wo sitzt es, wie fühlt es sich an, wird es stärker oder schwächer? Du merkst zweierlei. Es wird aushaltbar. Und es kommt und geht wie eine Welle. Starte mit 5 Minuten Timer, danach darfst du tun, was du willst. Beim nächsten Mal etwas länger, bis etwa 30 Minuten. Dann sind die meisten Verlangen weg.',
    evidence: 'In einer randomisierten Studie mit Rauchenden rauchten diejenigen, die Urge Surfing gelernt hatten, deutlich weniger als die Gruppe, die es mit Willenskraft versuchte (Bowen & Marlatt, 2009).',
    critique: 'Es ist Training, kein Zaubertrick. Die ersten Male fühlen sich holprig an. Und Achtung: Hinspüren heißt nicht Ausmalen. Sobald du dir Geschmack, Geruch oder den ersten Klick vorstellst, fütterst du das Verlangen (siehe Technik 08).',
    prompts: [
      'Wo genau in deinem Körper sitzt das Verlangen gerade?',
      'Ist es eher Druck, Zug, Kribbeln, Hitze oder Unruhe?',
      'Auf einer Skala von 0 bis 10: Wie stark ist die Welle jetzt?',
      'Was passiert, wenn du die Welle einfach da sein lässt, ohne zu handeln?',
      'Hattest du je ein Verlangen, das nicht irgendwann von selbst gegangen ist?',
      'Wird die Welle gerade höher oder flacher? Schau genau hin.',
    ],
    tool: Tool.surf,
    toolLabel: 'Surf-Timer starten',
  ),
  Technique(
    nr: 2,
    title: 'Abstrakt machen',
    motto: 'Der Marshmallow ist nur eine weiße Wolke.',
    short: 'Den Glanz abziehen. Beschreib es nüchtern wie ein Laborbericht.',
    explain: 'Was vor dir liegt, zählt weniger als das, was in deinem Kopf passiert. Kinder, die sich die Marshmallows als weiße Wattewolken vorstellten, hielten viel länger durch. Kinder, die sich ein Bild davon als echt vorstellten, gaben viel schneller nach. Also: Aus dem warmen, cremigen Schokokuchen wird brauner Industriebrei aus Zucker und Fett. Aus Instagram wird eine Glasscheibe mit farbigen Pixeln.',
    evidence: 'Klassische Belohnungsaufschub-Experimente von Walter Mischel und Kollegen in den 1970ern: Wer an die abstrakten, nicht verlockenden Eigenschaften dachte, wartete deutlich länger.',
    critique: 'Abstrahieren heißt nicht schlechtreden um jeden Preis. Es geht darum, das Versprechen abzuziehen, das Werbung und Gewohnheit draufgelegt haben. Wenn du dich dabei ertappst, dich selbst fertigzumachen, bist du zu weit.',
    prompts: [
      'Beschreib das, was du willst, so nüchtern wie einen Laborbericht.',
      'Woraus besteht das eigentlich? Zucker, Fett, Pixel, Stoff?',
      'Wer verdient gerade daran, dass du das willst?',
      'Wie würde ein Außerirdischer beschreiben, was du gleich tun willst?',
      'Was bleibt übrig, wenn du das Versprechen abziehst, das es dir macht?',
    ],
    tool: Tool.reframe,
    toolLabel: 'Nüchterne Beschreibungen',
  ),
  Technique(
    nr: 3,
    title: 'Eklig machen',
    motto: 'Ekel schlägt Gier.',
    short: 'Feuer mit Feuer bekämpfen. Stell dir Kakerlaken drauf vor.',
    explain: 'Niemand will eine Suppe trinken, in die er gerade selbst gespuckt hat, obwohl beim Essen ohnehin immer Speichel im Spiel ist. Schon die Vorstellung von etwas Ekligem infiziert den Genuss. Ekel ist tief in uns verdrahtet, weil er unsere Vorfahren vor Verdorbenem geschützt hat. Du nutzt einen Urtrieb gegen einen anderen: Gier gegen Ekel.',
    evidence: 'Ekel-Forschung (u. a. Paul Rozin) zeigt: Schon der Gedanke an Kontamination, etwa ein Haar im Essen, verdirbt den Appetit zuverlässig.',
    critique: 'Ein Notfallwerkzeug, kein Dauerzustand. Wenn du zu Essstörungen neigst, lass diese Technik beim Essen weg. Dein Verhältnis zu Essen soll gesund bleiben, nicht angstbesetzt.',
    prompts: [
      'Stell dir vor, Kakerlaken krabbeln über genau das, was du gerade willst.',
      'Stell dir ein langes, fremdes Haar darin vor.',
      'Wer hat das vor dir schon alles angefasst?',
      'Stell dir vor, jemand filmt dich genau jetzt und zeigt das Video morgen allen.',
    ],
    tool: Tool.reframe,
    toolLabel: 'Ekel-Bilder',
  ),
  Technique(
    nr: 4,
    title: 'Batman-Technik',
    motto: 'Arbeitet Batman gerade hart?',
    short: 'Abstand zu dir selbst. Sprich von dir in der dritten Person.',
    explain: 'Kinder, die als Batman verkleidet waren und gefragt wurden „Arbeitet Batman gerade hart?“, blieben am längsten bei einer langweiligen Aufgabe. Je mehr Abstand zum Ich, desto mehr Selbstkontrolle. Zwei Wege für Erwachsene: Sprich von dir in der dritten Person („Okay {name}, was ist hier der Move?“). Oder stell dir vor, ein Freund steht vor genau dieser Entscheidung. Bei anderen sehen wir sofort klar, bei uns selbst stehen wir uns im Weg.',
    evidence: 'Der „Batman-Effekt“ (White, Carlson u. a., 2017) und Solomons Paradox (Grossmann & Kross, 2014): Wir urteilen bei fremden Problemen weiser als bei eigenen.',
    critique: 'Fühlt sich am Anfang albern an. Genau das ist der Punkt: Der Abstand nimmt der Situation die Dringlichkeit. Wer sich dabei aber nur als Richter beschimpft, verfehlt das Ziel. Sprich mit dir wie ein guter Trainer.',
    prompts: [
      'Okay {name}, was ist hier der Move?',
      'Arbeitet {ego} gerade hart?',
      'Was würde {ego} jetzt tun?',
      'Ein guter Freund steht genau vor dieser Entscheidung. Was rätst du ihm?',
      '{name} in zwei Stunden: dankbar oder genervt?',
      'Wenn du {name} gerade von außen beobachtest: Was siehst du?',
    ],
    tool: Tool.distance,
    toolLabel: 'Name & Alter Ego festlegen',
  ),
  Technique(
    nr: 5,
    title: 'Entscheidungs-Wippe',
    motto: 'Mach es unfair.',
    short: 'Acht Felder. Nutzen und Kosten, kurz- und langfristig, für beide Optionen.',
    explain: 'Gym oder Couch? Zeichne eine Wippe. Jede Seite ist eine Option. Für jede Option schreibst du auf: Nutzen kurzfristig, Nutzen langfristig, Kosten kurzfristig, Kosten langfristig. Du wusstest schon vorher, dass die Couch nicht gut ist. Du hast die Folgen nur nicht gespürt. Aufschreiben zwingt dich, konkret zu werden, und holt die Konsequenzen emotional ins Jetzt.',
    evidence: 'Keine einzelne Studie, sondern ein Prinzip: Konkretes, schriftliches Durchdenken von Folgen aktiviert die emotionale Bewertung, die beim abstrakten „Ich weiß ja“ fehlt.',
    critique: 'Kippt die Wippe trotzdem zur bequemen Seite, prüf ehrlich: Hast du die Kosten kleingeredet? Oder ist die Pause gerade wirklich das Richtige? Beides kann stimmen. Entscheidend ist, dass du bewusst entscheidest.',
    prompts: [
      'Was kostet dich die schwierigere Option wirklich? In Minuten, nicht in Gefühlen.',
      'Was kostet dich die bequeme Option in einem Jahr?',
      'Wie fühlst du dich heute Abend, wenn du jetzt die leichte Option nimmst?',
      'Welche Folge kennst du eigentlich längst, spürst sie aber gerade nicht?',
    ],
    tool: Tool.seesaw,
    toolLabel: 'Wippe ausfüllen',
  ),
  Technique(
    nr: 6,
    title: 'Rat der Ichs',
    motto: 'Jeder bekommt eine Stimme. Auch der Hamster.',
    short: 'Jetzt-Ich, Heute-Abend-Ich, Zukunfts-Ich und das 80-jährige Ich stimmen ab.',
    explain: 'Du bist nicht eine Person, sondern ein ganzer Rat. Das Jetzt-Ich will es bequem. Das Heute-Abend-Ich muss mit den Folgen leben. Das Zukunfts-Ich profitiert oder bezahlt. Das 80-jährige Ich auf dem Sterbebett sieht das große Ganze. Und der Hamster, dein kleiner Kumpel, will eigentlich nur Ruhe, Wärme oder einen Snack. Alle stimmen ab.',
    evidence: 'Forschung zur Verbundenheit mit dem zukünftigen Selbst (Hal Hershfield): Wer sich seinem zukünftigen Ich nahe fühlt, entscheidet langfristiger, etwa beim Sparen.',
    critique: 'Das Jetzt-Ich hat auch eine legitime Stimme. Wenn es ernsthaft Erholung braucht, ist das kein Verrat. Gefährlich wird es nur, wenn es jedes Mal allein entscheidet.',
    prompts: [
      'Was sagt dein 80-jähriges Ich zu diesem Moment?',
      'Was wünscht sich dein Ich von heute Abend, dass du jetzt tust?',
      'Was braucht der Hamster wirklich? Ruhe, Wärme, Zucker oder Bestätigung?',
      'Wer im Rat schreit gerade am lautesten? Und hat er recht?',
      'Wofür wird dir dein Zukunfts-Ich in einem Jahr danken?',
    ],
    tool: Tool.council,
    toolLabel: 'Rat einberufen',
  ),
  Technique(
    nr: 7,
    title: 'Why-Motor',
    motto: 'Wer ein Warum hat, erträgt fast jedes Wie.',
    short: 'Ein Brief an dich selbst. Lies ihn, wenn die Disziplin rutscht.',
    explain: 'Du willst nicht abnehmen, weil es nett ist, nicht dick zu sein. Du willst lange genug leben, um die Abschlussfeier deiner Enkelin zu erleben. Du arbeitest nicht für eine Zahl auf dem Konto, sondern für Freiheit. Schreib dein Warum als Brief an dich selbst, in allen Details. Aufgeschrieben ist es echt, und du kannst ihm nicht ausweichen. Wenn die Disziplin rutscht, lies den Brief. Dann ist das Verlangen nur noch eine kleine Unbequemlichkeit.',
    evidence: 'Nach Nietzsche, bekannt geworden durch Viktor Frankl: „Wer ein Warum zum Leben hat, erträgt fast jedes Wie.“ Werteklärung ist zudem fester Bestandteil der Akzeptanz- und Commitment-Therapie.',
    critique: 'Ein Warum, das nur im Kopf existiert, verpufft. Ein Warum, das nicht deins ist, sondern das von Instagram, ebenso. Prüf deinen Brief alle paar Monate: Stimmt das noch? Berührt es dich noch?',
    prompts: [
      'Für wen machst du das eigentlich?',
      'Wie sieht ein ganz konkreter Tag in deinem Leben aus, wenn du dranbleibst?',
      'Was ist der Preis, wenn du so weitermachst wie bisher?',
      'Ist dein Warum stark genug, um gegen dieses Verlangen zu gewinnen? Was fehlt?',
    ],
    tool: Tool.why,
    toolLabel: 'Mein Warum',
  ),
  Technique(
    nr: 8,
    title: 'Urge Sprint',
    motto: 'Mach es verschwinden, bevor es wächst.',
    short: 'Drei Schritte: Auslöser weg, bewegen, Kopf beschäftigen.',
    explain: 'Die meisten Verlangensgedanken verschwinden von selbst. Die wenigen, die bleiben, wachsen durch zwei Dinge: Du spielst Erinnerungen ab, oder du machst einen „Nur mal schauen“-Check. Habe ich noch Geld für Zigaretten? Ist noch Schokolade da? Dabei malst du dir Geschmack, Geruch und den ersten Bissen aus, und das Verlangen rollt wie ein Schneeball. Genau dann hast du ein kurzes Zeitfenster für den Sprint: 1. Auslöser sofort weg, ohne nachzudenken. 2. Bewegen, schon 15 Minuten Gehen wirken. 3. Den Kopf beschäftigen, zum Beispiel mit einem 3-Minuten-Spiel, das dein Arbeitsgedächtnis füllt.',
    evidence: 'Elaborated-Intrusion-Theorie des Verlangens (Kavanagh, Andrade & May, 2005). Kurze Bewegung senkt Rauch- und Schokoladenverlangen messbar (u. a. Studien von Adrian Taylor). Schon 3 Minuten Tetris reduzierten Verlangen nach Essen, Nikotin, Alkohol und mehr (Skorka-Brown u. a.).',
    critique: 'Der Sprint funktioniert nur, wenn du schnell bist. Wer erst überlegt, ob er ihn machen sollte, ist schon mitten im Ausmalen. Mach ihn zum Reflex.',
    prompts: [
      'Machst du gerade einen „Nur mal schauen“-Check? Hör sofort auf.',
      'Spielst du gerade den ersten Bissen, Zug oder Klick im Kopf durch?',
      'Was kannst du in den nächsten 10 Sekunden tun, damit es unmöglich wird?',
      'Kannst du jetzt für 15 Minuten raus?',
    ],
    tool: Tool.sprint,
    toolLabel: 'Sprint starten',
  ),
  Technique(
    nr: 9,
    title: 'Bessere Optionen',
    motto: 'Mach es verlieren.',
    short: 'Die Alternative muss sofort da sein und darf nichts kosten.',
    explain: 'Ratten in einem kahlen Käfig wurden morphinabhängig. Ratten in einem großen Park mit Artgenossen tranken ein Vielfaches weniger. Süchtige Ratten wählten fast immer den Hebel zu einem Artgenossen statt den zur Droge. Aber nur, solange die Alternative sofort und ohne Strafe verfügbar war. Island hat die Jugend-Saufquote gedrückt, indem es Sport, Musik und Theater für jede Familie bezahlbar machte. Wir greifen zum Handy, weil wir nichts Besseres griffbereit haben. Also schaff dir Alternativen. Und einen Buddy, den du jederzeit anrufen darfst.',
    evidence: 'Rat Park (Bruce Alexander, um 1980), Wahlexperimente mit sozialer Belohnung bei abhängigen Ratten (Venniro u. a., 2018) und das isländische Präventionsmodell „Youth in Iceland“.',
    critique: 'Rat Park ließ sich nicht immer sauber reproduzieren, und Islands Erfolg hat viele Ursachen. Die Kernidee bleibt stark. Prüf deine Alternativen hart: Sind sie wirklich sofort da? Kosten sie wirklich nichts? Sonst gewinnt das Handy.',
    prompts: [
      'Was wäre jetzt sofort, ohne Aufwand, eine gute Alternative?',
      'Wen könntest du jetzt anrufen?',
      'Fehlen dir gerade Optionen oder fehlt dir Energie?',
      'Was hast du heute schon gemacht, das dich wirklich erfüllt hat?',
      'Was liegt in Griffweite, das besser ist als das hier?',
    ],
    tool: Tool.alternatives,
    toolLabel: 'Alternativen & Buddy',
  ),
  Technique(
    nr: 10,
    title: 'Unsichtbar machen',
    motto: 'Gewinn nicht die Schlacht. Entfern das Schlachtfeld.',
    short: 'Cue-Audit: vom Verlangen zurück zur Situation, die es auslöst.',
    explain: 'Die diszipliniertesten Menschen brauchen ihre Disziplin am wenigsten. Sie bauen ihr Leben so, dass Versuchungen gar nicht erst auftauchen. Dafür der Cue-Audit, wie in der Rückfallprävention: Was will ich wirklich? Was habe ich gerade gefühlt? Welcher Gedanke kam davor? Welche Situation hat diesen Gedanken erzeugt? Dann änderst du die Situation. Beispiel: Jeden Abend um 22 Uhr Doomscrolling. Ursache: Du fällst nach der Arbeit mit dem Handy aufs Sofa. Lösung: Um 21:30 kommt das Handy ins Ladegerät im Flur, auf dem Sofa liegt ein gutes Buch.',
    evidence: 'Situative Strategien gelten als die wirksamste Form der Selbstkontrolle (Duckworth u. a., 2016). Der Abgleich von Auslösern ist Standard in der Rückfallprävention.',
    critique: 'Die stärkste und die langweiligste Technik. Sie hilft dir nicht in diesem Moment, sondern ab morgen. Mach den Audit trotzdem, am besten direkt, nachdem du nachgegeben hast. Dann ist die Erinnerung frisch.',
    prompts: [
      'Was willst du gerade wirklich? Nicht das Ding, sondern das Gefühl dahinter.',
      'Was hast du direkt vor dem Verlangen gefühlt?',
      'Welcher Gedanke kam unmittelbar davor? „Ich hab mir das verdient“?',
      'Welche Situation erzeugt diesen Moment immer wieder?',
      'Wie könntest du das Schlachtfeld entfernen, statt die Schlacht zu gewinnen?',
    ],
    tool: Tool.audit,
    toolLabel: 'Cue-Audit machen',
  ),
];

Technique techniqueByNr(int nr) => techniques.firstWhere((t) => t.nr == nr);
