import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';
import '../widgets/finder_menu.dart';

const _labelWidth = 170.0;

/// "Label:  [control]" with labels right-aligned in one column, as in macOS
/// settings windows.
class SettingRow extends StatelessWidget {
  const SettingRow({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: FinderMetrics.fontSize),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(child: child),
      ],
    ),
  );
}

/// macOS-style pop-up button: shows the current choice, opens a menu.
class PopupField<T> extends StatelessWidget {
  const PopupField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return GestureDetector(
      onTapUp: (d) async {
        // The menu answers with an index: an option may itself be null
        // (e.g. "System" language), which would read as "dismissed".
        final keys = options.keys.toList();
        final chosen = await showFinderMenu<int>(context, d.globalPosition, [
          for (final (i, option) in keys.indexed)
            menuCheckItem(
              value: i,
              label: options[option] ?? '',
              checked: option == value,
            ),
        ]);
        if (chosen != null) onChanged(keys[chosen]);
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 180),
        padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
        decoration: BoxDecoration(
          color: palette.controlHover,
          borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          border: Border.all(color: palette.separator, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                options[value] ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: FinderMetrics.fontSize),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 12,
              color: palette.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Checkbox whose label is clickable too.
class CheckRow extends StatelessWidget {
  const CheckRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.leading,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? leading;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onChanged(!value),
    borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (v) => onChanged(v ?? false),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: FinderMetrics.fontSize),
            ),
          ),
        ],
      ),
    ),
  );
}
