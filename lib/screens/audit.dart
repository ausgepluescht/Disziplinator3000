import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class _Q {
  final String label;
  final String question;
  final String example;
  const _Q(this.label, this.question, this.example);
}

const _questions = [
  _Q(
    'Verlangen',
    'Was willst du gerade wirklich? Nicht das Ding, sondern das Gefühl dahinter.',
    'Instagram. Eigentlich: Ablenkung und Abschalten.',
  ),
  _Q('Gefühl', 'Was hast du direkt vor dem Verlangen gefühlt?', 'Müde, gelangweilt, geistig leer.'),
  _Q('Gedanke', 'Welcher Gedanke kam unmittelbar davor?', '„Feierabend. Das hab ich mir verdient.“'),
  _Q(
    'Situation',
    'Welche Situation hat diesen Gedanken ausgelöst?',
    'Nach der Arbeit falle ich aufs Sofa, das Handy liegt direkt neben mir.',
  ),
  _Q(
    'Umbau',
    'Wie veränderst du die Situation, sodass der Auslöser gar nicht erst auftaucht? Wann, wo, wie genau?',
    'Um 21:30 kommt das Handy ins Ladegerät im Flur. Auf dem Sofa liegt ein gutes Buch.',
  ),
];

/// Technik 10: Auslöser-Check. Vom Verlangen rückwärts zur Situation.
class AuditScreen extends StatefulWidget {
  final String? craving;
  const AuditScreen({super.key, this.craving});

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  late String _craving = widget.craving ?? 'handy';
  final _c = List.generate(_questions.length, (_) => TextEditingController());
  int _step = -1; // -1 = Übersicht

  @override
  void dispose() {
    for (final c in _c) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    context.readStore.addAudit(
      Audit(
        at: DateTime.now(),
        craving: _craving,
        want: _c[0].text.trim(),
        feeling: _c[1].text.trim(),
        thought: _c[2].text.trim(),
        situation: _c[3].text.trim(),
        fix: _c[4].text.trim(),
      ),
    );
    HapticFeedback.mediumImpact();
    for (final c in _c) {
      c.clear();
    }
    setState(() => _step = -1);
    toast(context, 'Umbau gespeichert. Setz ihn noch heute um.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step < 0 ? '10 · AUSLÖSER-CHECK' : '10 · AUSLÖSER-CHECK · ${_step + 1}/${_questions.length}'),
        leading: _step >= 0
            ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => setState(() => _step = -1))
            : null,
      ),
      body: _step < 0 ? _overview(context) : _wizard(context),
    );
  }

  Widget _overview(BuildContext context) {
    final p = context.c;
    final s = context.store;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        const PageHead(
          title: 'Entfern das Schlachtfeld.',
          motto: 'Situation, Gedanke, Gefühl, Verlangen. Setz ganz vorne an.',
        ),
        const SizedBox(height: 18),
        const _Chain(),
        const SizedBox(height: 22),
        Text('Um welches Verlangen geht es?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in cravings)
              Pill(c.label, icon: c.icon, selected: _craving == c.id, onTap: () => setState(() => _craving = c.id)),
          ],
        ),
        const SizedBox(height: 22),
        PrimaryButton('Check starten', icon: Icons.search_rounded, onPressed: () => setState(() => _step = 0)),
        SectionHeader('Deine Umbauten', trailing: Text('${s.audits.length}', style: T.num(p.muted, size: 12))),
        if (s.audits.isEmpty)
          Text(
            'Noch keine. Hier das Beispiel aus dem Video: jeden Abend um 22 Uhr endloses Scrollen.',
            style: T.body(p.muted),
          ),
        if (s.audits.isEmpty) ...[
          const SizedBox(height: 12),
          _AuditCard(
            audit: Audit(
              at: DateTime.now(),
              craving: 'handy',
              want: _questions[0].example,
              feeling: _questions[1].example,
              thought: _questions[2].example,
              situation: _questions[3].example,
              fix: _questions[4].example,
            ),
            example: true,
          ),
        ],
        for (final a in s.audits) ...[
          _AuditCard(audit: a, onDelete: () => s.update((s) => s.audits.remove(a))),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _wizard(BuildContext context) {
    final p = context.c;
    final q = _questions[_step];
    final last = _step == _questions.length - 1;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      children: [
        Row(
          children: List.generate(
            _questions.length,
            (i) => Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: i <= _step ? p.fg : p.line,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        Label(q.label),
        const SizedBox(height: 12),
        Text(q.question, style: T.quote(p.fg, size: 24)),
        const SizedBox(height: 18),
        TextField(
          controller: _c[_step],
          autofocus: true,
          minLines: 3,
          maxLines: null,
          style: T.body(p.fg),
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: q.example),
        ),
        const SizedBox(height: 10),
        Text('Beispiel: ${q.example}', style: T.small(p.muted)),
        if (last && _c[3].text.trim().isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: p.faint, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Label('Deine Situation'),
                const SizedBox(height: 6),
                Text(_c[3].text.trim(), style: T.body(p.fg)),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
        Row(
          children: [
            if (_step > 0) ...[
              Expanded(child: GhostButton('Zurück', onPressed: () => setState(() => _step--))),
              const SizedBox(width: 10),
            ],
            Expanded(
              flex: 2,
              child: PrimaryButton(
                last ? 'Umbau speichern' : 'Weiter',
                icon: last ? Icons.check_rounded : Icons.arrow_forward_rounded,
                onPressed: last ? _save : () => setState(() => _step++),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Chain extends StatelessWidget {
  const _Chain();

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    const steps = ['Situation', 'Gedanke', 'Gefühl', 'Verlangen'];
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == 0 ? p.fg : p.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.fg),
              ),
              child: Text(
                steps[i],
                style: T.label(i == 0 ? p.inverseFg : p.fg).copyWith(fontSize: 9.5, letterSpacing: 0.6),
                maxLines: 1,
              ),
            ),
          ),
          if (i < steps.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(Icons.arrow_forward_rounded, size: 14, color: p.muted),
            ),
        ],
      ],
    );
  }
}

class _AuditCard extends StatelessWidget {
  final Audit audit;
  final bool example;
  final VoidCallback? onDelete;
  const _AuditCard({required this.audit, this.example = false, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final c = cravingById(audit.craving);
    Widget row(String l, String v) => v.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 84,
                  child: Padding(padding: const EdgeInsets.only(top: 3), child: Label(l)),
                ),
                Expanded(child: Text(v, style: T.small(p.fg))),
              ],
            ),
          );
    return Tile(
      onLongPress: onDelete == null
          ? null
          : () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Umbau löschen?', style: T.h2(p.fg)),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
                  ],
                ),
              );
              if (ok == true) onDelete!();
            },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(c.icon, size: 18, color: p.fg),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.label, style: T.small(p.fg).copyWith(fontWeight: FontWeight.w700)),
              ),
              Text(example ? 'BEISPIEL' : fmtDate(audit.at), style: T.label(p.muted)),
            ],
          ),
          if (audit.fix.isNotEmpty) ...[const SizedBox(height: 12), Text(audit.fix, style: T.quote(p.fg, size: 18))],
          const SizedBox(height: 4),
          row('Wunsch', audit.want),
          row('Gefühl', audit.feeling),
          row('Gedanke', audit.thought),
          row('Situation', audit.situation),
        ],
      ),
    );
  }
}
