import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/place.dart';
import '../models/sort_spec.dart';
import 'commands.dart';
import 'finder_scope.dart';

const _typeAheadReset = Duration(milliseconds: 900);

/// Keys handled while the file view has focus. Finder's Cmd maps to Ctrl.
class ViewKeyHandler {
  String _typed = '';
  DateTime _lastTyped = DateTime(0);

  /// [gridColumns] is how many items one row of the icon grid holds.
  KeyEventResult handle(
    BuildContext context,
    KeyEvent event, {
    required int gridColumns,
  }) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final scope = FinderScope.of(context);
    final b = scope.browser;
    if (b.renamingPath != null) return KeyEventResult.ignored;
    final cmd = FinderCommands(context);
    final keys = HardwareKeyboard.instance;
    final ctrl = keys.isControlPressed;
    final shift = keys.isShiftPressed;
    final alt = keys.isAltPressed;
    final key = event.logicalKey;
    final repeatable = event is KeyDownEvent || event is KeyRepeatEvent;

    bool run(void Function() action) {
      action();
      return true;
    }

    final handled = switch (key) {
      _ when ctrl && alt && key == LogicalKeyboardKey.keyC => run(cmd.copyPath),
      LogicalKeyboardKey.keyA when ctrl => run(b.selectAll),
      LogicalKeyboardKey.keyC when ctrl => run(scope.actions.copy),
      LogicalKeyboardKey.keyX when ctrl => run(scope.actions.cut),
      LogicalKeyboardKey.keyV when ctrl => run(cmd.paste),
      LogicalKeyboardKey.keyD when ctrl => run(cmd.duplicate),
      LogicalKeyboardKey.keyI when ctrl => run(cmd.getInfo),
      LogicalKeyboardKey.backspace when ctrl => run(cmd.delete),
      LogicalKeyboardKey.arrowDown when ctrl => run(
        scope.actions.openSelection,
      ),
      LogicalKeyboardKey.arrowUp when ctrl => run(b.up),
      _ when ctrl || alt => false,
      LogicalKeyboardKey.arrowDown when repeatable => run(
        () => b.moveCursor(
          b.viewMode == ViewMode.icons ? gridColumns : 1,
          extend: shift,
        ),
      ),
      LogicalKeyboardKey.arrowUp when repeatable => run(
        () => b.moveCursor(
          b.viewMode == ViewMode.icons ? -gridColumns : -1,
          extend: shift,
        ),
      ),
      LogicalKeyboardKey.arrowRight when b.viewMode == ViewMode.icons => run(
        () => b.moveCursor(1, extend: shift),
      ),
      LogicalKeyboardKey.arrowLeft when b.viewMode == ViewMode.icons => run(
        () => b.moveCursor(-1, extend: shift),
      ),
      LogicalKeyboardKey.arrowRight when b.viewMode == ViewMode.columns => run(
        () => _enterColumn(context),
      ),
      LogicalKeyboardKey.arrowLeft when b.viewMode == ViewMode.columns => run(
        b.up,
      ),
      LogicalKeyboardKey.enter ||
      LogicalKeyboardKey.numpadEnter => run(scope.actions.openSelection),
      LogicalKeyboardKey.f2 => run(b.beginRename),
      LogicalKeyboardKey.space => run(cmd.quickLook),
      LogicalKeyboardKey.delete => run(cmd.delete),
      LogicalKeyboardKey.backspace => run(b.back),
      LogicalKeyboardKey.escape => run(
        b.query.isEmpty ? b.clearSelection : () => b.setQuery(''),
      ),
      _ => _typeAhead(context, event),
    };
    return handled ? KeyEventResult.handled : KeyEventResult.ignored;
  }

  Future<void> _enterColumn(BuildContext context) async {
    final b = FinderScope.of(context).browser;
    final target = b.cursorEntry;
    if (target == null || !target.isDirectory) return;
    await b.navigate(target.path);
    b.moveCursor(1);
  }

  bool _typeAhead(BuildContext context, KeyEvent event) {
    final char = event.character;
    if (char == null || char.isEmpty || char.codeUnitAt(0) < 0x20) return false;
    final now = DateTime.now();
    _typed = now.difference(_lastTyped) > _typeAheadReset
        ? char
        : _typed + char;
    _lastTyped = now;
    FinderScope.of(context).browser.selectByPrefix(_typed);
    return true;
  }
}

