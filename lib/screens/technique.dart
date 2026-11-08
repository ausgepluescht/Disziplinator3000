import 'package:flutter/material.dart';

import '../data/impulses.dart';
import '../data/techniques.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/swipe_deck.dart';
import '../widgets/ui.dart';

class TechniqueScreen extends StatelessWidget {
  final int nr;
  const TechniqueScreen({super.key, required this.nr});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final t = techniqueByNr(nr);
    final prev = nr > 1 ? techniqueByNr(nr - 1) : null;
    final next = nr < techniques.length ? techniqueByNr(nr + 1) : null;

    return Scaffold(
      appBar: AppBar(title: Text('TECHNIK ${t.nrLabel} / ${techniques.length}')),
      body: ActionBody(
        actions: t.tool == null
            ? null
            : [
                PrimaryButton(
                  t.toolLabel ?? 'Werkzeug öffnen',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => openTool(context, t),
                ),
              ],
        children: [
          PageHead(title: t.title, motto: t.motto),
          const SizedBox(height: 18),
          Text(s.fill(t.explain), style: T.body(p.fg)),
          const SectionHeader('Impulse'),
          SwipeDeck(
            key: ValueKey('deck$nr'),
            builder: () => buildDeck(s, tech: nr),
            height: 250,
          ),
          const SectionHeader('Forschung'),
          Text(t.evidence, style: T.body(p.muted)),
          const SectionHeader('Kritisch hinterfragt'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: p.fg, width: 3)),
              color: p.faint,
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
            ),
            child: Text(t.critique, style: T.quote(p.fg, size: 17)),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              if (prev != null) Expanded(child: _NavTile(t: prev, back: true)) else const Expanded(child: SizedBox()),
              const SizedBox(width: 10),
              if (next != null) Expanded(child: _NavTile(t: next, back: false)) else const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final Technique t;
  final bool back;
  const _NavTile({required this.t, required this.back});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Tile(
      onTap: () => Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => TechniqueScreen(nr: t.nr),
          transitionsBuilder: (_, a, _, child) => SlideTransition(
            position: Tween(
              begin: Offset(back ? -1 : 1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: back ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(back ? '← ${t.nrLabel}' : '${t.nrLabel} →', style: T.num(p.muted, size: 12)),
          const SizedBox(height: 6),
          Text(
            t.title,
            style: T.h2(p.fg).copyWith(fontSize: 15),
            textAlign: back ? TextAlign.left : TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
