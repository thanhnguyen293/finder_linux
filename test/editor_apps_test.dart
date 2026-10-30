import 'dart:io';

import 'package:finder_linux/services/editor_apps.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

const _code = '''
[Desktop Entry]
Name=Visual Studio Code
Name[vi]=Mã
Exec=/snap/bin/code --force-user-env %F
Type=Application
Categories=TextEditor;Development;IDE;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=/snap/bin/code --new-window %F
''';

const _studio = '''
[Desktop Entry]
Type=Application
Name=Android Studio
Exec=/snap/bin/android-studio %f
Categories=Development;IDE;
''';

const _antigravity = '''
[Desktop Entry]
Type=Application
Name=Antigravity
Exec=/snap/bin/antigravity %U
Categories=Development;
''';

const _claude = '''
[Desktop Entry]
Type=Application
Name=Claude
Exec=claude-desktop %U
Categories=Utility;Development;
''';

void main() {
  test('only visible GUI code editors are picked up', () {
    expect(parseEditorEntry('code', _code)?.name, 'Visual Studio Code');
    expect(parseEditorEntry('code', _code)?.exec, [
      '/snap/bin/code',
      '--force-user-env',
      '%F',
    ]);
    expect(parseEditorEntry('studio', _studio)?.isAndroidStudio, isTrue);
    // Categories alone don't say it; the executable does.
    expect(parseEditorEntry('ag', _antigravity)?.name, 'Antigravity');
    expect(parseEditorEntry('claude', _claude), isNull);
    expect(parseEditorEntry('h', '$_studio\nNoDisplay=true\n'), isNull);
    expect(
      parseEditorEntry(
        'vim',
        '[Desktop Entry]\nType=Application\nName=Vim\nExec=vim %F\n'
            'Terminal=true\nCategories=Development;TextEditor;\n',
      ),
      isNull,
    );
  });

  test('Exec lines split like a shell and fill in the folder', () {
    expect(splitExec(r'"/opt/My App/run" --flag "a \"b\"" %U'), [
      '/opt/My App/run',
      '--flag',
      'a "b"',
      '%U',
    ]);
    final app = EditorApp(
      id: 'x',
      name: 'X',
      exec: const ['x', '--name', '%c', '%i', '%U', '100%%'],
    );
    expect(launchArgs(app, '/p/repo'), ['x', '--name', '/p/repo', '100%']);
  });

  group('installed editors', () {
    late Directory root;
    late EditorAppsService service;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('finder_editors');
      Future<void> desktop(String dir, String id, String contents) async {
        final f = File(p.join(root.path, dir, 'applications', '$id.desktop'));
        await f.create(recursive: true);
        await f.writeAsString(contents);
      }

      await desktop('user', 'code', _code);
      // The user's own entry hides the system one with the same id.
      await desktop('sys', 'code', _code.replaceAll('Visual', 'System'));
      await desktop('sys', 'studio', _studio);
      await desktop('sys', 'claude', _claude);
      service = EditorAppsService(
        environment: {
          'XDG_DATA_HOME': p.join(root.path, 'user'),
          'XDG_DATA_DIRS': p.join(root.path, 'sys'),
        },
      );
      await service.load();
    });

    tearDown(() => root.delete(recursive: true));

    test('are read once, user entries first', () {
      expect(service.apps.map((a) => a.name), [
        'Android Studio',
        'Visual Studio Code',
      ]);
    });

    test('are offered for git folders only, by project type', () async {
      final repo = await Directory(p.join(root.path, 'repo')).create();
      List<String> offered() =>
          service.appsFor(repo.path).map((a) => a.name).toList();
      expect(offered(), isEmpty);

      await Directory(p.join(repo.path, '.git')).create();
      expect(offered(), ['Visual Studio Code']);

      await File(p.join(repo.path, 'pubspec.yaml')).writeAsString('');
      expect(offered(), ['Android Studio', 'Visual Studio Code']);
      expect(service.appsFor('/@adb/emulator-5554'), isEmpty);
    });
  });
}
