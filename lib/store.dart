import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ein Moment, in dem es dich gezogen hat.
class LogEntry {
  final DateTime at;
  final String craving;
  final int before;
  final int? after;

  /// 'resisted' oder 'gave_in'
  final String outcome;
  final List<String> used;
  final String note;

  LogEntry({
    required this.at,
    required this.craving,
    required this.before,
    this.after,
    required this.outcome,
    this.used = const [],
    this.note = '',
  });

  bool get resisted => outcome == 'resisted';

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'craving': craving,
    'before': before,
    'after': after,
    'outcome': outcome,
    'used': used,
    'note': note,
  };

  factory LogEntry.fromJson(Map<String, dynamic> j) => LogEntry(
    at: DateTime.parse(j['at'] as String),
    craving: j['craving'] as String? ?? 'sonst',
    before: (j['before'] as num?)?.toInt() ?? 5,
    after: (j['after'] as num?)?.toInt(),
    outcome: j['outcome'] as String? ?? 'resisted',
    used: (j['used'] as List?)?.cast<String>() ?? const [],
    note: j['note'] as String? ?? '',
  );
}

/// Cue-Audit (Technik 10).
class Audit {
  final DateTime at;
  final String craving;
  final String want;
  final String feeling;
  final String thought;
  final String situation;
  final String fix;

  Audit({
    required this.at,
    required this.craving,
    required this.want,
    required this.feeling,
    required this.thought,
    required this.situation,
    required this.fix,
  });

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'craving': craving,
    'want': want,
    'feeling': feeling,
    'thought': thought,
    'situation': situation,
    'fix': fix,
  };

  factory Audit.fromJson(Map<String, dynamic> j) => Audit(
    at: DateTime.parse(j['at'] as String),
    craving: j['craving'] as String? ?? 'sonst',
    want: j['want'] as String? ?? '',
    feeling: j['feeling'] as String? ?? '',
    thought: j['thought'] as String? ?? '',
    situation: j['situation'] as String? ?? '',
    fix: j['fix'] as String? ?? '',
  );
}

/// Gespeicherte Entscheidung aus Wippe oder Rat.
class Decision {
  final DateTime at;

  /// 'seesaw' oder 'council'
  final String kind;
  final String question;
  final String verdict;
  final Map<String, dynamic> data;

  Decision({required this.at, required this.kind, required this.question, required this.verdict, required this.data});

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'kind': kind,
    'question': question,
    'verdict': verdict,
    'data': data,
  };

  factory Decision.fromJson(Map<String, dynamic> j) => Decision(
    at: DateTime.parse(j['at'] as String),
    kind: j['kind'] as String? ?? 'seesaw',
    question: j['question'] as String? ?? '',
    verdict: j['verdict'] as String? ?? '',
    data: (j['data'] as Map?)?.cast<String, dynamic>() ?? {},
  );
}

/// Alles bleibt lokal auf dem Gerät (SharedPreferences).
class Store extends ChangeNotifier {
  static const _key = 'disziplinator_v1';
  SharedPreferences? _prefs;

  String name = '';
  String alterEgo = 'Batman';
  String why = '';
  String buddyName = '';
  String buddyPhone = '';
  int surfSeconds = 5 * 60;
  bool dark = false;
  bool followSystem = true;
  List<String> alternatives = [];
  List<String> saved = [];
  List<LogEntry> logs = [];
  List<Audit> audits = [];
  List<Decision> decisions = [];

