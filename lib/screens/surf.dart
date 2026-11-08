import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

const _bodyPrompts = [
  'Wo im Körper spürst du es gerade am deutlichsten?',
  'Ist es Druck, Ziehen, Kribbeln, Wärme oder Unruhe?',
  'Atme langsam in genau diese Stelle hinein.',
  'Hände, Brust, Bauch, Kiefer: Wo spürst du Anspannung?',
  'Wird die Welle gerade höher oder flacher?',
  'Du musst nichts tun, nur beobachten.',
  'Lass die Gedanken vorbeiziehen. Zurück zum Körper.',
  'Wo hört das Gefühl auf? Wie fühlt sich der Rand an?',
  'Du hältst das gerade aus. Merk dir das.',
  'Jede Welle erreicht einen Kamm. Danach flacht sie ab.',
];

class SurfScreen extends StatefulWidget {
  const SurfScreen({super.key});

  @override
  State<SurfScreen> createState() => _SurfScreenState();
}

enum _Phase { setup, running, done }

class _SurfScreenState extends State<SurfScreen> with SingleTickerProviderStateMixin {
  _Phase _phase = _Phase.setup;
  int? _before;
  int? _after;
  int _target = 300;
  int _left = 300;
  bool _completed = false;
  Timer? _timer;
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final s = context.readStore;
      setState(() {
        _target = s.surfSeconds;
        _left = _target;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _wave.dispose();
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = _Phase.running;
      _left = _target;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _left = 0;
          _completed = true;
          _phase = _Phase.done;
        });
      } else {
        setState(() => _left--);
      }
    });
  }

  void _stop() {
    _timer?.cancel();
    setState(() => _phase = _Phase.done);
  }

  void _close() {
    final s = context.readStore;
    if (_completed) s.surfCompleted();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('01 · URGE SURFING')),
      body: switch (_phase) {
        _Phase.setup => _setup(context),
        _Phase.running => _running(context),
        _Phase.done => _done(context),
      },
    );
  }

  Widget _setup(BuildContext context) {
    final p = context.c;
    return ActionBody(
      actions: [PrimaryButton('Los geht’s', icon: Icons.waves_rounded, onPressed: _start)],
      children: [
        const PageHead(title: 'Surf die Welle.', motto: 'Nicht wegdrücken, nicht nachgeben. Nur hinspüren.'),
        const SizedBox(height: 24),
        Text('Wie stark ist das Verlangen jetzt?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 12),
        ScaleRow(value: _before, onChanged: (v) => setState(() => _before = v)),
        const SizedBox(height: 28),
        Tile(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Label('Dauer heute'),
                    const SizedBox(height: 8),
                    Text(fmtClock(_target), style: T.num(p.fg, size: 40)),
                  ],
                ),
              ),
              IconButton.outlined(
                onPressed: _target > 60 ? () => setState(() => _target -= 60) : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                onPressed: _target < 1800 ? () => setState(() => _target += 60) : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Danach darfst du tun, was du willst. Hältst du durch, verlängert sich der Timer beim nächsten Mal um eine Minute, bis höchstens 30 Minuten.',
          style: T.small(p.muted),
        ),
      ],
    );
  }

  Widget _running(BuildContext context) {
    final p = context.c;
    final elapsed = _target - _left;
    final prompt = _bodyPrompts[(elapsed ~/ 20) % _bodyPrompts.length];
    final progress = _target == 0 ? 0.0 : elapsed / _target;
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(fmtClock(_left), style: T.num(p.fg, size: 64)),
        const SizedBox(height: 4),
        Label('noch'),
        const SizedBox(height: 28),
        Expanded(
          child: AnimatedBuilder(
            animation: _wave,
            builder: (_, _) => CustomPaint(
              size: Size.infinite,
              painter: _WavePainter(t: _wave.value, progress: progress, color: p.fg, line: p.line),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: Text(prompt, key: ValueKey(prompt), textAlign: TextAlign.center, style: T.quote(p.fg, size: 22)),
          ),
        ),
        const SizedBox(height: 12),
        ActionBar(children: [GhostButton('Die Welle ist schon vorbei', onPressed: _stop)]),
      ],
    );
  }

  Widget _done(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final next = (s.surfSeconds + 60).clamp(60, 1800);
    return ActionBody(
      topPadding: 12,
      actions: [PrimaryButton('Fertig', icon: Icons.check_rounded, onPressed: _close)],
      children: [
        PageHead(
          kicker: _completed ? 'Durchgehalten' : 'Abgebrochen nach ${fmtClock(_target - _left)}',
          title: _completed ? 'Du hast die Welle geritten.' : 'Auch das zählt.',
          motto: _completed
              ? 'Nächstes Mal: ${fmtClock(next)}. Jedes Mal ein Stück länger.'
              : 'Jede Sekunde Hinspüren ist Training. Morgen geht es weiter.',
        ),
        const SizedBox(height: 28),
        Text('Wie stark ist das Verlangen jetzt?', style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 12),
        ScaleRow(value: _after, onChanged: (v) => setState(() => _after = v)),
        if (_before != null && _after != null) ...[
          const SizedBox(height: 16),
          Text(
            _after! < _before!
                ? 'Von $_before auf $_after. Genau so funktionieren Wellen.'
                : 'Immer noch stark? Dann direkt in den Notfall-Sprint: bewegen, Kopf beschäftigen.',
            style: T.small(p.fg),
          ),
        ],
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  final double t;
  final double progress;
  final Color color;
  final Color line;
  _WavePainter({required this.t, required this.progress, required this.color, required this.line});

  @override
  void paint(Canvas canvas, Size size) {
    final mid = size.height * 0.55;
    // Die Welle baut sich auf, erreicht in der Mitte ihren Kamm und flacht ab.
    final crest = sin(pi * progress.clamp(0.0, 1.0));
    final amp = size.height * (0.08 + 0.26 * crest);

    for (var layer = 0; layer < 3; layer++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer == 0 ? 2.2 : 1.2
        ..color = layer == 0 ? color : color.withValues(alpha: 0.25 / layer);
      final path = Path();
      final phase = t * 2 * pi + layer * 0.9;
      final a = amp * (1 - layer * 0.25);
      for (var x = 0.0; x <= size.width; x += 3) {
        final k = x / size.width;
        final y = mid - a * sin(k * 2 * pi * 1.2 + phase) * (0.6 + 0.4 * sin(k * pi)) - (layer * 10);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, paint);
    }
    // Fortschrittslinie am Boden
    final base = Paint()
      ..color = line
      ..strokeWidth = 2;
    canvas.drawLine(Offset(24, size.height - 4), Offset(size.width - 24, size.height - 4), base);
    final prog = Paint()
      ..color = color
      ..strokeWidth = 2;
    canvas.drawLine(Offset(24, size.height - 4), Offset(24 + (size.width - 48) * progress, size.height - 4), prog);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t || old.progress != progress || old.color != color;
}
