import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/result.dart';
import 'adb_service.dart';

/// An installed code editor or IDE, from its freedesktop `.desktop` entry.
@immutable
class EditorApp {
  const EditorApp({required this.id, required this.name, required this.exec});

  /// Desktop file name without `.desktop`.
  final String id;
  final String name;

  /// The `Exec` line split into arguments, field codes still in place.
  final List<String> exec;

  bool get isAndroidStudio => exec.any((a) => a.contains('android-studio'));

  @override
  bool operator ==(Object other) =>
      other is EditorApp &&
      other.id == id &&
      other.name == name &&
      listEquals(other.exec, exec);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAll(exec));
}

// Editors whose entries only say "Development" (VS Code forks, Zed…), by
// executable name.
const _knownEditors = {
  'code',
  'code-insiders',
  'codium',
  'cursor',
  'antigravity',
  'windsurf',
  'zed',
  'zeditor',
  'sublime_text',
  'subl',
};

/// The editor described by a `.desktop` file, or null for anything else
/// (other apps, hidden entries, terminal programs like vim).
EditorApp? parseEditorEntry(String id, String contents) {
  final fields = <String, String>{};
  var inEntry = false;
  for (final line in contents.split('\n')) {
    final text = line.trim();
    if (text.startsWith('[')) {
      // Actions follow in their own groups; only the main one counts.
      if (inEntry) break;
      inEntry = text == '[Desktop Entry]';
    } else if (inEntry) {
      final eq = text.indexOf('=');
      if (eq > 0) {
        fields.putIfAbsent(text.substring(0, eq), () => text.substring(eq + 1));
      }
    }
  }
  final name = fields['Name'];
  final exec = splitExec(fields['Exec'] ?? '');
  if (name == null || exec.isEmpty) return null;
  if (fields['Type'] != 'Application' ||
      fields['NoDisplay'] == 'true' ||
      fields['Hidden'] == 'true' ||
      fields['Terminal'] == 'true') {
    return null;
  }
  final categories = (fields['Categories'] ?? '').split(';');
  final editor =
      categories.contains('IDE') ||
      (categories.contains('Development') &&
          (categories.contains('TextEditor') ||
              _knownEditors.contains(p.basename(exec.first))));
  return editor ? EditorApp(id: id, name: name, exec: exec) : null;
}

/// Splits an `Exec` value into arguments, honoring double quotes and the
/// backslash escapes allowed inside them.
List<String> splitExec(String exec) {
  final args = <String>[];
  final current = StringBuffer();
  var quoted = false;
  var started = false;
  for (var i = 0; i < exec.length; i++) {
    final c = exec[i];
    if (quoted && c == r'\' && i + 1 < exec.length) {
      current.write(exec[++i]);
    } else if (c == '"') {
      quoted = !quoted;
      started = true;
    } else if (c == ' ' && !quoted) {
      if (started) args.add(current.toString());
      current.clear();
      started = false;
    } else {
      current.write(c);
      started = true;
    }
  }
  if (started) args.add(current.toString());
  return args;
}

/// [app]'s command to open [dir]: file and URL field codes become the
/// folder, the rest (icon, name, location) are dropped.
List<String> launchArgs(EditorApp app, String dir) => [
  for (final arg in app.exec)
    if (const {'%f', '%F', '%u', '%U'}.contains(arg))
      dir
    else if (!RegExp(r'^%[a-zA-Z]$').hasMatch(arg))
      arg.replaceAll('%%', '%'),
];

bool isGitRepo(String dir) =>
    !isDevicePath(dir) &&
    FileSystemEntity.typeSync(p.join(dir, '.git')) !=
        FileSystemEntityType.notFound;

/// Android, Gradle or Flutter projects, which Android Studio suits.
bool isAndroidProject(String dir) =>
    [
      'build.gradle',
      'build.gradle.kts',
      'settings.gradle',
      'settings.gradle.kts',
      'pubspec.yaml',
      'android',
    ].any(
      (name) =>
          FileSystemEntity.typeSync(p.join(dir, name)) !=
          FileSystemEntityType.notFound,
    );

/// Code editors installed on the desktop, offered for git folders.
class EditorAppsService {
  EditorAppsService({Map<String, String>? environment})
    : _env = environment ?? Platform.environment;

  final Map<String, String> _env;
  List<EditorApp> _apps = const [];

  List<EditorApp> get apps => _apps;

  /// Reads the `.desktop` files once; until then no editor is offered.
  Future<void> load() async {
    final dataHome =
        _env['XDG_DATA_HOME'] ?? p.join(_env['HOME'] ?? '/', '.local/share');
    final dataDirs = (_env['XDG_DATA_DIRS'] ?? '/usr/local/share:/usr/share')
        .split(':')
        .where((d) => d.isNotEmpty);
    final found = <String, EditorApp?>{};
    // Earlier directories win, as in the spec: user, then system.
    for (final dir in [dataHome, ...dataDirs]) {
      final folder = Directory(p.join(dir, 'applications'));
      if (!await folder.exists()) continue;
      await for (final file in folder.list()) {
        final name = p.basename(file.path);
        if (file is! File || !name.endsWith('.desktop')) continue;
        final id = p.basenameWithoutExtension(name);
        if (found.containsKey(id)) continue;
        try {
          found[id] = parseEditorEntry(id, await file.readAsString());
        } on FileSystemException {
          continue;
        }
      }
    }
    final names = <String>{};
    _apps = [
      for (final app in found.values.nonNulls)
        if (names.add(app.name)) app,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Editors to offer for [dir]: none unless it is a git repository;
  /// Android Studio first for Android projects and left out otherwise.
  List<EditorApp> appsFor(String dir) {
    if (_apps.isEmpty || !isGitRepo(dir)) return const [];
    final android = isAndroidProject(dir);
    return [
      if (android) ..._apps.where((a) => a.isAndroidStudio),
      ..._apps.where((a) => !a.isAndroidStudio),
    ];
  }

  Future<Result<void>> open(EditorApp app, String dir) async {
    final args = launchArgs(app, dir);
    try {
      await Process.start(
        args.first,
        args.sublist(1),
        workingDirectory: dir,
        mode: ProcessStartMode.detached,
      );
      return const Ok(null);
    } on ProcessException catch (e) {
      return Err(Failure(FailureKind.other, e.message));
    }
  }
}
