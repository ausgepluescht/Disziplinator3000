import 'package:flutter/material.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

const _guides = [
  'Für wen machst du das? Nenn die Menschen beim Namen.',
  'Beschreib einen ganz konkreten Tag in fünf Jahren, wenn du dranbleibst. Was siehst, hörst, fühlst du?',
  'Was ist der Preis, wenn du so weitermachst wie bisher? Sei schonungslos.',
  'Wovon willst du frei sein?',
  'Was soll man einmal über dich sagen?',
];

/// Technik 7: Brief an dich selbst. Lesemodus in Lora, Schreibmodus mit Leitfragen.
class WhyScreen extends StatefulWidget {
  final bool readFirst;
  const WhyScreen({super.key, this.readFirst = false});

  @override
  State<WhyScreen> createState() => _WhyScreenState();
}

class _WhyScreenState extends State<WhyScreen> {
  late final TextEditingController _c;
  late bool _editing;

  @override
  void initState() {
    super.initState();
    final s = context.readStore;
    _c = TextEditingController(text: s.why);
    _editing = s.why.trim().isEmpty;
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _save() {
    context.readStore.update((s) => s.why = _c.text.trim());
    FocusScope.of(context).unfocus();
    setState(() => _editing = _c.text.trim().isEmpty);
    toast(context, 'Gespeichert.');
  }

  void _insert(String text) {
    final sel = _c.selection;
    final pos = sel.isValid ? sel.start : _c.text.length;
    final before = _c.text.substring(0, pos);
    final pre = before.isEmpty || before.endsWith('\n') ? '' : '\n\n';
    final insert = '$pre$text\n';
    _c.value = TextEditingValue(
      text: before + insert + _c.text.substring(pos),
      selection: TextSelection.collapsed(offset: pos + insert.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;

    return Scaffold(
      appBar: AppBar(
        title: const Text('07 · MEIN WARUM'),
        actions: [
          if (!_editing)
            IconButton(
              tooltip: 'Bearbeiten',
              onPressed: () => setState(() => _editing = true),
              icon: const Icon(Icons.edit_outlined),
            ),
        ],
      ),
      body: _editing ? _edit(context, p, s) : _read(context, p, s),
    );
  }

  Widget _read(BuildContext context, Palette p, Store s) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        Label('Ein Brief an dich, ${s.displayName}'),
        const SizedBox(height: 22),
        Text(s.why, style: T.quote(p.fg, size: 23).copyWith(height: 1.5)),
        const SizedBox(height: 36),
        Container(height: 1, color: p.line),
        const SizedBox(height: 18),
        Text('„Wer ein Warum zum Leben hat, erträgt fast jedes Wie.“', style: T.quote(p.muted, size: 16)),
        const SizedBox(height: 4),
        Label('Friedrich Nietzsche'),
        const SizedBox(height: 30),
        PrimaryButton(
          'Zurück, ich bin bereit',
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  Widget _edit(BuildContext context, Palette p, Store s) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        const PageHead(
          title: 'Dein Raketentreibstoff.',
          motto: 'Schreib es so lebendig, dass du ihm nicht ausweichen kannst.',
        ),
        const SizedBox(height: 18),
        Text(
          'Nicht „Ich will fitter sein“, sondern warum. Wen willst du erleben, was willst du tun können, wovon willst du frei sein? Tipp auf eine Leitfrage, um sie in den Brief zu übernehmen.',
          style: T.body(p.muted),
        ),
        const SizedBox(height: 16),
        for (final g in _guides)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Tile(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              radius: 12,
              onTap: () => _insert(g),
              child: Row(
                children: [
                  Expanded(child: Text(g, style: T.quote(p.fg, size: 16))),
                  const SizedBox(width: 8),
                  Icon(Icons.add_rounded, size: 18, color: p.muted),
                ],
              ),
            ),
          ),
        const SizedBox(height: 14),
        TextField(
          controller: _c,
          minLines: 12,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          style: T.quote(p.fg, size: 18).copyWith(height: 1.5),
          decoration: InputDecoration(hintText: 'Lieber ${s.displayName}, …'),
        ),
        const SizedBox(height: 16),
        PrimaryButton('Brief speichern', icon: Icons.check_rounded, onPressed: _save),
      ],
    );
  }
}
