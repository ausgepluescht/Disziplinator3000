import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../data/feelings.dart';
import '../data/impulses.dart';
import '../data/techniques.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/swipe_deck.dart';
import '../widgets/ui.dart';
import 'alternatives.dart';
import 'audit.dart';
import 'craving_editor.dart';
import 'sprint.dart';
import 'surf.dart';
import 'why.dart';

/// Akut-Modus: 1. Benennen  2. Gefühl und Gedanken  3. Auslöser weg  4. Welle brechen  5. Bilanz
class SosScreen extends StatefulWidget {
  final String? craving;
  const SosScreen({super.key, this.craving});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  int _step = 0;
  String? _craving;
  int? _before;
  int? _after;
  final Set<String> _used = {};
  final Set<int> _removed = {};
  final Set<String> _feelings = {};
  final _feelingNote = TextEditingController();
  final _thought = TextEditingController();

  @override
  void dispose() {
    _feelingNote.dispose();
    _thought.dispose();
    super.dispose();
  }

  /// Werkzeuge, die zu den gewählten Gefühlen passen, in der Reihenfolge der Nennung.
  List<SosTool> get _recommended {
    final out = <SosTool>[];
    for (final id in _feelings) {
      for (final t in feelingById(id)?.tools ?? const <SosTool>[]) {
        if (!out.contains(t)) out.add(t);
      }
    }
    return out;
  }

  @override
  void initState() {
    super.initState();
    _craving = widget.craving;
  }

  void _next() {
    HapticFeedback.lightImpact();
    setState(() => _step++);
  }

  Future<void> _editCustom(Craving? existing) async {
    final id = await editCraving(context, existing: existing);
    if (!mounted) return;
    setState(() {
      if (id != null) {
        _craving = id;
      } else if (_craving != null && cravings.every((c) => c.id != _craving)) {
        _craving = null;
      }
    });
  }

