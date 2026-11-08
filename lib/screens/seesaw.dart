import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Ein Feld der Wippe: Text plus Gewicht 1 bis 3.
class _Field {
  final String key;
  final String label;
  final String hint;
  final bool benefit;
  final TextEditingController c = TextEditingController();
  int weight = 2;
  _Field(this.key, this.label, this.hint, {required this.benefit});
}

class _Side {
  final TextEditingController name;
  final List<_Field> fields;
  _Side(String n, List<_Field> f) : name = TextEditingController(text: n), fields = f;

  int get score {
    var s = 0;
    for (final f in fields) {
      if (f.c.text.trim().isEmpty) continue;
      s += f.benefit ? f.weight : -f.weight;
    }
    return s;
  }
}

List<_Field> _fields(bool hard) => [
  _Field('bk', 'Nutzen kurzfristig', hard ? 'Energie, Stolz, schuldfreier Abend' : 'Bequem, sofort gut', benefit: true),
  _Field('bl', 'Nutzen langfristig', hard ? 'Gesundheit, Selbstvertrauen' : 'Gibt es überhaupt einen?', benefit: true),
  _Field(
    'kk',
    'Kosten kurzfristig',
    hard ? 'Umziehen, hinfahren, 40 Minuten' : 'Schlechtes Gewissen, Trägheit',
    benefit: false,
  ),
  _Field('kl', 'Kosten langfristig', hard ? 'Eigentlich keine' : 'Kein Fortschritt, Muster verfestigt', benefit: false),
];

class SeesawScreen extends StatefulWidget {
  const SeesawScreen({super.key});

  @override
  State<SeesawScreen> createState() => _SeesawScreenState();
}

class _SeesawScreenState extends State<SeesawScreen> {
  final _question = TextEditingController();
  final _a = _Side('Die schwierige Option', _fields(true));
  final _b = _Side('Die bequeme Option', _fields(false));

  @override
  void dispose() {
    _question.dispose();
    for (final s in [_a, _b]) {
      s.name.dispose();
      for (final f in s.fields) {
        f.c.dispose();
      }
    }
    super.dispose();
  }

  int get _filled => [..._a.fields, ..._b.fields].where((f) => f.c.text.trim().isNotEmpty).length;

  String _verdict() {
    final d = _a.score - _b.score;
    if (_filled < 4) return 'Füll mindestens vier Felder aus.';
    if (d == 0) return 'Gleichstand. Lies die Kosten der bequemen Seite noch einmal laut vor.';
    final w = d > 0 ? _a.name.text : _b.name.text;
    return 'Die Wippe neigt sich zu „$w“ (${d.abs()} ${d.abs() == 1 ? 'Punkt' : 'Punkte'} Vorsprung).';
  }

  void _save() {
    final data = <String, dynamic>{};
    for (final (side, tag) in [(_a, 'a'), (_b, 'b')]) {
      data['${tag}_name'] = side.name.text;
      for (final f in side.fields) {
        data['${tag}_${f.key}'] = f.c.text;
        data['${tag}_${f.key}_w'] = f.weight;
      }
    }
    context.readStore.addDecision(
      Decision(
        at: DateTime.now(),
        kind: 'seesaw',
        question: _question.text.trim().isEmpty ? '${_a.name.text} oder ${_b.name.text}' : _question.text.trim(),
        verdict: _verdict(),
        data: data,
      ),
    );
    HapticFeedback.mediumImpact();
    toast(context, 'Im Protokoll gespeichert.');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final diff = _a.score - _b.score;

    return Scaffold(
      appBar: AppBar(title: const Text('05 · ENTSCHEIDUNGS-WIPPE')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(
            title: 'Mach die Folgen spürbar.',
            motto: 'Du weißt es längst. Jetzt sollst du es auch spüren.',
          ),
          const SizedBox(height: 20),
          Text('Worum geht es?', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _question,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Zum Beispiel: Sport oder Sofa?'),
          ),
          const SizedBox(height: 18),
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: p.line),
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: diff.clamp(-8, 8) / 8),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutBack,
              builder: (_, v, _) => CustomPaint(
                painter: _SeesawPainter(tilt: v, fg: p.fg, muted: p.muted, line: p.line),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ScoreLabel(name: _a.name.text, score: _a.score, align: TextAlign.left),
                      ),
                      Expanded(
                        child: _ScoreLabel(name: _b.name.text, score: _b.score, align: TextAlign.right),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(_verdict(), style: T.quote(p.fg, size: 17)),
          for (final side in [_a, _b]) ...[
            SectionHeader(side == _a ? 'Option A' : 'Option B'),
            TextField(
              controller: side.name,
              style: T.h2(p.fg),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Name der Option'),
            ),
            const SizedBox(height: 12),
            for (final f in side.fields) ...[
              _FieldEditor(field: f, onChanged: () => setState(() {})),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 12),
          PrimaryButton('Entscheidung speichern', icon: Icons.check_rounded, onPressed: _filled == 0 ? null : _save),
          const SizedBox(height: 14),
          Text(
            'Gewicht 1 bis 3: Wie schwer wiegt der Punkt für dich? Nutzen drückt die Seite nach unten, Kosten heben sie an.',
            style: T.small(p.muted),
          ),
        ],
      ),
    );
  }
}

