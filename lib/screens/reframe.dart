import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cravings.dart';
import '../data/techniques.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

/// Technik 2 (abstrakt) und 3 (eklig): Bilder je Verlangen, zum Durchtippen,
/// plus eigene Formulierung.
class ReframeScreen extends StatefulWidget {
  final int tech;
  final String? craving;
  const ReframeScreen({super.key, required this.tech, this.craving});

  @override
  State<ReframeScreen> createState() => _ReframeScreenState();
}

class _ReframeScreenState extends State<ReframeScreen> {
  late String _craving = widget.craving ?? cravings.first.id;
  int _i = 0;
  final _own = TextEditingController();

  @override
  void dispose() {
    _own.dispose();
    super.dispose();
  }

  List<String> get _lines {
    final c = cravingById(_craving);
    return widget.tech == 2 ? c.abstract : c.disgust;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final t = techniqueByNr(widget.tech);
    final lines = _lines;
    final line = lines[_i % lines.length];
    final abstract = widget.tech == 2;

    return Scaffold(
      appBar: AppBar(title: Text('${t.nrLabel} · ${t.title.toUpperCase()}')),
      body: ActionBody(
        actions: [
          PrimaryButton(
            'Eigene Version merken',
            icon: Icons.bookmark_add_outlined,
            onPressed: () {
              final txt = _own.text.trim();
              if (txt.isEmpty) {
                toast(context, 'Schreib erst deine eigene Version unten auf.');
                return;
              }
              final s = context.readStore;
              if (!s.isSaved(txt)) s.toggleSaved(txt);
              _own.clear();
              FocusScope.of(context).unfocus();
              toast(context, 'Gemerkt. Du findest es unter „Gemerkt“.');
            },
          ),
        ],
        children: [
          PageHead(
            title: abstract ? 'Zieh den Glanz ab.' : 'Ekel schlägt Gier.',
            motto: abstract
                ? 'Was bleibt, wenn das Versprechen wegfällt?'
                : 'Stell es dir vor. Lebhaft. Mit allen Sinnen.',
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in cravings)
                Pill(
                  c.label,
                  icon: c.icon,
                  selected: c.id == _craving,
                  onTap: () => setState(() {
                    _craving = c.id;
                    _i = 0;
                  }),
                ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _i++);
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey('$_craving$_i'),
                constraints: const BoxConstraints(minHeight: 220),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: p.inverseBg, borderRadius: BorderRadius.circular(22)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('${(_i % lines.length) + 1}/${lines.length}', style: T.num(p.inverseMuted, size: 12)),
                        const Spacer(),
                        Label('Tippen für das nächste', color: p.inverseMuted),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(line, style: T.quote(p.inverseFg, size: 22)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                context.readStore.toggleSaved(line);
                toast(context, context.readStore.isSaved(line) ? 'Gemerkt.' : 'Entfernt.');
              },
              icon: Icon(
                context.store.isSaved(line) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: p.fg,
              ),
              label: Text('Merken', style: T.small(p.fg)),
            ),
          ),
          const SectionHeader('Deine eigene Version'),
          AskField(
            question: abstract
                ? 'Beschreib, was dich gerade lockt, so nüchtern wie in einem Laborbericht.'
                : 'Welches Bild verdirbt dir die Lust am zuverlässigsten?',
            hint: abstract ? 'Es ist eigentlich nur …' : 'Stell dir vor …',
            controller: _own,
            minLines: 3,
          ),
          if (!abstract) ...[const SizedBox(height: 22), Text(t.critique, style: T.small(p.muted))],
        ],
      ),
    );
  }
}