  Future<void> _use(String key, Future<Object?> Function() open) async {
    await open();
    if (mounted) setState(() => _used.add(key));
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
    const titles = ['Benennen', 'Gefühl', 'Auslöser weg', 'Welle brechen', 'Bilanz'];
    return Scaffold(
      appBar: AppBar(
        title: Text('AKUT · ${_step + 1}/${titles.length} · ${titles[_step].toUpperCase()}'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
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

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return _stepWhat(context);
      case 1:
        return _stepFeel(context);
      case 2:
        return _stepRemove(context);
      case 3:
        return _stepBreak(context);
      default:
        return _stepOutcome(context);
    }
  }

  // Schritt 1 ---------------------------------------------------------------
  Widget _stepWhat(BuildContext context) {
    final p = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Was lockt dich gerade?', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text('Wer es benennt, gewinnt schon etwas Abstand.', style: T.quote(p.muted, size: 17)),
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
                onTap: () => setState(() => _craving = c.id),
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
        const SizedBox(height: 26),
        Text('Wie stark ist es gerade?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 12),
        ScaleRow(value: _before, onChanged: (v) => setState(() => _before = v)),
        const SizedBox(height: 28),
        PrimaryButton('Weiter', icon: Icons.arrow_forward_rounded, onPressed: _craving == null ? null : _next),
      ],
    );
  }

  // Schritt 2 ---------------------------------------------------------------
  Widget _stepFeel(BuildContext context) {
    final p = context.c;
    final c = cravingById(_craving);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Label(c.label),
        const SizedBox(height: 10),
        Text('Was ist gerade los in dir?', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text(
          'Hinter jedem Verlangen steckt ein Gefühl. Wer es benennt, hat es nicht mehr im Nacken, sondern vor sich.',
          style: T.quote(p.muted, size: 17),
        ),
        const SizedBox(height: 22),
        Text('Wie fühlst du dich?', style: T.quote(p.fg, size: 18)),
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
        const SizedBox(height: 14),
        TextField(
          controller: _feelingNote,
          minLines: 1,
          maxLines: null,
          style: T.body(p.fg),
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Oder in eigenen Worten …'),
        ),
        const SizedBox(height: 26),
        Text('Was geht dir gerade durch den Kopf?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 6),
        Text('Schreib den Gedanken so auf, wie er in dir klingt. Ungefiltert.', style: T.small(p.muted)),
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
        PrimaryButton('Weiter', icon: Icons.arrow_forward_rounded, onPressed: _next),
        const SizedBox(height: 10),
        Center(child: Text('Du kannst das auch überspringen.', style: T.small(p.muted))),
      ],
    );
  }

  // Schritt 3 ---------------------------------------------------------------
  Widget _stepRemove(BuildContext context) {
    final p = context.c;
    final c = cravingById(_craving);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Label('08 · Notfall-Sprint · Schritt 1'),
        const SizedBox(height: 10),
        Text('Auslöser weg. Jetzt.', style: T.display(p.fg)),
        const SizedBox(height: 10),
        Text('Nicht nachdenken, nicht verhandeln. Erst handeln, dann weiterlesen.', style: T.quote(p.muted, size: 18)),
        const SizedBox(height: 22),
        for (var i = 0; i < c.removeTrigger.length; i++) ...[
          Tile(
            inverted: _removed.contains(i),
            onTap: () => setState(() => _removed.contains(i) ? _removed.remove(i) : _removed.add(i)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _removed.contains(i) ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                  color: _removed.contains(i) ? p.inverseFg : p.fg,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    c.removeTrigger[i],
                    style: T.body(_removed.contains(i) ? p.inverseFg : p.fg).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 18),
        PrimaryButton(
          _removed.isEmpty ? 'Geht gerade nicht. Weiter' : 'Erledigt. Weiter',
          icon: Icons.arrow_forward_rounded,
          onPressed: () {
            if (_removed.isNotEmpty) _used.add('Auslöser entfernt');
            _next();
          },
        ),
      ],
    );
  }

  // Schritt 4 ---------------------------------------------------------------
  Widget _stepBreak(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final c = cravingById(_craving);
    final alts = [...s.alternatives, ...c.alternatives];
    final thought = _thought.text.trim();
    final rec = _recommended;
    final labels = feelingLabels(_feelings);

    final tiles = <SosTool, Widget>{
      SosTool.surf: _ToolTile(
        nr: '01',
        title: 'Surfen',
        sub: 'Timer, ${s.surfSeconds ~/ 60} Min.',
        done: _used.contains('Urge Surfing'),
        recommended: rec.contains(SosTool.surf),
        onTap: () => _use('Urge Surfing', () => go(context, const SurfScreen())),
      ),
      SosTool.move: _ToolTile(
        nr: '08',
        title: 'Bewegen',
        sub: '2 bis 15 Min.',
        done: _used.contains('Bewegung'),
        recommended: rec.contains(SosTool.move),
        onTap: () => _use('Bewegung', () => go(context, const MoveScreen())),
      ),
      SosTool.game: _ToolTile(
        nr: '08',
        title: 'Ablenken',
        sub: 'Merkspiel, 3 Min.',
        done: _used.contains('Merkspiel'),
        recommended: rec.contains(SosTool.game),
        onTap: () => _use('Merkspiel', () => go(context, const PatternGameScreen())),
      ),
      SosTool.why: _ToolTile(
        nr: '07',
        title: 'Dein Warum',
        sub: s.why.trim().isEmpty ? 'Noch leer' : 'Brief lesen',
        done: _used.contains('Warum gelesen'),
        recommended: rec.contains(SosTool.why),
        onTap: () => _use('Warum gelesen', () => go(context, const WhyScreen(readFirst: true))),
      ),
      SosTool.alt: _ToolTile(
        nr: '09',
        title: 'Alternative',
        sub: 'Zufällig ziehen',
        done: _used.contains('Alternative'),
        recommended: rec.contains(SosTool.alt),
        onTap: () => _use('Alternative', () => showAlternative(context, alts[Random().nextInt(alts.length)])),
      ),
      SosTool.buddy: _ToolTile(
        nr: '09',
        title: s.buddyName.isEmpty ? 'Buddy' : s.buddyName,
        sub: s.buddyPhone.isEmpty ? 'Fehlt noch' : 'Anrufen',
        done: _used.contains('Buddy'),
        recommended: rec.contains(SosTool.buddy),
        onTap: () => _use('Buddy', () async {
          if (s.buddyPhone.isEmpty) {
            await go(context, const AlternativesScreen());
          } else {
            await callBuddy(context, s.buddyPhone);
          }
          return null;
        }),
      ),
    };
    // Empfohlene Werkzeuge zuerst, der Rest in gewohnter Reihenfolge.
    final order = [...rec.where(tiles.containsKey), ...tiles.keys.where((k) => !rec.contains(k))];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      children: [
        Text('Die Welle brechen.', style: T.h1(p.fg)),
        const SizedBox(height: 6),
        Text(
          labels.isEmpty
              ? 'Wisch dich durch die Fragen oder nimm eines der Werkzeuge darunter.'
              : 'Die ersten Karten gehen auf dein Gefühl ein. Werkzeuge, die dazu passen, stehen vorne.',
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
                Text(
                  'Ist das wahr? Oder ist das die Stimme des Verlangens, die gerade Argumente sammelt?',
                  style: T.small(p.muted),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        SwipeDeck(
          builder: () => buildDeck(s, craving: _craving, feelings: _feelings.toList()),
          height: 270,
        ),
        const SectionHeader('Werkzeuge'),
        if (labels.isNotEmpty) ...[
          Text('Markiert: Was zu „${labels.join('“, „')}“ passt.', style: T.small(p.muted)),
          const SizedBox(height: 12),
        ],
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.55,
          children: [for (final k in order) tiles[k]!],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GhostButton(
                'Wippe',
                icon: rec.contains(SosTool.seesaw) ? Icons.star_rounded : Icons.balance_rounded,
                onPressed: () {
                  _use('Entscheidungs-Wippe', () => openTool(context, techniqueByNr(5)));
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GhostButton(
                'Rat der Ichs',
                icon: rec.contains(SosTool.council) ? Icons.star_rounded : Icons.groups_2_outlined,
                onPressed: () {
                  _use('Rat der Ichs', () => openTool(context, techniqueByNr(6)));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        PrimaryButton('Die Welle ist vorbei', icon: Icons.arrow_forward_rounded, onPressed: _next),
      ],
    );
  }

  // Schritt 5 ---------------------------------------------------------------
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
                : 'Nicht schwächer geworden? Dann geh in eine zweite Runde: surfen oder bewegen.',
            style: T.small(p.fg),
          ),
        ],
        const SizedBox(height: 30),
        PrimaryButton('Widerstanden', icon: Icons.check_rounded, onPressed: () => _finish(true)),
        const SizedBox(height: 10),
        GhostButton('Nachgegeben', onPressed: () => _finish(false)),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _step = 3),
          child: Text('Doch noch nicht vorbei? Zurück zu den Werkzeugen', style: T.small(p.muted)),
        ),
      ],
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

class _ToolTile extends StatelessWidget {
  final String nr;
  final String title;
  final String sub;
  final bool done;
  final bool recommended;
  final VoidCallback onTap;
  const _ToolTile({
    required this.nr,
    required this.title,
    required this.sub,
    required this.done,
    required this.onTap,
    this.recommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: recommended ? p.fg : p.line, width: recommended ? 1.5 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(nr, style: T.num(p.muted, size: 12)),
                  if (recommended) ...[
                    const SizedBox(width: 8),
                    Expanded(child: Label('Passt', color: p.fg)),
                  ] else
                    const Spacer(),
                  Icon(done ? Icons.check_circle_rounded : Icons.north_east_rounded, size: 18, color: p.fg),
                ],
              ),
              const Spacer(),
              Text(title, style: T.h2(p.fg).copyWith(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(sub, style: T.small(p.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
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
