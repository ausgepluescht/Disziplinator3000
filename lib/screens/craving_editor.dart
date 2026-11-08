import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Öffnet den Editor. Liefert die ID der gespeicherten Kategorie,
/// oder null, wenn abgebrochen oder gelöscht wurde.
Future<String?> editCraving(BuildContext context, {Craving? existing}) =>
    Navigator.of(context).push<String>(MaterialPageRoute(builder: (_) => CravingEditorScreen(existing: existing)));

/// Eigene Kategorie für „Was lockt dich gerade?“ anlegen oder bearbeiten.
class CravingEditorScreen extends StatefulWidget {
  final Craving? existing;
  const CravingEditorScreen({super.key, this.existing});

  @override
  State<CravingEditorScreen> createState() => _CravingEditorScreenState();
}

class _CravingEditorScreenState extends State<CravingEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _remove;
  late final TextEditingController _abstract;
  late final TextEditingController _disgust;
  late final TextEditingController _alts;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    String lines(List<String>? l) => (l ?? const []).join('\n');
    _name = TextEditingController(text: e?.label ?? '');
    _remove = TextEditingController(text: lines(e?.removeTrigger));
    _abstract = TextEditingController(text: lines(e?.abstract));
    _disgust = TextEditingController(text: lines(e?.disgust));
    _alts = TextEditingController(text: lines(e?.alternatives));
  }

  @override
  void dispose() {
    for (final c in [_name, _remove, _abstract, _disgust, _alts]) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> _split(TextEditingController c) =>
      c.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      toast(context, 'Gib der Kategorie einen Namen.');
      return;
    }
    final id = widget.existing?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}';
    context.readStore.saveCustomCraving(
      Craving(
        id: id,
        label: name,
        icon: Icons.label_outline_rounded,
        removeTrigger: _split(_remove),
        abstract: _split(_abstract),
        disgust: _split(_disgust),
        alternatives: _split(_alts),
        custom: true,
      ),
    );
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(id);
  }

  Future<void> _delete() async {
    final p = context.c;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('„${widget.existing!.label}“ löschen?', style: T.h2(p.fg)),
        content: Text(
          'Einträge im Protokoll bleiben erhalten und erscheinen dann unter „Etwas anderes“.',
          style: T.body(p.fg),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Abbrechen')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Löschen')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    context.readStore.deleteCustomCraving(widget.existing!.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final editing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'KATEGORIE BEARBEITEN' : 'EIGENE KATEGORIE')),
      body: ActionBody(
        actions: [
          PrimaryButton(
            editing ? 'Änderungen speichern' : 'Kategorie anlegen',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
          if (editing) GhostButton('Kategorie löschen', icon: Icons.delete_outline_rounded, onPressed: _delete),
        ],
        children: [
          PageHead(
            title: editing ? widget.existing!.label : 'Was lockt dich noch?',
            motto: 'Je konkreter du es beschreibst, desto besser helfen dir die Impulse.',
          ),
          const SizedBox(height: 22),
          Text('Wie heißt es?', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            autofocus: !editing,
            style: T.h2(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Zum Beispiel: Nachts Essen bestellen'),
          ),
          const SizedBox(height: 8),
          Text(
            'Alles Weitere ist freiwillig. Schreib pro Zeile einen Eintrag. Leere Felder füllt die App mit allgemeinen Vorschlägen auf.',
            style: T.small(p.muted),
          ),
          const SectionHeader('Auslöser weg'),
          AskField(
            question: 'Was räumst du sofort aus dem Weg, wenn es dich packt?',
            hint: 'App löschen\nKarte aus dem Portemonnaie nehmen',
            controller: _remove,
            minLines: 3,
          ),
          const SectionHeader('02 · Abstrakt machen'),
          AskField(
            question: 'Wie beschreibst du es ganz nüchtern?',
            hint: 'Es ist eigentlich nur …',
            controller: _abstract,
            minLines: 3,
          ),
          const SectionHeader('03 · Eklig machen'),
          AskField(
            question: 'Welches Bild verdirbt dir die Lust darauf?',
            hint: 'Stell dir vor …',
            controller: _disgust,
            minLines: 3,
          ),
          const SectionHeader('09 · Bessere Optionen'),
          AskField(
            question: 'Was machst du stattdessen? Sofort verfügbar, ohne Kosten.',
            hint: 'Eine Runde um den Block\nSchwester anrufen',
            controller: _alts,
            minLines: 3,
          ),
        ],
      ),
    );
  }
}
