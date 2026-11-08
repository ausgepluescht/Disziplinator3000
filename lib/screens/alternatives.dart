import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/cravings.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

Future<void> callBuddy(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone.replaceAll(RegExp(r'[^\d+]'), ''));
  if (!await launchUrl(uri) && context.mounted) toast(context, 'Anruf konnte nicht gestartet werden.');
}

Future<void> textBuddy(BuildContext context, String phone) async {
  final uri = Uri(
    scheme: 'sms',
    path: phone.replaceAll(RegExp(r'[^\d+]'), ''),
    queryParameters: {'body': 'Hey, ich kämpfe gerade mit mir. Hast du zwei Minuten für mich?'},
  );
  if (!await launchUrl(uri) && context.mounted) toast(context, 'SMS konnte nicht geöffnet werden.');
}

/// Zeigt eine Alternative groß an.
Future<void> showAlternative(BuildContext context, String alt) {
  return showModalBottomSheet(
    context: context,
    builder: (ctx) {
      final p = ctx.c;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Label('09 · Deine bessere Option'),
              const SizedBox(height: 14),
              Text(alt, style: T.h1(p.fg)),
              const SizedBox(height: 10),
              Text(
                'Sofort. Ohne Verhandlung. Die Alternative gewinnt nur, wenn sie schneller ist.',
                style: T.quote(p.muted, size: 17),
              ),
              const SizedBox(height: 24),
              PrimaryButton('Mach ich', icon: Icons.check_rounded, onPressed: () => Navigator.of(ctx).pop()),
            ],
          ),
        ),
      );
    },
  );
}

class AlternativesScreen extends StatefulWidget {
  final String? craving;
  const AlternativesScreen({super.key, this.craving});

  @override
  State<AlternativesScreen> createState() => _AlternativesScreenState();
}

class _AlternativesScreenState extends State<AlternativesScreen> {
  late final TextEditingController _bName;
  late final TextEditingController _bPhone;
  final _new = TextEditingController();
  late String _cat = widget.craving ?? cravings.first.id;

  @override
  void initState() {
    super.initState();
    final s = context.readStore;
    _bName = TextEditingController(text: s.buddyName);
    _bPhone = TextEditingController(text: s.buddyPhone);
  }

  @override
  void dispose() {
    _bName.dispose();
    _bPhone.dispose();
    _new.dispose();
    super.dispose();
  }

  void _add(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    final s = context.readStore;
    if (s.alternatives.contains(t)) return;
    s.update((s) => s.alternatives.add(t));
    _new.clear();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final suggestions = cravingById(_cat).alternatives.where((a) => !s.alternatives.contains(a)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('09 · BESSERE OPTIONEN')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(
            title: 'Schaff dir bessere Optionen.',
            motto: 'Sofort verfügbar. Kostet nichts. Sonst gewinnt das Handy.',
          ),

          // Buddy ---------------------------------------------------------
          const SectionHeader('Dein Buddy'),
          Text(
            'Wen darfst du jederzeit anrufen, wenn es brenzlig wird? Schließt einen Pakt.',
            style: T.quote(p.fg, size: 18),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bName,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Name'),
            onChanged: (v) => s.update((s) => s.buddyName = v.trim()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bPhone,
            style: T.body(p.fg),
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Telefonnummer'),
            onChanged: (v) => s.update((s) => s.buddyPhone = v.trim()),
          ),
          if (s.buddyPhone.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    'Anrufen',
                    icon: Icons.call_outlined,
                    onPressed: () => callBuddy(context, s.buddyPhone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GhostButton(
                    'SMS',
                    icon: Icons.sms_outlined,
                    onPressed: () => textBuddy(context, s.buddyPhone),
                  ),
                ),
              ],
            ),
          ],

          // Eigene Alternativen ---------------------------------------------
          SectionHeader(
            'Deine Alternativen',
            trailing: Text('${s.alternatives.length}', style: T.num(p.muted, size: 12)),
          ),
          if (s.alternatives.isEmpty)
            Text('Noch keine. Bau dir eine Liste mit Dingen, die griffbereit sind.', style: T.body(p.muted)),
          for (final a in s.alternatives)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tile(
                padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                radius: 12,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(a, style: T.body(p.fg).copyWith(fontWeight: FontWeight.w500)),
                    ),
                    IconButton(
                      tooltip: 'Entfernen',
                      onPressed: () => s.update((s) => s.alternatives.remove(a)),
                      icon: Icon(Icons.close_rounded, size: 18, color: p.muted),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _new,
                  style: T.body(p.fg),
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Neue Alternative'),
                  onSubmitted: _add,
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () => _add(_new.text),
                style: IconButton.styleFrom(backgroundColor: p.fg, foregroundColor: p.inverseFg),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GhostButton(
            'Zufällige Alternative ziehen',
            icon: Icons.casino_outlined,
            onPressed: () {
              final pool = s.alternatives.isNotEmpty ? s.alternatives : cravingById(_cat).alternatives;
              showAlternative(context, pool[Random().nextInt(pool.length)]);
            },
          ),

          // Vorschläge ----------------------------------------------------
          const SectionHeader('Vorschläge'),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in cravings)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Pill(c.label, selected: c.id == _cat, onTap: () => setState(() => _cat = c.id)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (suggestions.isEmpty) Text('Alle übernommen.', style: T.small(p.muted)),
          for (final a in suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Tile(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                radius: 12,
                onTap: () => _add(a),
                child: Row(
                  children: [
                    Expanded(child: Text(a, style: T.body(p.fg))),
                    Icon(Icons.add_rounded, size: 18, color: p.fg),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            'Prüf jede Alternative kritisch: Erreichst du sie in 10 Sekunden? Kostet sie nichts? Die abhängigen Ratten griffen sofort wieder zur Droge, sobald sich die Tür zum Artgenossen erst zwei Minuten später öffnete.',
            style: T.small(p.muted),
          ),
        ],
      ),
    );
  }
}
