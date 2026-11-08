import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// Kleine Etikette in Mono-Versalien.
class Label extends StatelessWidget {
  final String text;
  final Color? color;
  const Label(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: T.label(color ?? context.c.muted), maxLines: 2, overflow: TextOverflow.ellipsis);
}

/// Abschnittskopf mit Linie.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 12),
      child: Row(
        children: [
          Label(title, color: context.c.fg),
          const SizedBox(width: 12),
          Expanded(child: Container(height: 1, color: context.c.line)),
          if (trailing != null) ...[const SizedBox(width: 12), Flexible(child: trailing!)],
        ],
      ),
    );
  }
}

/// Kachel: weiß mit feiner Linie, oder invertiert (schwarz).
class Tile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool inverted;
  final EdgeInsets padding;
  final double radius;

  const Tile({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.inverted = false,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Material(
      color: inverted ? p.inverseBg : p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: inverted ? BorderSide.none : BorderSide(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        onLongPress: onLongPress,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Hauptknopf: schwarz gefüllt (bzw. weiß im Dunkelmodus).
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  const PrimaryButton(this.text, {super.key, this.onPressed, this.icon, this.expand = true});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final btn = FilledButton(
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      style: FilledButton.styleFrom(
        backgroundColor: p.fg,
        foregroundColor: p.inverseFg,
        disabledBackgroundColor: p.faint,
        disabledForegroundColor: p.muted,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: T.sans, fontSize: 15, fontWeight: FontWeight.w700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Zweitknopf: nur Umriss.
class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  const GhostButton(this.text, {super.key, this.onPressed, this.icon, this.expand = true});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    final btn = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: p.fg,
        side: BorderSide(color: p.fg, width: 1.2),
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: T.sans, fontSize: 15, fontWeight: FontWeight.w600),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

/// Auswahl-Chip im Schwarz-Weiß-Stil.
class Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  const Pill(this.text, {super.key, this.selected = false, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Material(
      color: selected ? p.fg : p.surface,
      shape: StadiumBorder(side: BorderSide(color: selected ? p.fg : p.line)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: selected ? p.inverseFg : p.fg),
                const SizedBox(width: 6),
              ],
              Text(
                text,
                style: T
                    .small(selected ? p.inverseFg : p.fg)
                    .copyWith(fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skala 0 bis 10 zum Antippen.
class ScaleRow extends StatelessWidget {
  final int? value;
  final ValueChanged<int> onChanged;
  const ScaleRow({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(11, (i) {
            final sel = value == i;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    color: sel ? p.fg : (value != null && i < value! ? p.faint : p.surface),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: sel ? p.fg : p.line),
                  ),
                  alignment: Alignment.center,
                  child: Text('$i', style: T.num(sel ? p.inverseFg : p.fg, size: 13)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Label('kaum'), Label('übermächtig')]),
      ],
    );
  }
}

/// Einheitlicher Seitenkopf: Nummer in Mono, Titel in Inter, Motto in Lora.
class PageHead extends StatelessWidget {
  final String? kicker;
  final String title;
  final String? motto;
  const PageHead({super.key, this.kicker, required this.title, this.motto});

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kicker != null) ...[Label(kicker!), const SizedBox(height: 10)],
        Text(title, style: T.display(p.fg)),
        if (motto != null) ...[const SizedBox(height: 10), Text(motto!, style: T.quote(p.muted, size: 19))],
      ],
    );
  }
}

/// Mehrzeiliges Eingabefeld mit Frage in Lora darüber.
class AskField extends StatelessWidget {
  final String question;
  final String? hint;
  final TextEditingController controller;
  final int minLines;
  final ValueChanged<String>? onChanged;
  const AskField({
    super.key,
    required this.question,
    required this.controller,
    this.hint,
    this.minLines = 2,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: T.quote(p.fg, size: 18)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: null,
          onChanged: onChanged,
          textCapitalization: TextCapitalization.sentences,
          style: T.body(p.fg),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

String fmtClock(int seconds) {
  final m = (seconds ~/ 60).toString().padLeft(2, '0');
  final s = (seconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

const _wd = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

String fmtDate(DateTime d) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final hh = d.hour.toString().padLeft(2, '0');
  final mi = d.minute.toString().padLeft(2, '0');
  return '${_wd[d.weekday - 1]} $dd.$mm. · $hh:$mi';
}

void toast(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text), duration: const Duration(milliseconds: 1800)));
}
