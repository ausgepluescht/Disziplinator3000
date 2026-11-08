import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/impulses.dart';
import '../data/techniques.dart';
import '../store.dart';
import '../theme.dart';

/// Kartenstapel zum Wischen.
/// Nach links: nächste Karte. Nach rechts: merken und weiter.
class SwipeDeck extends StatefulWidget {
  final List<Impulse> Function() builder;
  final double height;

  /// Tippen auf die Technik-Zeile öffnet die Technik.
  final void Function(int tech)? onOpenTech;

  const SwipeDeck({super.key, required this.builder, this.height = 300, this.onOpenTech});

  @override
  State<SwipeDeck> createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck> with SingleTickerProviderStateMixin {
  late List<Impulse> _cards;
  int _i = 0;
  Offset _drag = Offset.zero;
  late final AnimationController _ac;
  Animation<Offset>? _anim;
  int _pendingDir = 0;

  @override
  void initState() {
    super.initState();
    _cards = widget.builder();
    _ac = AnimationController(vsync: this, duration: const Duration(milliseconds: 260))
      ..addListener(() => setState(() => _drag = _anim!.value))
      ..addStatusListener(_onAnimDone);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void reshuffle() {
    setState(() {
      _cards = widget.builder();
      _i = 0;
      _drag = Offset.zero;
    });
  }

  Impulse? get _current => _cards.isEmpty ? null : _cards[_i % _cards.length];
  Impulse? get _next => _cards.length < 2 ? null : _cards[(_i + 1) % _cards.length];

  void _onAnimDone(AnimationStatus st) {
    if (st != AnimationStatus.completed) return;
    if (_pendingDir != 0) {
      setState(() {
        _i++;
        if (_i >= _cards.length) {
          _cards = widget.builder();
          _i = 0;
        }
        _drag = Offset.zero;
        _pendingDir = 0;
      });
    }
  }

  void _animateTo(Offset target, {int dir = 0}) {
    _pendingDir = dir;
    _anim = Tween(begin: _drag, end: target).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
    _ac.forward(from: 0);
  }

  void swipe(int dir) {
    final cur = _current;
    if (cur == null || _ac.isAnimating) return;
    final w = MediaQuery.of(context).size.width;
    if (dir > 0) {
      final store = context.readStore;
      if (!store.isSaved(cur.text)) store.toggleSaved(cur.text);
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    _animateTo(Offset(dir * w * 1.3, _drag.dy + 30), dir: dir);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final cur = _current;
    if (cur == null) return const SizedBox.shrink();
    final w = MediaQuery.of(context).size.width;
    final progress = (_drag.dx / (w * 0.4)).clamp(-1.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (_next != null)
                Positioned.fill(
                  child: Transform.scale(
                    scale: 0.94 + 0.06 * progress.abs(),
                    alignment: Alignment.bottomCenter,
                    child: Transform.translate(
                      offset: Offset(0, 12 * (1 - progress.abs())),
                      child: _CardFace(impulse: _next!, dim: true),
                    ),
                  ),
                ),
              Positioned.fill(
                child: GestureDetector(
                  onPanUpdate: (d) {
                    if (_ac.isAnimating) return;
                    setState(() => _drag += d.delta);
                  },
                  onPanEnd: (d) {
                    if (_ac.isAnimating) return;
                    final v = d.velocity.pixelsPerSecond.dx;
                    if (_drag.dx > w * 0.28 || v > 900) {
                      swipe(1);
                    } else if (_drag.dx < -w * 0.28 || v < -900) {
                      swipe(-1);
                    } else {
                      _animateTo(Offset.zero);
                    }
                  },
                  child: Transform.translate(
                    offset: _drag,
                    child: Transform.rotate(
                      angle: _drag.dx / w * 0.25,
                      child: _CardFace(
                        impulse: cur,
                        hint: progress,
                        onTechTap: widget.onOpenTech == null ? null : () => widget.onOpenTech!(cur.tech),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _RoundBtn(icon: Icons.arrow_back_rounded, tooltip: 'Weiter', onTap: () => swipe(-1)),
            const SizedBox(width: 10),
            Expanded(
              child: Center(
                child: Text('${(_i % max(1, _cards.length)) + 1} / ${_cards.length}', style: T.num(p.muted, size: 12)),
              ),
            ),
            _RoundBtn(icon: Icons.shuffle_rounded, tooltip: 'Neu mischen', onTap: reshuffle),
            const SizedBox(width: 10),
            _RoundBtn(
              icon: context.store.isSaved(cur.text) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              tooltip: 'Merken',
              filled: true,
              onTap: () => swipe(1),
            ),
          ],
        ),
      ],
    );
  }
}

class _CardFace extends StatelessWidget {
  final Impulse impulse;
  final bool dim;
  final double hint;
  final VoidCallback? onTechTap;
  const _CardFace({required this.impulse, this.dim = false, this.hint = 0, this.onTechTap});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final t = techniqueByNr(impulse.tech);
    final isWhy = impulse.kind == 'warum' || impulse.kind == 'gefuehl';
    final bg = isWhy ? p.inverseBg : p.surface;
    final fg = isWhy ? p.inverseFg : p.fg;
    final muted = isWhy ? p.inverseMuted : p.muted;
    final kindLabel = switch (impulse.kind) {
      'bild' => 'Stell es dir vor',
      'warum' => 'Aus deinem Brief',
      'gefuehl' => 'Zu deinem Gefühl',
      _ => 'Frag dich',
    };

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 120),
      opacity: dim ? 0.9 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: dim ? p.surface : bg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: dim ? p.line : (isWhy ? p.inverseBg : p.fg), width: dim ? 1 : 1.4),
          boxShadow: dim
              ? null
              : [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onTechTap,
                  child: Row(
                    children: [
                      Text(t.nrLabel, style: T.num(fg, size: 13)),
                      const SizedBox(width: 8),
                      Container(width: 14, height: 1, color: muted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.title.toUpperCase(),
                          style: T.label(muted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onTechTap != null) Icon(Icons.north_east_rounded, size: 14, color: muted),
                    ],
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final len = impulse.text.length;
                      final size = len > 150 ? 18.0 : (len > 90 ? 21.0 : 25.0);
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: c.maxWidth,
                            child: Text(impulse.text, style: T.quote(fg, size: size)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text(kindLabel.toUpperCase(), style: T.label(muted)),
              ],
            ),
            if (hint.abs() > 0.05)
              Positioned(
                top: 28,
                right: hint > 0 ? 0 : null,
                left: hint < 0 ? 0 : null,
                child: Opacity(
                  opacity: hint.abs(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: hint > 0 ? fg : bg,
                      border: Border.all(color: fg, width: 1.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(hint > 0 ? 'MERKEN' : 'WEITER', style: T.label(hint > 0 ? bg : fg)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool filled;
  const _RoundBtn({required this.icon, required this.tooltip, required this.onTap, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: filled ? p.fg : p.surface,
        shape: CircleBorder(side: BorderSide(color: p.fg, width: 1.2)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 21, color: filled ? p.inverseFg : p.fg)),
        ),
      ),
    );
  }
}
