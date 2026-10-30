import 'dart:async';

import 'package:flutter/material.dart';
import 'package:irondash_message_channel/irondash_message_channel.dart'
    show isolateIdSalt;
import 'package:super_clipboard/super_clipboard.dart';

import 'l10n/app_localizations.dart';
import 'launch_target.dart';
import 'models/finder_settings.dart';
import 'services/adb_service.dart';
import 'services/clipboard_service.dart';
import 'services/editor_apps.dart';
import 'services/file_system_service.dart';
import 'services/places_service.dart';
import 'services/recent_folders.dart';
import 'services/session_store.dart';
import 'services/settings_store.dart';
import 'services/thumbnail_service.dart';
import 'services/update_service.dart';
import 'state/settings_controller.dart';
import 'state/update_controller.dart';
import 'theme/finder_theme.dart';
import 'ui/finder_window.dart';
import 'ui/settings_scope.dart';
import 'ui/app_services.dart';

/// The GTK runner's first, never-shown engine (see start_host_engine in
/// linux/runner/my_application.cc). It only keeps the shared Dart VM's
/// code loaded, so its main does nothing.
const hostEngineFlag = '--host-engine';

Future<void> main(List<String> args) async {
  if (args.contains(hostEngineFlag)) return;
  // Before any plugin talks to native code: this window's engine shares
  // the process with the other windows' engines.
  isolateIdSalt = windowIndexOf(args);
  WidgetsFlutterBinding.ensureInitialized();
  final places = PlacesService();
  final store = SettingsStore();
  final settings = SettingsController(store, await store.load());
  final startFolder = await places.folderFor(settings.value.newWindowFolder);
  final (folder, select) = resolveLaunchTarget(args, home: startFolder);
  // Whether this launch becomes a tab of an open window instead ("open
  // folders in tabs") was settled before this window was created: all
  // windows share one process, which asks the active window first (see
  // FinderWindow's launch handler and linux/runner/my_application.cc).
  final openedWithPath = args.any((a) => !a.startsWith('--'));
  // Opened from the app grid (no folder, not Ctrl+N): reopen last tabs.
  final sessions = SessionStore();
  final newWindow = args.contains(newWindowFlag);
  final restored = !openedWithPath && !newWindow && settings.value.restoreTabs
      ? await sessions.load()
      : null;
  final updates = UpdateController(UpdateService());
  if (settings.value.checkForUpdates) unawaited(updates.checkIfDue());
  final editors = EditorAppsService();
  unawaited(editors.load());
  runApp(
    FinderApp(
      places: places,
      settings: settings,
      initialPath: folder,
      initialSelection: select,
      restoredSession: restored,
      fs: const FileSystemService(adb: AdbService()),
      thumbnails: ThumbnailService(adb: const AdbService()),
      recents: RecentFolders(),
      updates: updates,
      editors: editors,
      clipboardStore: switch (SystemClipboard.instance) {
        final system? => SystemFileClipboard(system),
        null => MemoryFileClipboard(),
      },
      // Extra windows (Ctrl+N, torn-off tabs) don't replace the session.
      sessionStore: newWindow ? null : sessions,
    ),
  );
}

class FinderApp extends StatelessWidget {
  const FinderApp({
    super.key,
    required this.places,
    required this.settings,
    required this.initialPath,
    this.initialSelection,
    this.fs = const FileSystemService(),
    this.nativeDragAndDrop = true,
    this.restoredSession,
    this.sessionStore,
    this.clipboardStore,
    this.thumbnails,
    this.recents,
    this.updates,
    this.editors,
  });

  final PlacesService places;
  final SettingsController settings;
  final FileSystemService fs;

  /// Platform drag and drop (needs the native plugin; off in widget tests).
  final bool nativeDragAndDrop;

  /// Tabs to reopen instead of [initialPath].
  final Session? restoredSession;

  /// Where this window saves its tabs; null for windows that shouldn't.
  final SessionStore? sessionStore;

  /// The desktop clipboard; an in-memory one when not given (tests).
  final FileClipboardStore? clipboardStore;

  /// Generated previews for PDFs, videos and documents; none when null
  /// (widget tests, which can't run the tools).
  final ThumbnailService? thumbnails;

  /// Recent Folders store; none in widget tests.
  final RecentFolders? recents;

  /// Self-update from GitHub; none in widget tests.
  final UpdateController? updates;

  /// Code editors for "Open in…" on git folders; none in widget tests.
  final EditorAppsService? editors;
  final String initialPath;
  final String? initialSelection;

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      notifier: settings,
      child: Builder(
        builder: (context) {
          final prefs = SettingsScope.of(context);
          return MaterialApp(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            debugShowCheckedModeBanner: false,
            theme: buildFinderTheme(
              Brightness.light,
              accent: prefs.accent,
              colors: prefs.lightColors,
              sidebarOpacity: prefs.sidebarOpacity,
              windowOpacity: prefs.windowOpacity,
              glass: prefs.glass,
            ),
            darkTheme: buildFinderTheme(
              Brightness.dark,
              accent: prefs.accent,
              colors: prefs.darkColors,
              sidebarOpacity: prefs.sidebarOpacity,
              windowOpacity: prefs.windowOpacity,
              glass: prefs.glass,
            ),
            // The user's text size scales every label; heights that hold
            // text grow with it via `context.scaled`.
            builder: (context, child) {
              final scaled = MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(prefs.textScale)),
                child: child ?? const SizedBox.shrink(),
              );
              return AppServices(
                thumbnails: thumbnails,
                updates: updates,
                editors: editors,
                child: scaled,
              );
            },
            themeMode: switch (prefs.appearance) {
              AppearanceMode.system => ThemeMode.system,
              AppearanceMode.light => ThemeMode.light,
              AppearanceMode.dark => ThemeMode.dark,
            },
            locale: switch (prefs.languageCode) {
              final code? => Locale(code),
              null => null,
            },
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: FinderWindow(
              fs: fs,
              places: places,
              settings: settings,
              nativeDragAndDrop: nativeDragAndDrop,
              clipboardStore: clipboardStore ?? MemoryFileClipboard(),
              restoredSession: restoredSession,
              sessionStore: sessionStore,
              recents: recents,
              initialPath: initialPath,
              initialSelection: initialSelection,
            ),
          );
        },
      ),
    );
  }
}
