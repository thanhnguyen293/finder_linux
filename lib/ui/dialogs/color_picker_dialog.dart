import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';

/// Quick picks in the color dialog, roughly the macOS crayon box.
const _presets = [
  Color(0xFF007AFF),
  Color(0xFF5856D6),
  Color(0xFFAF52DE),
  Color(0xFFFF2D55),
  Color(0xFFFF3B30),
  Color(0xFFFF9500),
  Color(0xFFFFCC00),
  Color(0xFF34C759),
  Color(0xFF00C7BE),
  Color(0xFF8E8E93),
  Color(0xFFFFFFFF),
  Color(0xFFF2F2F7),
  Color(0xFFE5E5EA),
  Color(0xFF3A3A3C),
  Color(0xFF1C1C1E),
  Color(0xFF000000),
];

/// `#RRGGBB` for [color] (alpha dropped: theme colors are opaque).
String colorToHex(Color color) =>
    '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// Parses `#RGB`, `#RRGGBB` (the `#` optional); null when malformed.
Color? parseHexColor(String text) {
  var hex = text.trim().replaceFirst('#', '');
  if (hex.length == 3) hex = hex.split('').map((c) => '$c$c').join();
  if (hex.length != 6) return null;
  final value = int.tryParse(hex, radix: 16);
  return value == null ? null : Color(0xFF000000 | value);
}

/// Picks a color: presets, hue / saturation / brightness sliders and a
/// hex field, with a live preview. Null when cancelled.
Future<Color?> showColorPicker(BuildContext context, Color initial) =>
    showDialog<Color>(
      context: context,
      builder: (_) => _ColorPickerDialog(initial: initial),
    );

class _ColorPickerDialog extends StatefulWidget {
  const _ColorPickerDialog({required this.initial});

  final Color initial;

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial);
  late final _hex = TextEditingController(text: colorToHex(widget.initial));

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  void _set(HSVColor hsv, {bool fromHex = false}) {
    setState(() => _hsv = hsv);
    if (!fromHex) _hex.text = colorToHex(hsv.toColor());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final color = _hsv.toColor();
    Widget slider(
      String label,
      double value,
      double max,
      HSVColor Function(double) apply,
    ) => Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(fontSize: FinderMetrics.fontSize),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            max: max,
            activeColor: color,
            onChanged: (v) => _set(apply(v)),
          ),
        ),
      ],
    );
    return AlertDialog(
      title: Text(
        l10n.colorPickerTitle,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final preset in _presets)
                  GestureDetector(
                    onTap: () => _set(HSVColor.fromColor(preset)),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: preset,
                        shape: BoxShape.circle,
                        border: Border.all(color: palette.separator),
                      ),
                    ),
                  ),
              ],
            ),
            slider(l10n.colorHue, _hsv.hue, 360, _hsv.withHue),
            slider(
              l10n.colorSaturation,
              _hsv.saturation,
              1,
              _hsv.withSaturation,
            ),
            slider(l10n.colorBrightness, _hsv.value, 1, _hsv.withValue),
            Row(
              spacing: 12,
              children: [
                Container(
                  width: 48,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(
                      FinderMetrics.radiusSmall,
                    ),
                    border: Border.all(color: palette.separator),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _hex,
                    decoration: const InputDecoration(isDense: true),
                    style: const TextStyle(fontSize: FinderMetrics.fontSize),
                    onChanged: (text) {
                      if (parseHexColor(text) case final parsed?) {
                        _set(HSVColor.fromColor(parsed), fromHex: true);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.buttonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, color),
          child: Text(l10n.buttonOk),
        ),
      ],
    );
  }
}
