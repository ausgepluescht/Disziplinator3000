import 'package:flutter/material.dart';

import '../data/cravings.dart';
import '../data/impulses.dart';
import '../data/techniques.dart';
import '../nav.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/swipe_deck.dart';
import '../widgets/ui.dart';
import 'alternatives.dart';
import 'log.dart';
import 'sos.dart';
import 'why.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 5) return 'Spät geworden.';
    if (h < 11) return 'Guten Morgen.';
    if (h < 17) return 'Hallo.';
    if (h < 21) return 'Guten Abend.';
    return 'Schon spät.';
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            // Kopf -------------------------------------------------------
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: p.fg, borderRadius: BorderRadius.circular(6)),
                  child: Text('D3K', style: T.num(p.inverseFg, size: 12)),
                ),
                const SizedBox(width: 10),
                Expanded(child: Label('Disziplinator 3000', color: p.fg)),
                IconButton(
                  tooltip: 'Protokoll',
                  onPressed: () => go(context, const LogScreen()),
                  icon: const Icon(Icons.insights_outlined),
                ),
                IconButton(
                  tooltip: 'Einstellungen',
                  onPressed: () => showSettings(context),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(_greeting(), style: T.quote(p.muted, size: 20)),
            const SizedBox(height: 4),
            Text('Was lockt dich gerade?', style: T.display(p.fg)),
            const SizedBox(height: 20),

            // Akut -------------------------------------------------------
            Tile(
              inverted: true,
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
              onTap: () => go(context, const SosScreen()),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Label('Akut-Modus', color: p.inverseMuted),
                        const SizedBox(height: 8),
                        Text('Ich werde gerade schwach.', style: T.h1(p.inverseFg)),
                        const SizedBox(height: 6),
                        Text('Vier geführte Schritte, etwa zwei Minuten.', style: T.small(p.inverseMuted)),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: p.inverseFg, shape: BoxShape.circle),
                    child: Icon(Icons.arrow_forward_rounded, color: p.inverseBg),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cravings.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final c = cravings[i];
                  return Pill(
                    c.label,
                    icon: c.icon,
                    onTap: () => go(context, SosScreen(craving: c.id)),
                  );
                },
              ),
            ),

            // Impuls -----------------------------------------------------
            const SectionHeader('Impulse zum Hinterfragen'),
            SwipeDeck(builder: () => buildDeck(s), height: 290, onOpenTech: (nr) => openTechnique(context, nr)),
            const SizedBox(height: 8),
            Center(child: Text('Nach links wischen: weiter. Nach rechts: merken.', style: T.small(p.muted))),

            // Techniken --------------------------------------------------
            SectionHeader('10 Techniken', trailing: Text('${techniques.length}', style: T.num(p.muted, size: 12))),
            _TechniqueGrid(),

            // Persönlich -------------------------------------------------
            const SectionHeader('Persönlich'),
            _WhyTile(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SmallTile(
                    icon: Icons.call_outlined,
                    title: s.buddyName.isEmpty ? 'Buddy' : s.buddyName,
                    sub: s.buddyPhone.isEmpty ? 'Noch nicht hinterlegt' : 'Jetzt anrufen',
                    onTap: () => s.buddyPhone.isEmpty
                        ? go(context, const AlternativesScreen())
                        : callBuddy(context, s.buddyPhone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SmallTile(
                    icon: Icons.casino_outlined,
                    title: 'Alternativen',
                    sub: s.alternatives.isEmpty ? 'Noch keine eigenen' : '${s.alternatives.length} griffbereit',
                    onTap: () => go(context, const AlternativesScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SmallTile(
                    icon: Icons.bookmark_border_rounded,
                    title: 'Gemerkt',
                    sub: '${s.saved.length} Impulse',
                    onTap: () => go(context, const SavedScreen()),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SmallTile(
                    icon: Icons.insights_outlined,
                    title: 'Protokoll',
                    sub: '${s.logs.length} Momente',
                    onTap: () => go(context, const LogScreen()),
                  ),
                ),
              ],
            ),

            // Bilanz -----------------------------------------------------
            const SectionHeader('Bilanz'),
            _Stats(),
            const SizedBox(height: 28),
            Center(child: Text('Kein Login. Alles bleibt auf diesem Gerät.', style: T.small(p.muted))),
          ],
        ),
      ),
    );
  }
}

class _TechniqueGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < techniques.length; i += 2) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _TechTile(t: techniques[i])),
              const SizedBox(width: 10),
              Expanded(child: i + 1 < techniques.length ? _TechTile(t: techniques[i + 1]) : const SizedBox()),
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }
}

class _TechTile extends StatelessWidget {
  final Technique t;
  const _TechTile({required this.t});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Tile(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      onTap: () => openTechnique(context, t.nr),
      onLongPress: t.tool == null ? null : () => openTool(context, t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(t.nrLabel, style: T.num(p.fg, size: 22)),
              const Spacer(),
              Icon(Icons.north_east_rounded, size: 16, color: p.muted),
            ],
          ),
          const SizedBox(height: 14),
          Text(t.title, style: T.h2(p.fg).copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(t.motto, style: T.quote(p.muted, size: 14)),
        ],
      ),
    );
  }
}

class _WhyTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final why = context.store.why.trim();
    final has = why.isNotEmpty;
    return Tile(
      padding: const EdgeInsets.all(18),
      onTap: () => go(context, const WhyScreen()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('07', style: T.num(p.fg, size: 13)),
              const SizedBox(width: 8),
              Label('Dein Warum'),
              const Spacer(),
              Icon(has ? Icons.menu_book_outlined : Icons.edit_outlined, size: 18, color: p.fg),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            has
                ? why
                : 'Noch kein Brief an dich selbst. Schreib auf, wofür du das alles machst. Das ist dein Treibstoff.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: T.quote(has ? p.fg : p.muted, size: 18),
          ),
        ],
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _SmallTile({required this.icon, required this.title, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Tile(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: p.fg),
          const SizedBox(height: 14),
          Text(title, style: T.h2(p.fg).copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(sub, style: T.small(p.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    Widget cell(String n, String l) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(n, style: T.num(p.fg, size: 30)),
          const SizedBox(height: 6),
          Label(l),
        ],
      ),
    );
    return Tile(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      onTap: () => go(context, const LogScreen()),
      child: Row(
        children: [
          cell('${s.resistedCount}', 'Widerstanden'),
          Container(width: 1, height: 44, color: p.line, margin: const EdgeInsets.only(right: 14)),
          cell('${s.gaveInCount}', 'Nachgegeben'),
          Container(width: 1, height: 44, color: p.line, margin: const EdgeInsets.only(right: 14)),
          cell('${s.streak}', 'Tage in Folge'),
        ],
      ),
    );
  }
}
