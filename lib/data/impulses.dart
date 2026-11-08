import 'dart:math';

import '../store.dart';
import 'cravings.dart';
import 'feelings.dart';
import 'techniques.dart';

/// Eine Karte im Impuls-Stapel.
class Impulse {
  final String text;
  final int tech;

  /// 'frage', 'bild' (Vorstellung), 'warum' (eigener Brief) oder 'gefuehl' (zu deinem Gefühl).
  final String kind;

  const Impulse(this.text, this.tech, {this.kind = 'frage'});
}

/// Baut einen gemischten Stapel. Mit [craving] werden die passenden
/// Bilder aus Technik 2 und 3 ergänzt, mit [tech] nur eine Technik.
List<Impulse> buildDeck(Store s, {String? craving, int? tech, List<String> feelings = const [], Random? rnd}) {
  final r = rnd ?? Random();
  final out = <Impulse>[];

  for (final t in techniques) {
    if (tech != null && t.nr != tech) continue;
    for (final p in t.prompts) {
      // Ohne eingetragenen Namen keine Fragen in der dritten Person.
      if (p.contains('{name}') && s.name.trim().isEmpty) continue;
      out.add(Impulse(s.fill(p), t.nr));
    }
  }

  final pool = craving == null ? cravings : [cravingById(craving)];
  if (tech == null || tech == 2) {
    for (final c in pool) {
      for (final a in c.abstract) {
        out.add(Impulse(a, 2, kind: 'bild'));
      }
    }
  }
  if (tech == null || tech == 3) {
    for (final c in pool) {
      for (final d in c.disgust) {
        out.add(Impulse(d, 3, kind: 'bild'));
      }
    }
  }

  // Eigene Gedanken haben Vorrang: Sätze aus dem Warum-Brief.
  if ((tech == null || tech == 7) && s.why.trim().isNotEmpty) {
    final sentences = s.why
        .split(RegExp(r'(?<=[.!?])\s+|\n+'))
        .map((e) => e.trim())
        .where((e) => e.length > 12)
        .toList();
    for (final w in sentences) {
      out.add(Impulse(w, 7, kind: 'warum'));
    }
  }

  out.shuffle(r);

  // Ohne Filter auf die Technik: Ein Satz aus dem Warum kommt früh.
  if (tech == null) {
    final i = out.indexWhere((e) => e.kind == 'warum');
    if (i > 2) out.insert(1, out.removeAt(i));
  }

  // Fragen zu den Gefühlen, die du gerade benannt hast, kommen zuerst.
  if (tech == null) {
    final own = [for (final id in feelings) ?feelingById(id)];
    own.shuffle(r);
    out.insertAll(0, own.map((f) => Impulse(f.prompt, f.tech, kind: 'gefuehl')));
  }
  return out;
}
