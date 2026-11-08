import 'package:flutter/material.dart';

import '../data/techniques.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Technik 4: Name und Alter Ego festlegen, Solomon-Modus.
class DistanceScreen extends StatefulWidget {
  const DistanceScreen({super.key});

  @override
  State<DistanceScreen> createState() => _DistanceScreenState();
}

class _DistanceScreenState extends State<DistanceScreen> {
  late final TextEditingController _name;
  late final TextEditingController _ego;
  final _friend = TextEditingController();
  final _advice = TextEditingController();

  static const _egos = ['Batman', 'Wonder Woman', 'Mein bestes Ich', 'Ein Stoiker', 'Ein Profisportler'];

  @override
  void initState() {
    super.initState();
    final s = context.readStore;
    _name = TextEditingController(text: s.name);
    _ego = TextEditingController(text: s.alterEgo);
  }

  @override
  void dispose() {
    _name.dispose();
    _ego.dispose();
    _friend.dispose();
    _advice.dispose();
    super.dispose();
  }

  void _saveIdentity() {
    context.readStore.update((s) {
      s.name = _name.text.trim();
      s.alterEgo = _ego.text.trim().isEmpty ? 'Batman' : _ego.text.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final s = context.store;
    final t = techniqueByNr(4);

    return Scaffold(
      appBar: AppBar(title: const Text('04 · BATMAN-TECHNIK')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(
            title: 'Geh auf Abstand.',
            motto: 'Bei anderen sehen wir klar. Bei uns selbst stehen wir uns im Weg.',
          ),
          const SectionHeader('Dritte Person'),
          Text('Wie sollen dich die Impulse ansprechen?', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _name,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(hintText: 'Dein Vorname'),
            onChanged: (_) => _saveIdentity(),
          ),
          const SizedBox(height: 22),
          Text('Wer ist dein Alter Ego?', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in _egos)
                Pill(
                  e,
                  selected: s.alterEgo == e,
                  onTap: () {
                    _ego.text = e;
                    _saveIdentity();
                  },
                ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ego,
            style: T.body(p.fg),
            decoration: const InputDecoration(hintText: 'Oder eigenes Vorbild'),
            onChanged: (_) => _saveIdentity(),
          ),
          const SizedBox(height: 20),
          Label('So klingt das'),
          const SizedBox(height: 10),
          for (final q in t.prompts.where((q) => q.contains('{')))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('—', style: T.quote(p.muted, size: 18)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(s.fill(q), style: T.quote(p.fg, size: 18))),
                ],
              ),
            ),
          const SectionHeader('Solomon-Modus'),
          Text('Beschreib die Situation, als wäre es die eines guten Freundes.', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _friend,
            minLines: 3,
            maxLines: null,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Mein Freund sitzt gerade auf dem Sofa und will …'),
          ),
          const SizedBox(height: 18),
          Text('Was rätst du ihm? Ehrlich und freundlich.', style: T.quote(p.fg, size: 18)),
          const SizedBox(height: 10),
          TextField(
            controller: _advice,
            minLines: 3,
            maxLines: null,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Ich würde ihm sagen …'),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            'Rat als Impuls merken',
            icon: Icons.bookmark_add_outlined,
            onPressed: () {
              final a = _advice.text.trim();
              if (a.isEmpty) return;
              final st = context.readStore;
              if (!st.isSaved(a)) st.toggleSaved(a);
              FocusScope.of(context).unfocus();
              toast(context, 'Gemerkt. Jetzt gilt der Rat auch für dich.');
            },
          ),
        ],
      ),
    );
  }
}
