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
    motto: 'Reite die Welle, statt gegen sie anzuschwimmen.',
    short: 'Nicht wegdrücken. Neugierig hinspüren, bis die Welle bricht.',
    explain: 'Gegen ein Verlangen anzukämpfen kostet Kraft und hält selten lange. Beim Urge Surfing lässt du das Verlangen da sein und beobachtest es in deinem Körper: Wo sitzt es? Wie fühlt es sich an? Wird es stärker oder schwächer? Dabei merkst du zweierlei. Es wird aushaltbar. Und es kommt und geht wie eine Welle. Stell dir beim ersten Mal einen Timer auf 5 Minuten. Danach darfst du tun, was du willst. Jedes weitere Mal ein bisschen länger, bis etwa 30 Minuten. Spätestens dann ist der Drang meist verschwunden.',
    evidence: 'In einer randomisierten Studie mit Rauchern rauchten diejenigen, die Urge Surfing gelernt hatten, deutlich weniger als die Gruppe, die es nur mit Willenskraft versuchte (Bowen & Marlatt, 2009).',
    critique: 'Das ist Training, kein Zaubertrick. Die ersten Male fühlen sich holprig an. Und Vorsicht: Hinspüren heißt nicht ausmalen. Sobald du dir Geschmack, Geruch oder den ersten Klick vorstellst, fütterst du das Verlangen (siehe Technik 08).',
    prompts: [
      'Wo genau in deinem Körper spürst du das Verlangen gerade?',
      'Ist es eher Druck, Ziehen, Kribbeln, Hitze oder Unruhe?',
      'Auf einer Skala von 0 bis 10: Wie hoch ist die Welle gerade?',
      'Was passiert, wenn du die Welle einfach da sein lässt, ohne etwas zu tun?',
      'Gab es je ein Verlangen, das nicht irgendwann von selbst nachgelassen hat?',
      'Wird die Welle gerade höher oder flacher? Schau genau hin.',
    ],
    tool: Tool.surf,
    toolLabel: 'Surf-Timer starten',
  ),
  Technique(
    nr: 2,
    title: 'Abstrakt machen',
    motto: 'Der Marshmallow ist nur eine weiße Wolke.',
    short: 'Den Glanz abziehen. Beschreib es so nüchtern wie in einem Laborbericht.',
    explain: 'Was vor dir liegt, zählt weniger als das, was in deinem Kopf passiert. Kinder, die sich die Marshmallows als weiße Wattewolken vorstellten, hielten viel länger durch. Kinder, die sich dagegen ein Foto von Marshmallows als echt vorstellen sollten, gaben deutlich schneller nach. Also wird aus dem warmen, cremigen Schokokuchen ein brauner Industriebrei aus Zucker und Fett. Und aus Instagram eine Glasscheibe mit bunten Pixeln.',
    evidence: 'Klassische Experimente zum Belohnungsaufschub von Walter Mischel und Kollegen aus den 1970er-Jahren: Wer an die nüchternen, wenig verlockenden Eigenschaften dachte, wartete deutlich länger.',
    critique: 'Abstrahieren heißt nicht, alles um jeden Preis schlechtzureden. Du ziehst nur den Glanz ab, den Werbung und Gewohnheit daraufgelegt haben. Wenn du anfängst, dich selbst dafür fertigzumachen, dass du es willst, bist du zu weit gegangen.',
    prompts: [
      'Beschreib, was du willst, so nüchtern wie in einem Laborbericht.',
      'Woraus besteht das eigentlich? Zucker, Fett, Pixel, Stoff?',
      'Wer verdient gerade daran, dass du das willst?',
      'Wie würde ein Außerirdischer beschreiben, was du gleich tun willst?',
      'Was bleibt übrig, wenn du das Versprechen weglässt, das es dir macht?',
    ],
    tool: Tool.reframe,
    toolLabel: 'Nüchterne Beschreibungen',
  ),
  Technique(
    nr: 3,
    title: 'Eklig machen',
    motto: 'Ekel schlägt Gier.',
    short: 'Feuer mit Feuer bekämpfen. Stell dir Kakerlaken darauf vor.',
    explain: 'Niemand will eine Suppe essen, in die er gerade selbst gespuckt hat. Dabei landet beim Essen ohnehin immer Speichel im Mund. Schon die bloße Vorstellung von etwas Ekligem verdirbt den Genuss. Ekel ist tief in uns verankert, weil er unsere Vorfahren vor verdorbenem Essen geschützt hat. Du setzt also einen Urtrieb gegen einen anderen: Ekel gegen Gier.',
    evidence: 'Die Ekelforschung (u. a. Paul Rozin) zeigt: Schon der Gedanke an Verunreinigung, etwa an ein Haar im Essen, verdirbt zuverlässig den Appetit.',
    critique: 'Ein Werkzeug für den Notfall, kein Dauerzustand. Wenn du zu Essstörungen neigst, lass diese Technik beim Thema Essen weg. Dein Verhältnis zum Essen soll gesund bleiben und nicht von Angst geprägt sein.',
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
    motto: 'Gibt Batman gerade alles?',
    short: 'Abstand zu dir selbst. Sprich von dir in der dritten Person.',
    explain: 'Kinder, die als Batman verkleidet waren und immer wieder gefragt wurden „Gibt Batman gerade alles?“, blieben am längsten an einer langweiligen Aufgabe dran. Je mehr Abstand zum eigenen Ich, desto mehr Selbstkontrolle. Für Erwachsene gibt es zwei Wege. Sprich von dir in der dritten Person: „Okay {name}, was ist jetzt der klügste Zug?“ Oder stell dir vor, ein guter Freund steht vor genau dieser Entscheidung. Bei anderen sehen wir sofort klar, bei uns selbst stehen wir uns oft im Weg.',
    evidence: 'Der „Batman-Effekt“ (White, Carlson u. a., 2017) und Salomons Paradox (Grossmann & Kross, 2014): Bei fremden Problemen urteilen wir weiser als bei unseren eigenen.',
    critique: 'Das fühlt sich anfangs albern an. Genau darum wirkt es: Der Abstand nimmt der Situation die Dringlichkeit. Wenn du dich dabei aber nur von außen beschimpfst, verfehlst du das Ziel. Sprich mit dir wie ein guter Trainer.',
    prompts: [
      'Okay {name}, was ist jetzt der klügste Zug?',
      'Gibt {ego} gerade alles?',
      'Was würde {ego} jetzt tun?',
      'Ein guter Freund steht genau vor dieser Entscheidung. Was rätst du ihm?',
      '{name} in zwei Stunden: dankbar oder genervt?',
      'Stell dir vor, du beobachtest {name} gerade von außen. Was siehst du?',
    ],
    tool: Tool.distance,
    toolLabel: 'Name und Vorbild festlegen',
  ),
  Technique(
    nr: 5,
    title: 'Entscheidungs-Wippe',
    motto: 'Mach die Folgen spürbar.',
    short: 'Acht Felder: Nutzen und Kosten, kurz- und langfristig, für beide Optionen.',
    explain: 'Fitnessstudio oder Sofa? Zeichne eine Wippe. Jede Seite steht für eine Option. Für jede Option schreibst du auf: Nutzen kurzfristig, Nutzen langfristig, Kosten kurzfristig, Kosten langfristig. Dass das Sofa keine gute Idee ist, wusstest du schon vorher. Du hast die Folgen nur nicht gespürt. Das Aufschreiben zwingt dich, konkret zu werden, und macht die Konsequenzen jetzt schon fühlbar.',
    evidence: 'Keine einzelne Studie, sondern ein Prinzip: Wer die Folgen konkret und schriftlich durchdenkt, bezieht auch seine Gefühle ein. Genau das fehlt beim abstrakten „Ich weiß ja“.',
    critique: 'Neigt sich die Wippe trotzdem zur bequemen Seite, prüf ehrlich: Hast du die Kosten kleingeredet? Oder ist eine Pause gerade wirklich das Richtige? Beides ist möglich. Entscheidend ist, dass du bewusst entscheidest.',
    prompts: [
      'Was kostet dich die schwierigere Option wirklich? In Minuten, nicht in Gefühlen.',
      'Was kostet dich die bequeme Option, wenn du sie ein Jahr lang wählst?',
      'Wie fühlst du dich heute Abend, wenn du jetzt den leichten Weg nimmst?',
      'Welche Folge kennst du eigentlich längst, spürst sie aber gerade nicht?',
    ],
    tool: Tool.seesaw,
    toolLabel: 'Wippe ausfüllen',
  ),
  Technique(
    nr: 6,
    title: 'Rat der Ichs',
    motto: 'Jeder bekommt eine Stimme. Auch der Hamster.',
    short: 'Jetzt-Ich, Abend-Ich, Zukunfts-Ich und das 80-jährige Ich stimmen ab.',
    explain: 'In dir sitzt nicht eine Person, sondern ein ganzer Rat. Das Jetzt-Ich will es bequem haben. Das Abend-Ich muss mit den Folgen leben. Das Zukunfts-Ich profitiert davon oder zahlt den Preis. Das 80-jährige Ich auf dem Sterbebett sieht das große Ganze. Und der Hamster, dein kleiner Kumpel, will eigentlich nur Ruhe, Wärme oder einen Snack. Alle stimmen ab.',
    evidence: 'Forschung zur Verbundenheit mit dem zukünftigen Ich (Hal Hershfield): Wer sich seinem zukünftigen Ich nahe fühlt, entscheidet weitsichtiger, zum Beispiel beim Sparen.',
    critique: 'Auch das Jetzt-Ich hat eine berechtigte Stimme. Wenn es wirklich Erholung braucht, ist das kein Verrat. Problematisch wird es nur, wenn es jedes Mal allein entscheidet.',
    prompts: [
      'Was sagt dein 80-jähriges Ich zu diesem Moment?',
      'Was würde dir dein Ich von heute Abend jetzt raten?',
      'Was braucht der Hamster wirklich? Ruhe, Wärme, Zucker oder Bestätigung?',
      'Wer im Rat schreit gerade am lautesten? Und hat er recht?',
      'Wofür wird dir dein Zukunfts-Ich in einem Jahr dankbar sein?',
    ],
    tool: Tool.council,
    toolLabel: 'Rat einberufen',
  ),
  Technique(
    nr: 7,
    title: 'Dein Warum',
    motto: 'Wer ein Warum hat, erträgt fast jedes Wie.',
    short: 'Ein Brief an dich selbst. Lies ihn, wenn die Disziplin nachlässt.',
    explain: 'Du willst nicht abnehmen, weil schlank irgendwie besser ist. Du willst lange genug leben, um bei der Abschlussfeier deiner Enkelin dabei zu sein. Du arbeitest nicht für eine Zahl auf dem Konto, sondern für deine Freiheit. Schreib dein Warum als Brief an dich selbst, mit allen Einzelheiten. Was aufgeschrieben ist, wird real, und du kannst ihm nicht mehr ausweichen. Wenn die Disziplin nachlässt, lies den Brief. Dann schrumpft das Verlangen auf das, was es ist: eine kleine Unbequemlichkeit.',
    evidence: 'Der Satz stammt von Nietzsche und wurde durch Viktor Frankl bekannt: „Wer ein Warum zum Leben hat, erträgt fast jedes Wie.“ Die Klärung der eigenen Werte ist außerdem ein fester Bestandteil der Akzeptanz- und Commitment-Therapie (ACT).',
    critique: 'Ein Warum, das nur im Kopf existiert, verpufft. Ebenso eines, das gar nicht deins ist, sondern das von Instagram. Lies deinen Brief alle paar Monate kritisch: Stimmt das noch? Berührt es dich noch?',
    prompts: [
      'Für wen machst du das eigentlich?',
      'Wie sieht ein ganz konkreter Tag in deinem Leben aus, wenn du dranbleibst?',
      'Was ist der Preis, wenn du so weitermachst wie bisher?',
      'Ist dein Warum stark genug, um gegen dieses Verlangen zu gewinnen? Wenn nicht: Was fehlt?',
    ],
    tool: Tool.why,
    toolLabel: 'Brief öffnen',
  ),
  Technique(
    nr: 8,
    title: 'Notfall-Sprint',
    motto: 'Stopp es, bevor es wächst.',
    short: 'Drei Schritte: Auslöser weg, bewegen, Kopf beschäftigen.',
    explain: 'Die meisten Gedanken an etwas, das wir wollen, verschwinden von selbst. Die wenigen, die bleiben, wachsen durch zwei Dinge. Entweder spielst du Erinnerungen ab, oder du machst einen „Nur für den Fall“-Check: Nicht, dass ich es tun würde, aber habe ich eigentlich noch Zigaretten? Ist noch Schokolade da? Dabei malst du dir Geschmack, Geruch und den ersten Bissen aus, und das Verlangen wächst wie ein Schneeball. Genau dann hast du ein kurzes Zeitfenster für den Sprint. Erstens: Auslöser sofort weg, ohne nachzudenken. Zweitens: bewegen, schon 15 Minuten Gehen helfen. Drittens: den Kopf beschäftigen, zum Beispiel mit einem 3-Minuten-Spiel, das dein Arbeitsgedächtnis auslastet.',
    evidence: 'Elaborated-Intrusion-Theorie des Verlangens (Kavanagh, Andrade & May, 2005). Schon kurze Bewegung senkt das Verlangen nach Zigaretten und Schokolade messbar (u. a. Studien von Adrian Taylor). Bereits 3 Minuten Tetris verringerten das Verlangen nach Essen, Nikotin, Alkohol und mehr (Skorka-Brown u. a.).',
    critique: 'Der Sprint wirkt nur, wenn du schnell bist. Wer erst überlegt, ob er ihn machen sollte, steckt schon mitten im Ausmalen. Mach ihn zum Reflex.',
    prompts: [
      'Machst du gerade einen „Nur für den Fall“-Check? Hör sofort damit auf.',
      'Spielst du gerade den ersten Bissen, Zug oder Klick im Kopf durch?',
      'Was kannst du in den nächsten 10 Sekunden tun, damit es unmöglich wird?',
      'Kannst du jetzt für 15 Minuten rausgehen?',
    ],
    tool: Tool.sprint,
    toolLabel: 'Sprint starten',
  ),
  Technique(
    nr: 9,
    title: 'Bessere Optionen',
    motto: 'Gib dem Verlangen Konkurrenz.',
    short: 'Die Alternative muss sofort verfügbar sein und darf nichts kosten.',
    explain: 'Ratten in einem kahlen Käfig wurden morphinabhängig. Ratten in einem großen Gehege mit Artgenossen tranken ein Vielfaches weniger. Selbst abhängige Ratten wählten fast immer den Hebel, der die Tür zu einem Artgenossen öffnete, statt den für die Droge. Allerdings nur, solange diese Alternative sofort und ohne Nachteil verfügbar war. Island hat den Alkoholkonsum seiner Jugendlichen drastisch gesenkt, indem es Sport, Musik und Theater für jede Familie bezahlbar gemacht hat. Wir greifen zum Handy, weil nichts Besseres griffbereit ist. Also schaff dir Alternativen. Und einen Buddy, den du jederzeit anrufen darfst.',
    evidence: 'Rat Park (Bruce Alexander, um 1980), Wahlexperimente mit sozialer Belohnung bei abhängigen Ratten (Venniro u. a., 2018) und das isländische Präventionsmodell „Youth in Iceland“.',
    critique: 'Rat Park ließ sich nicht immer sauber wiederholen, und Islands Erfolg hat viele Ursachen. Die Kernidee überzeugt trotzdem. Prüf deine Alternativen kritisch: Sind sie wirklich sofort da? Kosten sie wirklich nichts? Sonst gewinnt das Handy.',
    prompts: [
      'Was wäre jetzt sofort und ohne Aufwand eine gute Alternative?',
      'Wen könntest du jetzt anrufen?',
      'Fehlen dir gerade Alternativen oder fehlt dir Energie?',
      'Was hast du heute schon gemacht, das dich wirklich erfüllt hat?',
      'Was liegt in Reichweite, das besser ist als das hier?',
    ],
    tool: Tool.alternatives,
    toolLabel: 'Alternativen und Buddy',
  ),
  Technique(
    nr: 10,
    title: 'Unsichtbar machen',
    motto: 'Gewinn nicht die Schlacht. Entfern das Schlachtfeld.',
    short: 'Auslöser-Check: vom Verlangen zurück zur Situation, die es auslöst.',
    explain: 'Die diszipliniertesten Menschen brauchen ihre Disziplin am seltensten. Sie richten ihr Leben so ein, dass Versuchungen gar nicht erst auftauchen. Dabei hilft der Auslöser-Check aus der Rückfallprävention. Du fragst dich: Was will ich wirklich? Was habe ich gerade gefühlt? Welcher Gedanke kam davor? Welche Situation hat diesen Gedanken ausgelöst? Dann änderst du die Situation. Beispiel: Jeden Abend um 22 Uhr scrollst du dich durch Instagram. Ursache: Du fällst nach der Arbeit aufs Sofa, das Handy liegt direkt neben dir. Lösung: Um 21:30 Uhr kommt das Handy ans Ladegerät im Flur, und auf dem Sofa liegt ein gutes Buch.',
    evidence: 'Situative Strategien gelten als die wirksamste Form der Selbstkontrolle (Duckworth u. a., 2016). Das Erkennen von Auslösern gehört zum Standard der Rückfallprävention.',
    critique: 'Die stärkste und zugleich langweiligste Technik. Sie hilft dir nicht in diesem Moment, sondern ab morgen. Mach den Check trotzdem, am besten direkt nachdem du nachgegeben hast. Dann ist die Erinnerung noch frisch.',
    prompts: [
      'Was willst du gerade wirklich? Nicht das Ding selbst, sondern das Gefühl dahinter.',
      'Was hast du direkt vor dem Verlangen gefühlt?',
      'Welcher Gedanke kam unmittelbar davor? „Das hab ich mir verdient“?',
      'Welche Situation führt immer wieder zu diesem Moment?',
      'Wie könntest du das Schlachtfeld entfernen, statt die Schlacht zu gewinnen?',
    ],
    tool: Tool.audit,
    toolLabel: 'Auslöser-Check starten',
  ),
];

Technique techniqueByNr(int nr) => techniques.firstWhere((t) => t.nr == nr);
