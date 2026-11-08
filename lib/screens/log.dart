import 'package:flutter/material.dart';

import '../data/cravings.dart';
import '../data/feelings.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';
import 'craving_editor.dart';

/// Protokoll mit Mustern: Wann, was, welches Gefühl, und was bei dir wirklich hilft.
class LogScreen extends StatefulWidget {
  /// Vorausgewählte Kategorie, zum Beispiel vom Startbildschirm.
  final String? craving;
  const LogScreen({super.key, this.craving});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  late String? _filter = widget.craving;

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final all = s.logs;
    final logs = _filter == null ? all : all.where((l) => l.craving == _filter).toList();
    final usedIds = all.map((l) => l.craving).toSet();
    final filterable = cravings.where((c) => usedIds.contains(c.id)).toList();
    final resisted = logs.where((l) => l.resisted).length;
    final gaveIn = logs.length - resisted;

    return Scaffold(
      appBar: AppBar(title: const Text('PROTOKOLL')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(title: 'Deine Muster.', motto: 'Kein Urteil. Nur Daten, aus denen du lernst.'),
          if (filterable.length > 1) ...[
            const SizedBox(height: 18),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Pill('Alle', selected: _filter == null, onTap: () => setState(() => _filter = null)),
                  ),
                  for (final c in filterable)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pill(
                        c.label,
                        icon: c.icon,
                        selected: _filter == c.id,
                        onTap: () => setState(() => _filter = _filter == c.id ? null : c.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              _Num(n: '$resisted', l: 'Widerstanden'),
              _Num(n: '$gaveIn', l: 'Nachgegeben'),
              _Num(n: logs.isEmpty ? '–' : '${(resisted * 100 / logs.length).round()}%', l: 'Erfolgsquote'),
            ],
          ),
          if (logs.length >= 3) ...[
            const SectionHeader('Erkenntnisse'),
            ..._insights(logs, filtered: _filter != null).map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Container(width: 6, height: 6, color: p.fg),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(t, style: T.quote(p.fg, size: 17))),
                  ],
                ),
              ),
            ),
          ],
          SectionHeader('Momente', trailing: Text('${logs.length}', style: T.num(p.muted, size: 12))),
          if (logs.isEmpty)
            Text('Noch nichts protokolliert. Jeder Durchlauf im Akut-Modus landet hier.', style: T.body(p.muted)),
          for (final l in logs) ...[_LogTile(entry: l), const SizedBox(height: 8)],
          if (_filter == null && s.decisions.isNotEmpty) ...[
            SectionHeader('Entscheidungen', trailing: Text('${s.decisions.length}', style: T.num(p.muted, size: 12))),
            for (final d in s.decisions) ...[
              Tile(
                onLongPress: () => _confirmDelete(context, () => s.update((s) => s.decisions.remove(d))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Label(d.kind == 'seesaw' ? '05 · Wippe' : '06 · Rat'),
                        const Spacer(),
                        Text(fmtDate(d.at), style: T.label(p.muted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(d.question, style: T.h2(p.fg).copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(d.verdict, style: T.quote(p.muted, size: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          if (logs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Antippen zum Nachlesen, lange drücken zum Löschen.', style: T.small(p.muted)),
          ],
        ],
      ),
    );
  }

  List<String> _insights(List<LogEntry> logs, {required bool filtered}) {
    final out = <String>[];

    if (!filtered) {
      final byCraving = <String, int>{};
      for (final l in logs) {
        byCraving[l.craving] = (byCraving[l.craving] ?? 0) + 1;
      }
      final top = byCraving.entries.reduce((a, b) => a.value >= b.value ? a : b);
      out.add('Am häufigsten lockt dich: ${cravingById(top.key).label} (${top.value} von ${logs.length} Momenten).');
    }

    final byFeeling = <String, int>{};
    for (final l in logs) {
      for (final f in l.feelings) {
        byFeeling[f] = (byFeeling[f] ?? 0) + 1;
      }
    }
    if (byFeeling.isNotEmpty) {
      final tf = byFeeling.entries.reduce((a, b) => a.value >= b.value ? a : b);
      final label = feelingById(tf.key)?.label.toLowerCase();
      if (label != null) {
        out.add(
          filtered
              ? 'Dahinter steckt meistens: $label (${tf.value} von ${logs.length} Momenten).'
              : 'Das häufigste Gefühl dahinter: $label (${tf.value} von ${logs.length} Momenten).',
        );
      }
    }

    final byBlock = <int, int>{};
    for (final l in logs) {
      final b = l.at.hour ~/ 2;
      byBlock[b] = (byBlock[b] ?? 0) + 1;
    }
    final tb = byBlock.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final from = (tb.key * 2).toString().padLeft(2, '0');
    final to = (tb.key * 2 + 2).toString().padLeft(2, '0');
    out.add('Kritischste Zeit: $from bis $to Uhr. Genau hier lohnt sich ein Auslöser-Check.');

    final drops = logs.where((l) => l.after != null).map((l) => l.before - l.after!).toList();
    if (drops.isNotEmpty) {
      final avg = drops.reduce((a, b) => a + b) / drops.length;
      out.add(
        avg > 0
            ? 'Mit den Werkzeugen sinkt die Welle im Schnitt um ${avg.toStringAsFixed(1).replaceAll('.', ',')} Punkte.'
            : 'Die Welle sinkt bei dir bisher kaum. Probier länger zu surfen oder dich mehr zu bewegen.',
      );
    }

    final helped = <String, int>{};
    for (final l in logs.where((l) => l.resisted)) {
      for (final u in l.used) {
        helped[u] = (helped[u] ?? 0) + 1;
      }
    }
    if (helped.isNotEmpty) {
      final h = helped.entries.reduce((a, b) => a.value >= b.value ? a : b);
      out.add('Am häufigsten dabei, wenn du widerstanden hast: ${h.key}.');
    }
    return out;
  }
}

Future<void> _confirmDelete(BuildContext context, VoidCallback onDelete) async {
  final p = context.c;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Eintrag löschen?', style: T.h2(p.fg)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
      ],
    ),
  );
  if (ok == true) onDelete();
}

class _Num extends StatelessWidget {
  final String n;
  final String l;
  const _Num({required this.n, required this.l});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n, style: T.num(p.fg, size: 32)),
          const SizedBox(height: 6),
          Label(l),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final LogEntry entry;
  const _LogTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final c = cravingById(entry.craving);
    final s = context.store;
    final feel = [...feelingLabels(entry.feelings), if (entry.feelingNote.isNotEmpty) entry.feelingNote];
    final hasDetail = feel.isNotEmpty || entry.thought.isNotEmpty;
    return Tile(
      inverted: false,
      padding: const EdgeInsets.all(14),
      onTap: () => _showEntry(context, entry),
      onLongPress: () => _confirmDelete(context, () => s.update((s) => s.logs.remove(entry))),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.resisted ? p.fg : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: p.fg, width: 1.4),
            ),
            child: Icon(
              entry.resisted ? Icons.check_rounded : Icons.remove_rounded,
              size: 20,
              color: entry.resisted ? p.inverseFg : p.fg,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.label, style: T.small(p.fg).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                if (feel.isNotEmpty)
                  Text(feel.join(', '), style: T.small(p.fg), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (entry.thought.isNotEmpty)
                  Text(
                    '„${entry.thought}“',
                    style: T.quote(p.muted, size: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!hasDetail)
                  Text(
                    entry.used.isEmpty ? (entry.resisted ? 'Widerstanden' : 'Nachgegeben') : entry.used.join(' · '),
                    style: T.small(p.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                entry.after == null ? '${entry.before}' : '${entry.before}→${entry.after}',
                style: T.num(p.fg, size: 14),
              ),
              const SizedBox(height: 4),
              Text(fmtDate(entry.at), style: T.label(p.muted).copyWith(fontSize: 9.5, letterSpacing: 0.4)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Ein Moment zum Nachlesen: Gefühl, Gedanke, Werkzeuge, Ausgang.
void _showEntry(BuildContext context, LogEntry e) {
  final c = cravingById(e.craving);
  final feel = [...feelingLabels(e.feelings), if (e.feelingNote.isNotEmpty) e.feelingNote];
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final p = ctx.c;
      Widget block(String label, Widget child) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Label(label), const SizedBox(height: 6), child],
        ),
      );
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(c.icon, size: 20, color: p.fg),
                  const SizedBox(width: 10),
                  Expanded(child: Text(c.label, style: T.h2(p.fg))),
                  Text(fmtDate(e.at), style: T.label(p.muted)),
                ],
              ),
              const SizedBox(height: 6),
              Text(e.resisted ? 'Widerstanden' : 'Nachgegeben', style: T.quote(p.muted, size: 16)),
              const SizedBox(height: 22),
              if (feel.isNotEmpty) block('Gefühl', Text(feel.join(', '), style: T.body(p.fg))),
              if (e.thought.isNotEmpty) block('Gedanke', Text('„${e.thought}“', style: T.quote(p.fg, size: 18))),
              if (e.used.isNotEmpty) block('Werkzeuge', Text(e.used.join(' · '), style: T.body(p.fg))),
              block(
                'Verlangen',
                Text(
                  e.after == null ? 'Stärke ${e.before}' : 'Von ${e.before} auf ${e.after}',
                  style: T.num(p.fg, size: 18),
                ),
              ),
              GhostButton('Schließen', onPressed: () => Navigator.of(ctx).pop()),
            ],
          ),
        ),
      );
    },
  );
}

