import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Technik 8: Urge Sprint in drei Schritten.
class SprintScreen extends StatefulWidget {
  final String? craving;
  const SprintScreen({super.key, this.craving});

  @override
  State<SprintScreen> createState() => _SprintScreenState();
}

class _SprintScreenState extends State<SprintScreen> {
  bool _one = false;
  bool _two = false;
  bool _three = false;

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final c = cravingById(widget.craving);
    final tips = widget.craving == null
        ? ['Snack wegwerfen, Handy weglegen, Laptop zuklappen. Was auch immer es ist: weg damit.']
        : c.removeTrigger;

    return Scaffold(
      appBar: AppBar(title: const Text('08 · URGE SPRINT')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(title: 'Sprint. Jetzt.', motto: 'Das Zeitfenster ist kurz. Wer zögert, malt schon aus.'),
          const SizedBox(height: 24),
          _Step(
            nr: '1',
            title: 'Auslöser weg',
            done: _one,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final t in tips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('· $t', style: T.body(p.fg)),
                  ),
                const SizedBox(height: 8),
                GhostButton(
                  _one ? 'Erledigt' : 'Ist weg',
                  icon: _one ? Icons.check_rounded : null,
                  onPressed: () => setState(() => _one = true),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Step(
            nr: '2',
            title: 'Bewegen',
            done: _two,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schon eine einzige Runde Bewegung senkt Verlangen messbar. 15 Minuten Gehen reichen.',
                  style: T.body(p.fg),
                ),
                const SizedBox(height: 10),
                GhostButton(
                  'Bewegungs-Timer',
                  icon: Icons.directions_walk_rounded,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MoveScreen()));
                    if (mounted) setState(() => _two = true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Step(
            nr: '3',
            title: 'Kopf füllen',
            done: _three,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verlangen lebt im Arbeitsgedächtnis. Füll es mit etwas anderem, dann ist kein Platz mehr. Drei Minuten genügen.',
                  style: T.body(p.fg),
                ),
                const SizedBox(height: 10),
                GhostButton(
                  'Muster-Spiel, 3 Min.',
                  icon: Icons.grid_view_rounded,
                  onPressed: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PatternGameScreen()));
                    if (mounted) setState(() => _three = true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton('Sprint beendet', icon: Icons.flag_outlined, onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String nr;
  final String title;
  final bool done;
  final Widget body;
  const _Step({required this.nr, required this.title, required this.done, required this.body});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: done ? p.fg : p.line, width: done ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: done ? p.fg : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.fg, width: 1.4),
                ),
                child: done
                    ? Icon(Icons.check_rounded, size: 18, color: p.inverseFg)
                    : Text(nr, style: T.num(p.fg, size: 14)),
              ),
              const SizedBox(width: 12),
              Text(title, style: T.h2(p.fg)),
            ],
          ),
          const SizedBox(height: 12),
          body,
        ],
      ),
    );
  }
}

// Bewegung -----------------------------------------------------------------

const _moves = [
  ('Zügig gehen', 15 * 60),
  ('Treppe rauf und runter', 5 * 60),
  ('Kniebeugen, 3 × 15', 4 * 60),
  ('Hampelmänner', 2 * 60),
  ('Liegestütze bis zur Grenze', 2 * 60),
  ('Planke halten', 60),
];

