import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../theme/finder_theme.dart';
import 'glass_panel.dart';

/// Material's 300 ms grow-in felt sluggish next to macOS menus, which appear
/// almost at once.
const _menuAnimation = AnimationStyle(
  duration: Duration(milliseconds: 90),
  reverseDuration: Duration(milliseconds: 120),
);

/// Opens a menu at [at] (global). With the glass style it is a frosted
/// panel; otherwise Material's menu.
Future<T?> showFinderMenu<T>(
  BuildContext context,
  Offset at,
  List<PopupMenuEntry<T>> items,
) {
  if (context.palette.glass) {
    return Navigator.of(context).push(
      _GlassMenuRoute<T>(
        at: at,
        items: items,
        tint: Theme.of(context).colorScheme.surface,
        capturedThemes: InheritedTheme.capture(
          from: context,
          to: Navigator.of(context).context,
        ),
      ),
    );
  }
  return showMenu<T>(
    context: context,
    position: RelativeRect.fromLTRB(at.dx, at.dy, at.dx, at.dy),
    popUpAnimationStyle: _menuAnimation,
    items: items,
  );
}

/// Material's menu items on a [GlassPanel]. Items pop the route with
/// their value themselves, as they do in Material's menu.
class _GlassMenuRoute<T> extends PopupRoute<T> {
  _GlassMenuRoute({
    required this.at,
    required this.items,
    required this.tint,
    required this.capturedThemes,
  });

  final Offset at;
  final List<PopupMenuEntry<T>> items;
  final Color tint;
  final CapturedThemes capturedThemes;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Dismiss menu';

  @override
  Duration get transitionDuration => _menuAnimation.duration!;

  @override
  Duration get reverseTransitionDuration => _menuAnimation.reverseDuration!;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    final menu = CustomSingleChildLayout(
      delegate: _MenuLayout(at),
      child: FocusScope(
        autofocus: true,
        child: GlassPanel(
          tint: tint,
          radius: FinderMetrics.radiusMedium,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 112, maxWidth: 420),
            child: IntrinsicWidth(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return capturedThemes.wrap(
      FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: menu,
      ),
    );
  }
}

/// Puts the menu's top-left at the pointer, flipped to stay on screen.
class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout(this.at);

  final Offset at;
  static const _margin = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.loose(
        constraints.biggest,
      ).deflate(const EdgeInsets.all(_margin));

  @override
  Offset getPositionForChild(Size size, Size child) {
    var x = at.dx;
    var y = at.dy;
    if (x + child.width > size.width - _margin) x = at.dx - child.width;
    if (y + child.height > size.height - _margin) y = at.dy - child.height;
    return Offset(
      x.clamp(_margin, size.width - child.width - _margin),
      y.clamp(_margin, size.height - child.height - _margin),
    );
  }

  @override
  bool shouldRelayout(_MenuLayout old) => old.at != at;
}

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
