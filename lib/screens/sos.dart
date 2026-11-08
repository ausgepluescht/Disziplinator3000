import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../data/feelings.dart';
import '../data/techniques.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'alternatives.dart';
import 'audit.dart';
import 'craving_editor.dart';

/// Akut-Modus in vier Schritten:
/// 1. Benennen (antippen geht direkt weiter)
/// 2. Einordnen: Stärke, Gefühl, Gedanken
/// 3. Technik wählen und damit arbeiten
/// 4. Bilanz
class SosScreen extends StatefulWidget {
  final String? craving;
  const SosScreen({super.key, this.craving});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

/// Technik, die im Akutfall angeboten wird. Die Reihenfolge ist die Standardreihenfolge.
const _akutTechniques = [8, 1, 2, 3, 9, 7, 4, 5, 6];

/// Welche Technik ein Werkzeug aus `feelings.dart` meint.
int _techOf(SosTool t) => switch (t) {
  SosTool.surf => 1,
  SosTool.move || SosTool.game => 8,
  SosTool.why => 7,
  SosTool.alt || SosTool.buddy => 9,
  SosTool.seesaw => 5,
  SosTool.council => 6,
};

class _SosScreenState extends State<SosScreen> {
  late int _step = widget.craving == null ? 0 : 1;
  late String? _craving = widget.craving;
  int? _before;
  int? _after;
  final Set<String> _used = {};
  final Set<String> _feelings = {};
  final _feelingNote = TextEditingController();
  final _thought = TextEditingController();

  @override
  void dispose() {
    _feelingNote.dispose();
    _thought.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    HapticFeedback.lightImpact();
    setState(() => _step = step);
  }

  /// Techniken, die zu den gewählten Gefühlen passen, nach Häufigkeit der Nennung.
  List<int> get _recommended {
    final score = <int, int>{};
    for (final id in _feelings) {
      for (final t in feelingById(id)?.tools ?? const <SosTool>[]) {
        final nr = _techOf(t);
        score[nr] = (score[nr] ?? 0) + 1;
      }
    }
    final list = score.keys.toList()..sort((a, b) => score[b]!.compareTo(score[a]!));
    return list;
  }

  /// Welche Gefühle für diese Technik sprechen.
  List<String> _reasonFor(int nr) => [
    for (final id in _feelings)
      if ((feelingById(id)?.tools ?? const <SosTool>[]).any((t) => _techOf(t) == nr)) feelingById(id)!.label,
  ];

  Future<void> _pickCraving(String id) async {
    HapticFeedback.selectionClick();
    setState(() => _craving = id);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (mounted) _goTo(1);
  }

  Future<void> _editCustom(Craving? existing) async {
    final id = await editCraving(context, existing: existing);
    if (!mounted) return;
    if (id != null) {
      _pickCraving(id);
    } else if (_craving != null && cravings.every((c) => c.id != _craving)) {
      setState(() => _craving = null);
    }
  }

  Future<void> _useTechnique(Technique t) async {
    if (t.nr == 9) {
      await _showOptions();
    } else {
      await openTool(context, t, craving: _craving);
    }
    if (mounted) setState(() => _used.add(t.title));
  }

  /// Technik 09 im Akutfall: eine Alternative ziehen oder den Buddy anrufen.
  Future<void> _showOptions() {
    final s = context.readStore;
    final c = cravingById(_craving);
    final pool = [...s.alternatives, ...c.alternatives];
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _OptionsSheet(pool: pool, buddyName: s.buddyName, buddyPhone: s.buddyPhone),
    );
  }