class MoveScreen extends StatefulWidget {
  const MoveScreen({super.key});

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {
  int _sel = 0;
  int _left = _moves.first.$2;
  Timer? _t;

  bool get _running => _t?.isActive ?? false;

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    if (_running) {
      _t!.cancel();
      setState(() {});
      return;
    }
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        HapticFeedback.heavyImpact();
        setState(() => _left = 0);
      } else {
        setState(() => _left--);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final total = _moves[_sel].$2;
    return Scaffold(
      appBar: AppBar(title: const Text('08 · BEWEGEN')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(
            title: 'Beweg dich.',
            motto: 'Bewegung baut einen Schild gegen Verlangen. Selbst unter Stress.',
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _moves.length; i++)
                Pill(
                  '${_moves[i].$1} · ${_moves[i].$2 ~/ 60 == 0 ? 1 : _moves[i].$2 ~/ 60}′',
                  selected: _sel == i,
                  onTap: () {
                    _t?.cancel();
                    setState(() {
                      _sel = i;
                      _left = _moves[i].$2;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 36),
          Center(
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.expand(
                    child: CircularProgressIndicator(
                      value: total == 0 ? 0 : 1 - _left / total,
                      strokeWidth: 4,
                      color: p.fg,
                      backgroundColor: p.line,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(fmtClock(_left), style: T.num(p.fg, size: 48)),
                      const SizedBox(height: 6),
                      Text(_moves[_sel].$1, style: T.quote(p.muted, size: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          if (_left == 0)
            PrimaryButton('Geschafft', icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop(true))
          else
            PrimaryButton(
              _running ? 'Pause' : 'Start',
              icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              onPressed: _toggle,
            ),
          const SizedBox(height: 10),
          GhostButton('Fertig', onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
  }
}

// Muster-Spiel ---------------------------------------------------------------

/// Ein Merkspiel, das drei Minuten lang das visuelle Arbeitsgedächtnis füllt.
class PatternGameScreen extends StatefulWidget {
  const PatternGameScreen({super.key});

  @override
  State<PatternGameScreen> createState() => _PatternGameScreenState();
}

class _PatternGameScreenState extends State<PatternGameScreen> {
  static const _total = 180;
  static const _n = 16;
  final _rnd = Random();
  List<int> _seq = [];
  int _len = 3;
  int _best = 0;
  int _input = 0;
  int? _lit;
  int? _wrong;
  bool _showing = false;
  bool _started = false;
  int _left = _total;
  int _gen = 0;
  Timer? _clock;

  @override
  void dispose() {
    _clock?.cancel();
    _gen++;
    super.dispose();
  }

  void _start() {
    HapticFeedback.mediumImpact();
    setState(() {
      _started = true;
      _left = _total;
      _len = 3;
      _best = 0;
    });
    _clock = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 1) {
        t.cancel();
        _gen++;
        HapticFeedback.heavyImpact();
        setState(() {
          _left = 0;
          _showing = false;
          _lit = null;
        });
      } else {
        setState(() => _left--);
      }
    });
    _round();
  }

  Future<void> _round() async {
    final g = ++_gen;
    _seq = [];
    while (_seq.length < _len) {
      final x = _rnd.nextInt(_n);
      if (_seq.isEmpty || _seq.last != x) _seq.add(x);
    }
    setState(() {
      _showing = true;
      _input = 0;
      _wrong = null;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    for (final x in _seq) {
      if (!mounted || g != _gen) return;
      setState(() => _lit = x);
      await Future.delayed(const Duration(milliseconds: 480));
      if (!mounted || g != _gen) return;
      setState(() => _lit = null);
      await Future.delayed(const Duration(milliseconds: 170));
    }
    if (!mounted || g != _gen) return;
    setState(() => _showing = false);
  }

  Future<void> _tap(int i) async {
    if (_showing || _left == 0 || !_started) return;
    HapticFeedback.selectionClick();
    if (_seq[_input] == i) {
      setState(() {
        _lit = i;
        _input++;
      });
      await Future.delayed(const Duration(milliseconds: 140));
      if (!mounted) return;
      setState(() => _lit = null);
      if (_input == _seq.length) {
        _best = max(_best, _len);
        _len++;
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted && _left > 0) _round();
      }
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _wrong = i);
      _len = max(3, _len - 1);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted && _left > 0) _round();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final over = _started && _left == 0;
    return Scaffold(
      appBar: AppBar(title: const Text('08 · KOPF FÜLLEN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Label('Zeit'),
                      const SizedBox(height: 4),
                      Text(fmtClock(_left), style: T.num(p.fg, size: 34)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Label('Länge · Rekord'),
                      const SizedBox(height: 4),
                      Text('$_len · $_best', style: T.num(p.fg, size: 34)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                !_started
                    ? 'Merk dir die Reihenfolge der Felder und tipp sie nach. Jede Runde eins mehr.'
                    : over
                    ? 'Drei Minuten voll. Wie fühlt sich das Verlangen jetzt an?'
                    : _showing
                    ? 'Merken …'
                    : 'Jetzt du. ${_seq.length - _input} noch.',
                style: T.quote(p.muted, size: 17),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      physics: const NeverScrollableScrollPhysics(),
                      children: List.generate(_n, (i) {
                        final lit = _lit == i;
                        final wrong = _wrong == i;
                        return GestureDetector(
                          onTapDown: (_) => _tap(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 90),
                            decoration: BoxDecoration(
                              color: lit ? p.fg : p.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: wrong ? p.fg : p.line, width: wrong ? 3 : 1),
                            ),
                            child: wrong ? Icon(Icons.close_rounded, color: p.fg) : null,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (!_started)
                PrimaryButton('Start', icon: Icons.play_arrow_rounded, onPressed: _start)
              else if (over)
                PrimaryButton('Fertig', icon: Icons.check_rounded, onPressed: () => Navigator.of(context).pop(true))
              else
                GhostButton('Abbrechen', onPressed: () => Navigator.of(context).pop(true)),
            ],
          ),
        ),
      ),
    );
  }
}
