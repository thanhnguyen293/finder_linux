import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/sort_spec.dart';
import '../services/window_registry.dart';
import '../state/browser_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/file_entry.dart';
import 'dialogs/quick_look.dart';
import 'dialogs/simple_dialogs.dart';
import 'finder_scope.dart';
import 'settings/settings_dialog.dart';
import 'settings_scope.dart';

/// User-facing commands that need localized strings or dialogs. Shared by
/// keyboard shortcuts, context menus and toolbar buttons.
class FinderCommands {
  FinderCommands(this.context);

  final BuildContext context;

  FinderScope get _s => FinderScope.of(context);
  AppLocalizations get _l10n => AppLocalizations.of(context);

  Future<void> newFolder() => _s.actions.newFolder(_l10n.untitledFolder);
  Future<void> paste() => _s.actions.paste(copySuffix: _l10n.copySuffix);
  Future<void> duplicate() =>
      _s.actions.duplicate(copySuffix: _l10n.copySuffix);
  Future<void> openInTerminal([String? dir]) =>
      _s.browser.fs.openTerminal(dir ?? _s.browser.path);
  Future<void> newWindow() => _s.browser.fs.openNewWindow(_s.browser.path);

  /// Delete key: Trash normally, permanent delete (confirmed) inside Trash.
  Future<void> delete() async {
    final count = _s.browser.selection.length;
    if (count == 0) return;
    if (!_s.browser.isTrash) return _s.actions.trashSelection();
    final ok = await confirmDestructive(
      context,
      title: _l10n.deleteConfirmTitle(count),
      body: _l10n.deleteConfirmBody,
      action: _l10n.buttonDelete,
    );
    if (ok) await _s.actions.deleteSelection();
  }

  Future<void> emptyTrash() async {
    if (!SettingsScope.read(context).value.warnBeforeEmptyingTrash) {
      return _s.actions.emptyTrash();
    }
    final ok = await confirmDestructive(
      context,
      title: _l10n.emptyTrashConfirmTitle,
      body: _l10n.deleteConfirmBody,
      action: _l10n.menuEmptyTrash,
    );
    if (ok) await _s.actions.emptyTrash();
  }

  /// Opens [path] (default: the current folder) in a new tab.
  void newTab([String? path, bool activate = true]) {
    _s.tabs.open(path ?? _s.browser.path, activate: activate);
  }

  /// Closes a tab (default: the active one); the last tab closes the window.
  void closeTab([int? index]) {
    if (!_s.tabs.close(index ?? _s.tabs.activeIndex)) _s.window.close();
  }

  void closeOtherTabs(int index) => _s.tabs.closeOthers(index);

  Future<void> moveTabToNewWindow(int index) async {
    await _s.browser.fs.openNewWindow(_s.tabs.tabs[index].browser.path);
    closeTab(index);
  }

  /// Window ▸ Merge All Windows: every other Finder window hands over its
  /// tabs and closes.
  Future<void> mergeAllWindows() async {
    final registry = _s.registry;
    final tabs = _s.tabs;
    final l10n = _l10n;
    final messenger = ScaffoldMessenger.of(context);
    final windows = registry == null
        ? const <List<TabDescriptor>>[]
        : await registry.collectOtherWindows();
    for (final window in windows) {
      for (final t in window) {
        final tab = tabs.open(t.path, activate: false, atEnd: true);
        final view = ViewMode.values.where((v) => v.name == t.viewMode);
        if (view.isNotEmpty) tab.browser.setViewMode(view.first);
      }
    }
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.mergedWindows(windows.length))),
    );
  }

  Future<void> openSettings() async {
    await showFinderSettings(context);
    _s.contentFocus.requestFocus();
  }

  Future<void> quickLook() async {
    final entry =
        _s.browser.cursorEntry ?? _s.browser.selectedEntries.firstOrNull;
    if (entry == null) return;
    await showQuickLook(context, entry, onOpen: () => _s.actions.open(entry));
    _s.contentFocus.requestFocus();
  }

  Future<void> getInfo() async {
    final entry =
        _s.browser.cursorEntry ?? _s.browser.selectedEntries.firstOrNull;
    if (entry == null) return;
    await showGetInfo(context, entry, _s.browser.fs);
  }

  Future<void> goToFolder() async {
    final browser = _s.browser;
    final target = await askGoToFolder(
      context,
      home: _s.sidebar.home,
      current: browser.path,
    );
    if (target == null) return;
    if (browser.fs.isDirectory(target)) {
      await browser.navigate(target);
    } else if (await browser.fs.entry(target) != null) {
      await browser.navigate(p.dirname(target), select: target);
    } else {
      browser.emit(FailureNotice(Failure(FailureKind.notFound, target)));
    }
    _s.contentFocus.requestFocus();
  }

  /// Jumps to a place (sidebar, path bar, Go shortcuts); it becomes the
  /// first column of the column view.
  Future<void> goTo(String path) async {
    await _s.browser.navigate(path, root: path);
    _s.contentFocus.requestFocus();
  }

  Future<void> copyPath() async {
    final paths = _s.browser.selectedEntries.map((e) => e.path);
    await Clipboard.setData(
      ClipboardData(text: paths.isEmpty ? _s.browser.path : paths.join('\n')),
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(_l10n.pathCopied)));
  }

  /// Clicking an item: plain click selects, Ctrl toggles, Shift extends.
  void clickEntry(FileEntry entry) {
    final keys = HardwareKeyboard.instance;
    _s.contentFocus.requestFocus();
    _s.browser.select(
      entry.path,
      toggle: keys.isControlPressed || keys.isMetaPressed,
      range: keys.isShiftPressed,
    );
  }

  /// Right-click keeps an existing multi-selection if the item is part of it.
  void secondaryClickEntry(FileEntry entry) {
    _s.contentFocus.requestFocus();
    if (!_s.browser.isSelected(entry.path)) _s.browser.select(entry.path);
  }
}