class _ScoreLabel extends StatelessWidget {
  final String name;
  final int score;
  final TextAlign align;
  const _ScoreLabel({required this.name, required this.score, required this.align});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Column(
      crossAxisAlignment: align == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Text(score > 0 ? '+$score' : '$score', style: T.num(p.fg, size: 22)),
        const SizedBox(height: 2),
        Text(name, style: T.small(p.muted), textAlign: align, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}

class _FieldEditor extends StatelessWidget {
  final _Field field;
  final VoidCallback onChanged;
  const _FieldEditor({required this.field, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field.benefit ? '+' : '−', style: T.num(p.fg, size: 16)),
              const SizedBox(width: 8),
              Expanded(child: Label(field.label, color: p.fg)),
              for (var w = 1; w <= 3; w++)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    field.weight = w;
                    onChanged();
                  },
                  child: Container(
                    width: 30,
                    height: 26,
                    margin: const EdgeInsets.only(left: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: field.weight == w ? p.fg : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: field.weight == w ? p.fg : p.line),
                    ),
                    child: Text('$w', style: T.num(field.weight == w ? p.inverseFg : p.fg, size: 12)),
                  ),
                ),
            ],
          ),
          TextField(
            controller: field.c,
            minLines: 1,
            maxLines: null,
            onChanged: (_) => onChanged(),
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: field.hint,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.only(top: 8, bottom: 2),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeesawPainter extends CustomPainter {
  /// -1 bis 1. Positiv heißt: Option A (links) ist schwerer und sinkt.
  final double tilt;
  final Color fg;
  final Color muted;
  final Color line;
  _SeesawPainter({required this.tilt, required this.fg, required this.muted, required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final pivotY = size.height - 34;
    final beamLen = size.width * 0.72;
    final angle = -tilt * 0.22;

    // Boden
    canvas.drawLine(
      Offset(24, size.height - 18),
      Offset(size.width - 24, size.height - 18),
      Paint()
        ..color = line
        ..strokeWidth = 1.5,
    );
    // Drehpunkt
    final tri = Path()
      ..moveTo(cx, pivotY)
      ..lineTo(cx - 14, size.height - 18)
      ..lineTo(cx + 14, size.height - 18)
      ..close();
    canvas.drawPath(tri, Paint()..color = fg);

    canvas.save();
    canvas.translate(cx, pivotY);
    canvas.rotate(angle);
    final beam = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: beamLen, height: 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(beam, Paint()..color = fg);
    // Gewichte
    final l = Offset(-beamLen / 2 + 14, -14);
    final r = Offset(beamLen / 2 - 14, -14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: l, width: 22, height: 22), const Radius.circular(5)),
      Paint()..color = fg,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: r, width: 22, height: 22), const Radius.circular(5)),
      Paint()
        ..color = fg
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
    canvas.drawCircle(Offset(cx, pivotY), 3, Paint()..color = fg);
  }

  @override
  bool shouldRepaint(covariant _SeesawPainter old) => old.tilt != tilt || old.fg != fg;
}
