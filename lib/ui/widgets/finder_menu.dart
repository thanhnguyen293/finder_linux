import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';

/// Material's 300 ms grow-in felt sluggish next to macOS menus, which appear
/// almost at once.
const _menuAnimation = AnimationStyle(
  duration: Duration(milliseconds: 90),
  reverseDuration: Duration(milliseconds: 120),
);

Future<T?> showFinderMenu<T>(
  BuildContext context,
  Offset at,
  List<PopupMenuEntry<T>> items,
) => showMenu<T>(
  context: context,
  position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
  popUpAnimationStyle: _menuAnimation,
  items: items,
);

/// Non-selectable section title, like "Sort By" in Finder's menus.
PopupMenuItem<T> menuHeader<T>(BuildContext context, String label) =>
    PopupMenuItem<T>(
      enabled: false,
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        label,
        style: TextStyle(
          fontSize: FinderMetrics.fontSizeSmall,
          fontWeight: FontWeight.w700,
          color: context.palette.textSecondary,
        ),
      ),
    );

/// Item with a leading mark ([mark], default a checkmark) when [checked].
PopupMenuItem<T> menuCheckItem<T>({
  required T value,
  required String label,
  required bool checked,
  IconData mark = CupertinoIcons.checkmark,
}) => PopupMenuItem<T>(
  value: value,
  height: 26,
  padding: const EdgeInsets.symmetric(horizontal: 8),
  child: Row(
    children: [
      SizedBox(width: 22, child: checked ? Icon(mark, size: 12) : null),
      Text(label, style: const TextStyle(fontSize: FinderMetrics.fontSize)),
    ],
  ),
);
