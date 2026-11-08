import 'package:flutter/material.dart';

import 'data/techniques.dart';
import 'screens/alternatives.dart';
import 'screens/audit.dart';
import 'screens/council.dart';
import 'screens/distance.dart';
import 'screens/reframe.dart';
import 'screens/seesaw.dart';
import 'screens/sprint.dart';
import 'screens/surf.dart';
import 'screens/technique.dart';
import 'screens/why.dart';

Future<T?> go<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));

Future<void> openTechnique(BuildContext context, int nr) => go(context, TechniqueScreen(nr: nr));

/// Öffnet das Werkzeug einer Technik. Liefert true, wenn es benutzt wurde.
Future<bool?> openTool(BuildContext context, Technique t, {String? craving}) {
  final page = switch (t.tool) {
    Tool.surf => const SurfScreen(),
    Tool.reframe => ReframeScreen(tech: t.nr, craving: craving),
    Tool.distance => const DistanceScreen(),
    Tool.seesaw => const SeesawScreen(),
    Tool.council => const CouncilScreen(),
    Tool.why => const WhyScreen(),
    Tool.sprint => SprintScreen(craving: craving),
    Tool.alternatives => AlternativesScreen(craving: craving),
    Tool.audit => AuditScreen(craving: craving),
    null => TechniqueScreen(nr: t.nr),
  };
  return go<bool>(context, page);
}
