import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/place.dart';
import '../models/sort_spec.dart';
import '../services/adb_service.dart';
import '../services/editor_apps.dart';
import '../services/window_registry.dart';
import '../state/browser_controller.dart';
import '../l10n/app_localizations.dart';
import '../models/finder_settings.dart';
import '../models/tag_color.dart';
import '../models/file_entry.dart';
import 'app_services.dart';
import 'dialogs/conflict_dialog.dart';
import 'dialogs/quick_look.dart';
import 'dialogs/simple_dialogs.dart';
import 'finder_scope.dart';
import 'settings/settings_controls.dart';
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
  Future<void> paste() => _s.actions.paste(
    copySuffix: _l10n.copySuffix,
    resolve: conflictResolver(context),
  );
  Future<void> sendToDevice(Place device) => _s.actions.sendSelectionToDevice(
    device.path,
    device.label,
    copySuffix: _l10n.copySuffix,
    resolve: conflictResolver(context),
  );
  Future<void> openInEditor(EditorApp app, String dir) async {
    final editors = AppServices.editorsOf(context);
    if (editors == null) return;
    if (await editors.open(app, dir) case Err(:final failure)) {
      _s.browser.emit(FailureNotice(failure));
    }
  }

  Future<void> undo() => _s.actions.undo();
  Future<void> redo() => _s.actions.redo();
  Future<void> duplicate() =>
      _s.actions.duplicate(copySuffix: _l10n.copySuffix);
  Future<void> openInTerminal([String? dir]) =>
      _s.browser.fs.openTerminal(dir ?? _s.browser.path);

  /// Ctrl+N: a fresh window at the default folder, as in Finder (not a
  /// copy of this one).
  Future<void> newWindow() => _s.window.openWindow();

  /// Delete key: Trash normally, permanent delete (confirmed) inside the
  /// Trash and on devices, which have none.
  Future<void> delete() async {
    final b = _s.browser;
    if (b.selection.isEmpty) return;
    if (!b.isTrash && !isDevicePath(b.path)) {
      return _s.actions.trashSelection();
    }
    await deleteImmediately([for (final e in b.selectedEntries) e.path]);
  }

  Future<void> deleteImmediately(List<String> paths) async {
    if (paths.isEmpty) return;
    final ok = await confirmDestructive(
      context,
      title: _l10n.deleteConfirmTitle(paths.length),
      body: _l10n.deleteConfirmBody,
      action: _l10n.buttonDelete,
    );
    if (ok) await _s.actions.deletePaths(paths);
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
    await _s.window.openWindow(_s.tabs.tabs[index].browser.path);
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
    await showQuickLook(
      context,
      entry,
      onOpen: () => _s.actions.open(entry),
      localCopy: _s.browser.fs.localCopy,
    );
    _s.contentFocus.requestFocus();
  }

  Future<void> getInfo() async {
    final entry =
        _s.browser.cursorEntry ?? _s.browser.selectedEntries.firstOrNull;
    if (entry == null) return;
    await showGetInfo(context, entry, _s.browser.fs);
  }

  Future<void> goToFolder() async {
    final target = await askGoToFolder(
      context,
      home: _s.sidebar.home,
      current: _s.browser.path,
    );
    if (target != null) await openLocation(target);
  }

  /// Opens a typed location: a folder, or a file shown selected in its
  /// folder.
  Future<void> openLocation(String target) async {
    final browser = _s.browser;
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

  /// Ctrl + / Ctrl − / Ctrl 0: text size, as in a browser.
  Future<void> zoomText(int steps) {
    final s = SettingsScope.read(context).value;
    final size = steps == 0 ? defaultTextSize : stepTextSize(s.textSize, steps);
    return saveSettings(context, s.copyWith(textSize: size));
  }

  /// Ctrl+L: type a location in the path bar, or in a dialog when the
  /// path bar is hidden.
  Future<void> editLocation() async {
    if (SettingsScope.read(context).value.showPathBar) {
      _s.browser.setEditingLocation(true);
    } else {
      await goToFolder();
    }
  }

  /// Lists every file in Home tagged [tag], as a sidebar tag does.
  Future<void> showTagged(TagColor tag) async {
    final home = _s.sidebar.home;
    if (_s.browser.path != home) await _s.browser.navigate(home, root: home);
    _s.browser.showTagged(tag);
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
