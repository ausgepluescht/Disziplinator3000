import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets/ui.dart';

class _Member {
  final String name;
  final String when;
  final IconData icon;
  final String question;
  final TextEditingController c = TextEditingController();
  bool? vote;
  _Member(this.name, this.when, this.icon, this.question);
}

/// Technik 6: Jedes Ich bekommt eine Stimme.
class CouncilScreen extends StatefulWidget {
  const CouncilScreen({super.key});

  @override
  State<CouncilScreen> createState() => _CouncilScreenState();
}

class _CouncilScreenState extends State<CouncilScreen> {
  final _q = TextEditingController();
  final _members = [
    _Member(
      'Jetzt-Ich',
      'in diesem Moment',
      Icons.bolt_outlined,
      'Was will ich gerade wirklich? Und warum so dringend?',
    ),
    _Member(
      'Heute-Abend-Ich',
      'in ein paar Stunden',
      Icons.nightlight_outlined,
      'Wie geht es mir heute Abend mit dieser Entscheidung? Stolz oder genervt?',
    ),
    _Member(
      'Zukunfts-Ich',
      'in einem Jahr',
      Icons.trending_up_rounded,
      'Wenn ich das jeden Tag so entscheide: Wo stehe ich in einem Jahr?',
    ),
    _Member(
      '80-jähriges Ich',
      'auf dem Sterbebett',
      Icons.hourglass_bottom_rounded,
      'Wird mir dieser Moment im Rückblick egal sein, oder war er ein Baustein?',
    ),
    _Member(
      'Der Hamster',
      'dein kleiner Kumpel',
      Icons.pets_outlined,
      'Was braucht der Hamster eigentlich? Ruhe, Wärme, Zucker, Bestätigung? Geht das auch anders?',
    ),
  ];

  @override
  void dispose() {
    _q.dispose();
    for (final m in _members) {
      m.c.dispose();
    }
    super.dispose();
  }

  int get _yes => _members.where((m) => m.vote == true).length;
  int get _no => _members.where((m) => m.vote == false).length;
  bool get _complete => _members.every((m) => m.vote != null);

  String get _verdict {
    if (!_complete) return 'Noch ${_members.where((m) => m.vote == null).length} Stimmen offen.';
    if (_yes == _no) return 'Unentschieden.';
    return _yes > _no ? 'Der Rat sagt Ja, $_yes zu $_no.' : 'Der Rat sagt Nein, $_no zu $_yes.';
  }

  void _save() {
    context.readStore.addDecision(
      Decision(
        at: DateTime.now(),
        kind: 'council',
        question: _q.text.trim().isEmpty ? 'Ratssitzung' : _q.text.trim(),
        verdict: _verdict,
        data: {
          for (final m in _members) m.name: {'vote': m.vote, 'note': m.c.text},
        },
      ),
    );
    HapticFeedback.mediumImpact();
    toast(context, 'Beschluss gespeichert.');
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Scaffold(
      appBar: AppBar(title: const Text('06 · RAT DER ICHS')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          const PageHead(title: 'Der Rat tagt.', motto: 'Jeder bekommt eine Stimme. Auch der Hamster.'),
          const SizedBox(height: 20),
          TextField(
            controller: _q,
            style: T.h2(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Worüber stimmt der Rat ab? Gehe ich jetzt laufen?'),
          ),
          const SizedBox(height: 20),
          for (final m in _members) ...[
            _MemberCard(member: m, onChanged: () => setState(() {})),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: p.inverseBg, borderRadius: BorderRadius.circular(18)),
            child: Row(
              children: [
                Text('$_yes:$_no', style: T.num(p.inverseFg, size: 34)),
                const SizedBox(width: 18),
                Expanded(child: Text(_verdict, style: T.quote(p.inverseFg, size: 18))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton('Beschluss speichern', icon: Icons.gavel_rounded, onPressed: _complete ? _save : null),
          const SizedBox(height: 14),
          Text(
            'Wenn das Jetzt-Ich und der Hamster allein gegen alle anderen stehen, ist die Sache meistens klar.',
            style: T.small(p.muted),
          ),
        ],
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  final _Member member;
  final VoidCallback onChanged;
  const _MemberCard({required this.member, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    Widget vote(String text, bool v) {
      final sel = member.vote == v;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            member.vote = v;
            onChanged();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? p.fg : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: sel ? p.fg : p.line),
            ),
            child: Text(text, style: T.small(sel ? p.inverseFg : p.fg).copyWith(fontWeight: FontWeight.w700)),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: member.vote == null ? p.line : p.fg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(member.icon, size: 20, color: p.fg),
              const SizedBox(width: 10),
              Text(member.name, style: T.h2(p.fg).copyWith(fontSize: 16)),
              const Spacer(),
              Label(member.when),
            ],
          ),
          const SizedBox(height: 10),
          Text(member.question, style: T.quote(p.fg, size: 17)),
          TextField(
            controller: member.c,
            minLines: 1,
            maxLines: null,
            style: T.body(p.fg),
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Stimme dieses Ichs …',
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
          Row(children: [vote('Ja', true), const SizedBox(width: 8), vote('Nein', false)]),
        ],
      ),
    );
  }
}
