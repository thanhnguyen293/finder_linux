import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'launch_target.dart';
import 'models/finder_settings.dart';
import 'services/file_system_service.dart';
import 'services/places_service.dart';
import 'services/settings_store.dart';
import 'state/settings_controller.dart';
import 'theme/finder_theme.dart';
import 'ui/finder_window.dart';
import 'ui/settings_scope.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  final places = PlacesService();
  final store = SettingsStore();
  final settings = SettingsController(store, await store.load());
  final startFolder = await places.folderFor(settings.value.newWindowFolder);
  final (folder, select) = resolveLaunchTarget(args, home: startFolder);
  runApp(
    FinderApp(
      places: places,
      settings: settings,
      initialPath: folder,
      initialSelection: select,
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
  });

  final PlacesService places;
  final SettingsController settings;
  final FileSystemService fs;
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
            theme: buildFinderTheme(Brightness.light),
            darkTheme: buildFinderTheme(Brightness.dark),
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
              initialPath: initialPath,
              initialSelection: initialSelection,
            ),
          );
        },
      ),
    );
  }
}