const _tabDigits = [
  LogicalKeyboardKey.digit1,
  LogicalKeyboardKey.digit2,
  LogicalKeyboardKey.digit3,
  LogicalKeyboardKey.digit4,
  LogicalKeyboardKey.digit5,
  LogicalKeyboardKey.digit6,
  LogicalKeyboardKey.digit7,
  LogicalKeyboardKey.digit8,
  LogicalKeyboardKey.digit9,
];

/// Window-wide shortcuts that work regardless of which pane has focus.
KeyEventResult handleGlobalKey(
  BuildContext context,
  KeyEvent event, {
  required FocusNode searchFocus,
}) {
  if (event is KeyUpEvent) return KeyEventResult.ignored;
  final scope = FinderScope.of(context);
  final b = scope.browser;
  final cmd = FinderCommands(context);
  final keys = HardwareKeyboard.instance;
  final ctrl = keys.isControlPressed;
  final shift = keys.isShiftPressed;
  final alt = keys.isAltPressed;
  final key = event.logicalKey;

  String? placePath(PlaceKind kind) =>
      scope.sidebar.favorites.where((p) => p.kind == kind).firstOrNull?.path;

  void Function()? action;
  if (ctrl && shift) {
    action = switch (key) {
      LogicalKeyboardKey.keyN => cmd.newFolder,
      LogicalKeyboardKey.keyG => cmd.goToFolder,
      LogicalKeyboardKey.keyH => () => cmd.goTo(scope.sidebar.home),
      LogicalKeyboardKey.keyD => () => cmd.goTo(
        placePath(PlaceKind.desktop) ?? scope.sidebar.home,
      ),
      LogicalKeyboardKey.keyO => () => cmd.goTo(
        placePath(PlaceKind.documents) ?? scope.sidebar.home,
      ),
      LogicalKeyboardKey.keyL => () => cmd.goTo(
        placePath(PlaceKind.downloads) ?? scope.sidebar.home,
      ),
      LogicalKeyboardKey.period => b.toggleHidden,
      LogicalKeyboardKey.keyM => cmd.mergeAllWindows,
      LogicalKeyboardKey.tab => () => scope.tabs.cycle(-1),
      _ => null,
    };
  } else if (ctrl) {
    action = switch (key) {
      LogicalKeyboardKey.keyF => searchFocus.requestFocus,
      LogicalKeyboardKey.comma => cmd.openSettings,
      LogicalKeyboardKey.keyL => cmd.goToFolder,
      LogicalKeyboardKey.keyN => cmd.newWindow,
      LogicalKeyboardKey.keyT => cmd.newTab,
      LogicalKeyboardKey.keyW => cmd.closeTab,
      LogicalKeyboardKey.keyQ => scope.window.close,
      LogicalKeyboardKey.tab ||
      LogicalKeyboardKey.pageDown => () => scope.tabs.cycle(1),
      LogicalKeyboardKey.pageUp => () => scope.tabs.cycle(-1),
      LogicalKeyboardKey.keyH => b.toggleHidden,
      LogicalKeyboardKey.keyR => b.refresh,
      LogicalKeyboardKey.digit1 => () => b.setViewMode(ViewMode.icons),
      LogicalKeyboardKey.digit2 => () => b.setViewMode(ViewMode.list),
      LogicalKeyboardKey.digit3 => () => b.setViewMode(ViewMode.columns),
      LogicalKeyboardKey.bracketLeft => b.back,
      LogicalKeyboardKey.bracketRight => b.forward,
      _ => null,
    };
  } else if (alt) {
    action = switch (key) {
      LogicalKeyboardKey.arrowLeft => b.back,
      LogicalKeyboardKey.arrowRight => b.forward,
      LogicalKeyboardKey.arrowUp => b.up,
      LogicalKeyboardKey.home => () => cmd.goTo(scope.sidebar.home),
      // Alt+1…9 jump to a tab (Ctrl+1…3 already switch the view).
      _ when _tabDigits.contains(key) => () => scope.tabs.activate(
        _tabDigits.indexOf(key),
      ),
      _ => null,
    };
  } else if (key == LogicalKeyboardKey.f5) {
    action = b.refresh;
  }
  if (action == null) return KeyEventResult.ignored;
  action();
  return KeyEventResult.handled;
}