  String get displayName => name.trim().isEmpty ? 'Champion' : name.trim();

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_key);
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      name = j['name'] as String? ?? '';
      alterEgo = j['alterEgo'] as String? ?? 'Batman';
      why = j['why'] as String? ?? '';
      buddyName = j['buddyName'] as String? ?? '';
      buddyPhone = j['buddyPhone'] as String? ?? '';
      surfSeconds = (j['surfSeconds'] as num?)?.toInt() ?? 300;
      dark = j['dark'] as bool? ?? false;
      followSystem = j['followSystem'] as bool? ?? true;
      alternatives = (j['alternatives'] as List?)?.cast<String>() ?? [];
      saved = (j['saved'] as List?)?.cast<String>() ?? [];
      logs = ((j['logs'] as List?) ?? []).map((e) => LogEntry.fromJson((e as Map).cast())).toList();
      audits = ((j['audits'] as List?) ?? []).map((e) => Audit.fromJson((e as Map).cast())).toList();
      decisions = ((j['decisions'] as List?) ?? []).map((e) => Decision.fromJson((e as Map).cast())).toList();
    } catch (_) {
      // Defekte Daten nicht überschreiben, sondern beiseitelegen.
      await _prefs!.setString('${_key}_broken_${DateTime.now().millisecondsSinceEpoch}', raw);
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'alterEgo': alterEgo,
    'why': why,
    'buddyName': buddyName,
    'buddyPhone': buddyPhone,
    'surfSeconds': surfSeconds,
    'dark': dark,
    'followSystem': followSystem,
    'alternatives': alternatives,
    'saved': saved,
    'logs': logs.map((e) => e.toJson()).toList(),
    'audits': audits.map((e) => e.toJson()).toList(),
    'decisions': decisions.map((e) => e.toJson()).toList(),
  };

  Future<void> _save() async {
    notifyListeners();
    await _prefs?.setString(_key, jsonEncode(toJson()));
  }

  void update(void Function(Store s) fn) {
    fn(this);
    _save();
  }

  void addLog(LogEntry e) => update((s) => s.logs.insert(0, e));
  void addAudit(Audit a) => update((s) => s.audits.insert(0, a));
  void addDecision(Decision d) => update((s) => s.decisions.insert(0, d));

  bool isSaved(String text) => saved.contains(text);
  void toggleSaved(String text) =>
      update((s) => s.saved.contains(text) ? s.saved.remove(text) : s.saved.insert(0, text));

  /// Nach einer vollständigen Surf-Session wird die nächste etwas länger, bis 30 Minuten.
  void surfCompleted() => update((s) => s.surfSeconds = (s.surfSeconds + 60).clamp(60, 30 * 60));

  String fill(String text) => text.replaceAll('{name}', displayName).replaceAll('{ego}', alterEgo);

  // Auswertung ------------------------------------------------------------

  int get resistedCount => logs.where((l) => l.resisted).length;
  int get gaveInCount => logs.where((l) => !l.resisted).length;

  /// Tage in Folge (bis heute oder gestern) mit mindestens einem Sieg und ohne Nachgeben.
  int get streak {
    if (logs.isEmpty) return 0;
    final byDay = <DateTime, List<LogEntry>>{};
    for (final l in logs) {
      final d = DateTime(l.at.year, l.at.month, l.at.day);
      byDay.putIfAbsent(d, () => []).add(l);
    }
    final now = DateTime.now();
    var day = DateTime(now.year, now.month, now.day);
    if (!byDay.containsKey(day)) day = day.subtract(const Duration(days: 1));
    var n = 0;
    while (true) {
      final e = byDay[day];
      if (e == null || e.any((l) => !l.resisted)) break;
      n++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return n;
  }

  Future<void> wipe() async {
    name = '';
    alterEgo = 'Batman';
    why = '';
    buddyName = '';
    buddyPhone = '';
    surfSeconds = 300;
    alternatives = [];
    saved = [];
    logs = [];
    audits = [];
    decisions = [];
    await _save();
  }
}

/// Macht den Store im Widget-Baum verfügbar.
class StoreScope extends InheritedNotifier<Store> {
  const StoreScope({super.key, required Store store, required super.child}) : super(notifier: store);

  static Store of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
  static Store read(BuildContext context) => context.getInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}

extension StoreX on BuildContext {
  Store get store => StoreScope.of(this);
  Store get readStore => StoreScope.read(this);
}
