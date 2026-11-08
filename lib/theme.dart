import 'package:flutter/material.dart';

/// Schwarz-Weiß-Palette. Hell und dunkel sind exakt gespiegelt.
class Palette {
  final Color bg;
  final Color surface;
  final Color fg;
  final Color muted;
  final Color faint;
  final Color line;
  final Color inverseBg;
  final Color inverseFg;
  final Color inverseMuted;

  const Palette({
    required this.bg,
    required this.surface,
    required this.fg,
    required this.muted,
    required this.faint,
    required this.line,
    required this.inverseBg,
    required this.inverseFg,
    required this.inverseMuted,
  });

  static const light = Palette(
    bg: Color(0xFFFAFAFA),
    surface: Color(0xFFFFFFFF),
    fg: Color(0xFF0A0A0A),
    muted: Color(0xFF5E5E5E),
    faint: Color(0xFFEDEDED),
    line: Color(0xFFDADADA),
    inverseBg: Color(0xFF0A0A0A),
    inverseFg: Color(0xFFFFFFFF),
    inverseMuted: Color(0xFFA8A8A8),
  );

  static const dark = Palette(
    bg: Color(0xFF000000),
    surface: Color(0xFF0E0E0E),
    fg: Color(0xFFF5F5F5),
    muted: Color(0xFFA3A3A3),
    faint: Color(0xFF1C1C1C),
    line: Color(0xFF2E2E2E),
    inverseBg: Color(0xFFF5F5F5),
    inverseFg: Color(0xFF0A0A0A),
    inverseMuted: Color(0xFF5E5E5E),
  );
}

extension PaletteX on BuildContext {
  Palette get c => Theme.of(this).brightness == Brightness.dark ? Palette.dark : Palette.light;
}

/// Drei Schriften, drei Rollen:
/// Inter für Struktur, Lora kursiv für Fragen und Gedanken,
/// JetBrains Mono für Nummern, Zeiten und Etiketten.
class T {
  static const sans = 'Inter';
  static const serif = 'Lora';
  static const mono = 'JetBrainsMono';

  static TextStyle display(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.08,
    letterSpacing: -1.1,
    color: c,
  );

  static TextStyle h1(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.6,
    color: c,
  );

  static TextStyle h2(Color c) => TextStyle(
    fontFamily: sans,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.3,
    color: c,
  );

  static TextStyle body(Color c) =>
      TextStyle(fontFamily: sans, fontSize: 15, fontWeight: FontWeight.w400, height: 1.5, color: c);

  static TextStyle small(Color c) =>
      TextStyle(fontFamily: sans, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4, color: c);

  static TextStyle quote(Color c, {double size = 22}) => TextStyle(
    fontFamily: serif,
    fontStyle: FontStyle.italic,
    fontSize: size,
    fontWeight: FontWeight.w500,
    height: 1.35,
    color: c,
  );

  static TextStyle label(Color c) =>
      TextStyle(fontFamily: mono, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.4, height: 1.2, color: c);

  static TextStyle num(Color c, {double size = 14}) =>
      TextStyle(fontFamily: mono, fontSize: size, fontWeight: FontWeight.w600, height: 1.1, color: c);
}

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Palette.dark : Palette.light;
  final scheme = ColorScheme(
    brightness: b,
    primary: p.fg,
    onPrimary: p.inverseFg,
    secondary: p.fg,
    onSecondary: p.inverseFg,
    error: p.fg,
    onError: p.inverseFg,
    surface: p.surface,
    onSurface: p.fg,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    fontFamily: T.sans,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.fg,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: T.label(p.fg),
    ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    sliderTheme: SliderThemeData(
      activeTrackColor: p.fg,
      inactiveTrackColor: p.line,
      thumbColor: p.fg,
      overlayColor: p.fg.withValues(alpha: 0.08),
      trackHeight: 2,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      hintStyle: T.body(p.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: p.fg, width: 1.5),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.fg,
      selectionColor: p.fg.withValues(alpha: 0.2),
      selectionHandleColor: p.fg,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: p.inverseBg,
      contentTextStyle: T.small(p.inverseFg),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: p.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}