/// Gemerkte Impulse.
class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    return Scaffold(
      appBar: AppBar(title: const Text('GEMERKT')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(title: 'Was bei dir wirkt.', motto: 'Deine gesammelten Sätze. Lies sie, wenn es eng wird.'),
          const SizedBox(height: 20),
          if (s.saved.isEmpty)
            Text(
              'Noch nichts gemerkt. Wisch eine Impuls-Karte nach rechts, um sie hier zu sammeln.',
              style: T.body(p.muted),
            ),
          for (final t in s.saved) ...[
            Dismissible(
              key: ValueKey(t),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.delete_outline_rounded, color: p.inverseFg),
              ),
              onDismissed: (_) => s.toggleSaved(t),
              child: Tile(
                padding: const EdgeInsets.all(18),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(t, style: T.quote(p.fg, size: 19)),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (s.saved.isNotEmpty) Text('Nach links wischen zum Entfernen.', style: T.small(p.muted)),
        ],
      ),
    );
  }
}

/// Einstellungen als Blatt von unten.
Future<void> showSettings(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return ListenableBuilder(
        listenable: StoreScope.read(context),
        builder: (ctx, _) {
          final p = ctx.c;
          final s = StoreScope.read(context);
          final mode = s.followSystem ? 0 : (s.dark ? 2 : 1);
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label('Einstellungen', color: p.fg),
                  const SizedBox(height: 18),
                  Text('Darstellung', style: T.h2(p.fg)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      Pill('System', selected: mode == 0, onTap: () => s.update((s) => s.followSystem = true)),
                      Pill(
                        'Hell',
                        selected: mode == 1,
                        onTap: () => s.update((s) {
                          s.followSystem = false;
                          s.dark = false;
                        }),
                      ),
                      Pill(
                        'Dunkel',
                        selected: mode == 2,
                        onTap: () => s.update((s) {
                          s.followSystem = false;
                          s.dark = true;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Eigene Kategorien', style: T.h2(p.fg)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in customCravings)
                        Pill(
                          c.label,
                          icon: Icons.edit_outlined,
                          onTap: () => editCraving(ctx, existing: c),
                        ),
                      Pill('Neue Kategorie', icon: Icons.add_rounded, onTap: () => editCraving(ctx)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Daten', style: T.h2(p.fg)),
                  const SizedBox(height: 6),
                  Text(
                    'Alles liegt nur auf diesem Gerät. Kein Konto, keine Cloud, kein Tracking.',
                    style: T.small(p.muted),
                  ),
                  const SizedBox(height: 12),
                  GhostButton(
                    'Alle Daten löschen',
                    icon: Icons.delete_outline_rounded,
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: ctx,
                        builder: (d) => AlertDialog(
                          title: Text('Wirklich alles löschen?', style: T.h2(p.fg)),
                          content: Text(
                            'Protokoll, Brief, Alternativen, Buddy, eigene Kategorien und Gemerktes. Das lässt sich nicht rückgängig machen.',
                            style: T.body(p.fg),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(d, false), child: const Text('Abbrechen')),
                            TextButton(onPressed: () => Navigator.pop(d, true), child: const Text('Löschen')),
                          ],
                        ),
                      );
                      if (ok == true) {
                        await s.wipe();
                        if (ctx.mounted) Navigator.of(ctx).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  Text('Disziplinator 3000 · v1.0', style: T.label(p.muted)),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