  void _finish(bool resisted) {
    final s = context.readStore;
    s.addLog(
      LogEntry(
        at: DateTime.now(),
        craving: _craving ?? 'sonst',
        before: _before ?? 5,
        after: _after,
        outcome: resisted ? 'resisted' : 'gave_in',
        used: _used.toList(),
        feelings: _feelings.toList(),
        feelingNote: _feelingNote.text.trim(),
        thought: _thought.text.trim(),
      ),
    );
    HapticFeedback.heavyImpact();
    final nav = Navigator.of(context);
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OutcomeSheet(resisted: resisted),
    ).then((r) {
      if (!mounted) return;
      nav.pop();
      if (r == 'audit') {
        final labels = feelingLabels(_feelings);
        final note = _feelingNote.text.trim();
        final feeling = [...labels, if (note.isNotEmpty) note].join(', ');
        nav.push(
          MaterialPageRoute(
            builder: (_) => AuditScreen(
              craving: _craving,
              feeling: feeling.isEmpty ? null : feeling,
              thought: _thought.text.trim().isEmpty ? null : _thought.text.trim(),
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    const titles = ['Benennen', 'Einordnen', 'Technik', 'Bilanz'];
    return Scaffold(
      appBar: AppBar(
        title: Text('AKUT · ${_step + 1}/${titles.length} · ${titles[_step].toUpperCase()}'),
        leading: IconButton(
          icon: Icon(
            _step == 0 || (_step == 1 && widget.craving != null) ? Icons.close_rounded : Icons.arrow_back_rounded,
          ),
          onPressed: () {
            if (_step == 0 || (_step == 1 && widget.craving != null)) {
              Navigator.of(context).pop();
            } else {
              _goTo(_step - 1);
            }
          },
        ),
        actions: [
          if (_step > 0)
            IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(
                titles.length,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _step ? p.fg : p.line,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, a) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween(begin: const Offset(0.06, 0), end: Offset.zero).animate(a),
                  child: child,
                ),
              ),
              child: KeyedSubtree(key: ValueKey(_step), child: _buildStep(context)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context) => switch (_step) {
    0 => _stepWhat(context),
    1 => _stepRate(context),
    2 => _stepTechnique(context),
    _ => _stepOutcome(context),
  };

  // Schritt 1: Benennen -----------------------------------------------------
  Widget _stepWhat(BuildContext context) {
    final p = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Was lockt dich gerade?', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text('Antippen, und es geht direkt weiter.', style: T.quote(p.muted, size: 17)),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.3,
          children: [
            for (final c in cravings)
              _ChoiceTile(
                icon: c.icon,
                text: c.label,
                selected: _craving == c.id,
                onTap: () => _pickCraving(c.id),
                onLongPress: c.custom ? () => _editCustom(c) : null,
              ),
            _ChoiceTile(
              icon: Icons.add_rounded,
              text: 'Eigenes hinzufügen',
              selected: false,
              outlined: true,
              onTap: () => _editCustom(null),
            ),
          ],
        ),
        if (customCravings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Eigene Kategorien: lange drücken zum Bearbeiten.', style: T.small(p.muted)),
        ],
      ],
    );
  }

  // Schritt 2: Einordnen ----------------------------------------------------
  Widget _stepRate(BuildContext context) {
    final p = context.c;
    final c = cravingById(_craving);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Row(
          children: [
            Icon(c.icon, size: 16, color: p.muted),
            const SizedBox(width: 8),
            Label(c.label),
          ],
        ),
        const SizedBox(height: 10),
        Text('Wie stark ist es gerade?', style: T.h1(p.fg)),
        const SizedBox(height: 14),
        ScaleRow(value: _before, onChanged: (v) => setState(() => _before = v)),
        const SizedBox(height: 28),
        Text('Was fühlst du?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in feelings)
              Pill(
                f.label,
                selected: _feelings.contains(f.id),
                onTap: () => setState(() => _feelings.contains(f.id) ? _feelings.remove(f.id) : _feelings.add(f.id)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _feelingNote,
          minLines: 1,
          maxLines: null,
          style: T.body(p.fg),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Oder in eigenen Worten …'),
        ),
        const SizedBox(height: 24),
        Text('Was geht dir durch den Kopf?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 6),
        Text('So aufschreiben, wie es in dir klingt. Landet im Protokoll.', style: T.small(p.muted)),
        const SizedBox(height: 10),
        TextField(
          controller: _thought,
          minLines: 3,
          maxLines: null,
          style: T.body(p.fg),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: '„Nur kurz, ich hab heute genug geschafft …“'),
        ),
        const SizedBox(height: 28),
        PrimaryButton('Weiter zu den Techniken', icon: Icons.arrow_forward_rounded, onPressed: () => _goTo(2)),
        const SizedBox(height: 10),
        Center(child: Text('Alles hier ist freiwillig.', style: T.small(p.muted))),
      ],
    );
  }

  // Schritt 3: Technik wählen -----------------------------------------------
  Widget _stepTechnique(BuildContext context) {
    final p = context.c;
    final thought = _thought.text.trim();
    final rec = _recommended;
    final order = [...rec, ..._akutTechniques.where((n) => !rec.contains(n))];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Womit gehst du es an?', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text(
          rec.isEmpty ? 'Such dir eine Technik aus und bleib bei ihr, bis die Welle flacher wird.' : 'Oben steht, was zu deinem Gefühl passt. Such dir eine Technik aus und bleib bei ihr, bis die Welle flacher wird.',
          style: T.quote(p.muted, size: 17),
        ),
        if (thought.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: p.fg, width: 3)),
              color: p.faint,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label('Dein Gedanke'),
                const SizedBox(height: 8),
                Text('„$thought“', style: T.quote(p.fg, size: 17)),
                const SizedBox(height: 10),
                Text('Ist das wahr? Oder sammelt das Verlangen gerade Argumente?', style: T.small(p.muted)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        for (final nr in order) ...[
          _TechniqueCard(
            t: techniqueByNr(nr),
            reasons: _reasonFor(nr),
            done: _used.contains(techniqueByNr(nr).title),
            onTap: () => _useTechnique(techniqueByNr(nr)),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 16),
        PrimaryButton('Die Welle ist vorbei', icon: Icons.arrow_forward_rounded, onPressed: () => _goTo(3)),
      ],
    );
  }

  // Schritt 4: Bilanz -------------------------------------------------------
  Widget _stepOutcome(BuildContext context) {
    final p = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Wie ist es ausgegangen?', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text('Sei ehrlich. Hier gibt es keine Strafe, nur Erkenntnisse.', style: T.quote(p.muted, size: 17)),
        const SizedBox(height: 24),
        Text('Wie stark ist das Verlangen jetzt?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 12),
        ScaleRow(value: _after, onChanged: (v) => setState(() => _after = v)),
        if (_before != null && _after != null) ...[
          const SizedBox(height: 14),
          Text(
            _after! < _before!
                ? 'Von $_before auf $_after: Die Welle ist um ${_before! - _after!} ${_before! - _after! == 1 ? 'Punkt' : 'Punkte'} gesunken.'
                : 'Nicht schwächer geworden? Dann probier noch eine zweite Technik.',
            style: T.small(p.fg),
          ),
        ],
        if (_used.isNotEmpty) ...[
          const SizedBox(height: 18),
          Label('Genutzt'),
          const SizedBox(height: 6),
          Text(_used.join(' · '), style: T.body(p.fg)),
        ],
        const SizedBox(height: 30),
        PrimaryButton('Widerstanden', icon: Icons.check_rounded, onPressed: () => _finish(true)),
        const SizedBox(height: 10),
        GhostButton('Nachgegeben', onPressed: () => _finish(false)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => _goTo(2),
          child: Text('Doch noch nicht vorbei? Zurück zu den Techniken', style: T.small(p.muted)),
        ),
      ],
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final Technique t;
  final List<String> reasons;
  final bool done;
  final VoidCallback onTap;
  const _TechniqueCard({required this.t, required this.reasons, required this.done, required this.onTap});

  /// Was die Technik im Akutfall konkret tut.
  String get _action => switch (t.nr) {
    1 => 'Timer stellen und die Welle im Körper beobachten, bis sie bricht.',
    2 => 'Das Ding nüchtern sehen: Material, Funktion, wer daran verdient.',
    3 => 'Ein Bild, das dir die Lust verdirbt. Wirkt in Sekunden.',
    4 => 'Von außen auf dich schauen, wie auf einen guten Freund.',
    5 => 'Nutzen und Kosten aufschreiben, bis die Wippe kippt.',
    6 => 'Jetzt-Ich, Abend-Ich, Zukunfts-Ich: Alle stimmen ab.',
    7 => 'Deinen Brief lesen. Erinnern, wofür du das machst.',
    8 => 'Auslöser weg, 15 Minuten bewegen, Kopf beschäftigen.',
    9 => 'Alternative ziehen oder den Buddy anrufen.',
    _ => t.short,
  };

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final rec = reasons.isNotEmpty;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: rec ? p.fg : p.line, width: rec ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.nrLabel, style: T.num(p.fg, size: 18)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, style: T.h2(p.fg).copyWith(fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(_action, style: T.small(p.muted)),
                    if (rec) ...[const SizedBox(height: 8), Label('Passt zu ${reasons.join(', ')}', color: p.fg)],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(done ? Icons.check_circle_rounded : Icons.arrow_forward_rounded, size: 20, color: p.fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final bool outlined;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const _ChoiceTile({
    required this.icon,
    required this.text,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final fg = selected ? p.inverseFg : p.fg;
    return Tile(
      inverted: selected,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: 14,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        children: [
          Icon(icon, color: outlined ? p.muted : fg, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: T.small(outlined ? p.muted : fg).copyWith(fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Technik 09 im Akutfall.
class _OptionsSheet extends StatefulWidget {
  final List<String> pool;
  final String buddyName;
  final String buddyPhone;
  const _OptionsSheet({required this.pool, required this.buddyName, required this.buddyPhone});

  @override
  State<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends State<_OptionsSheet> {
  final _rnd = Random();
  late String _current = widget.pool[_rnd.nextInt(widget.pool.length)];

  void _draw() {
    if (widget.pool.length < 2) return;
    HapticFeedback.selectionClick();
    String next;
    do {
      next = widget.pool[_rnd.nextInt(widget.pool.length)];
    } while (next == _current);
    setState(() => _current = next);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final hasBuddy = widget.buddyPhone.isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label('09 · Deine bessere Option'),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(_current, key: ValueKey(_current), style: T.h1(p.fg)),
            ),
            const SizedBox(height: 10),
            Text(
              'Sofort, ohne Verhandlung. Die Alternative gewinnt nur, wenn sie schneller ist.',
              style: T.quote(p.muted, size: 17),
            ),
            const SizedBox(height: 24),
            PrimaryButton('Mach ich', icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop()),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GhostButton('Andere ziehen', icon: Icons.casino_outlined, onPressed: _draw),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostButton(
                    hasBuddy ? widget.buddyName.split(' ').first : 'Buddy',
                    icon: Icons.call_outlined,
                    onPressed: () async {
                      if (hasBuddy) {
                        await callBuddy(context, widget.buddyPhone);
                      } else {
                        await go(context, const AlternativesScreen());
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeSheet extends StatelessWidget {
  final bool resisted;
  const _OutcomeSheet({required this.resisted});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Label(resisted ? 'Gewonnen' : 'Kein Drama'),
            const SizedBox(height: 10),
            Text(
              resisted
                  ? 'Stark. Das war Sieg Nummer ${s.resistedCount}.'
                  : 'Kann passieren. Jetzt zählt, was du daraus lernst.',
              style: T.h1(p.fg),
            ),
            const SizedBox(height: 12),
            Text(
              resisted
                  ? 'Jedes Mal, wenn du eine Welle aussitzt, lernt dein Gehirn, dass das Verlangen auch vergeht, ohne dass du nachgibst. Beim nächsten Mal wird es leichter.'
                  : 'Ein Ausrutscher ist noch kein Rückfall. Er zeigt dir, wo du nachbessern kannst. Der beste Zeitpunkt für einen Auslöser-Check ist jetzt, solange die Erinnerung frisch ist.',
              style: T.quote(p.muted, size: 17),
            ),
            const SizedBox(height: 24),
            if (!resisted) ...[
              PrimaryButton(
                'Auslöser-Check starten',
                icon: Icons.search_rounded,
                onPressed: () => Navigator.of(context).pop('audit'),
              ),
              const SizedBox(height: 10),
            ],
            GhostButton('Schließen', onPressed: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
