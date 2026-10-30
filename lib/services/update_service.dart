import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';

/// GitHub repository Finder updates from.
const updateRepository = 'thanhnguyen293/finder_linux';

/// Commit this build was made from and the Flutter it was built with;
/// install.sh passes both (`--dart-define`). Empty in `flutter run`
/// builds, which therefore never offer updates.
const _buildCommit = String.fromEnvironment('FINDER_COMMIT');
const _buildFlutter = String.fromEnvironment('FINDER_FLUTTER');

/// What a check found.
enum UpdateCheck { upToDate, available }

/// Reads GitHub's compare answer: is `main` ahead of the build's commit?
UpdateCheck parseCompare(Map<String, Object?> json) =>
    switch (json['ahead_by']) {
      final int ahead when ahead > 0 => UpdateCheck.available,
      _ => UpdateCheck.upToDate,
    };

/// Finder installs from source (install.sh), so updating means fetching
/// the latest `main` into a private checkout and running its installer.
/// The user's own checkout is never touched.
class UpdateService {
  UpdateService({
    Map<String, String>? environment,
    this.commit = _buildCommit,
    this.flutter = _buildFlutter,
  }) : _env = environment ?? Platform.environment;

  final Map<String, String> _env;
  final String commit;
  final String flutter;

  static const _checkEvery = Duration(days: 1);

  /// Builds from install.sh know their commit and can update.
  bool get supported => commit.isNotEmpty && flutter.isNotEmpty;

  String get _cacheDir => p.join(
    _env['XDG_CACHE_HOME'] ?? p.join(_env['HOME'] ?? '/', '.cache'),
    'finder-linux',
  );

  String get sourceDir => p.join(_cacheDir, 'source');
  File get _stamp => File(p.join(_cacheDir, 'last-update-check'));

  /// Whether a day has passed since the last automatic check.
  Future<bool> isDue() async {
    try {
      final last = DateTime.parse((await _stamp.readAsString()).trim());
      return DateTime.now().difference(last) >= _checkEvery;
    } on FileSystemException {
      return true;
    } on FormatException {
      return true;
    }
  }

  Future<Result<UpdateCheck>> check() async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(
        Uri.https(
          'api.github.com',
          '/repos/$updateRepository/compare/$commit...main',
        ),
      );
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/vnd.github+json')
        ..set(HttpHeaders.userAgentHeader, 'finder-linux');
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final body = await response.transform(utf8.decoder).join();
      await _recordCheck();
      // 404: the build's commit isn't on GitHub (a local build); nothing
      // newer can be known.
      if (response.statusCode == HttpStatus.notFound) {
        return const Ok(UpdateCheck.upToDate);
      }
      if (response.statusCode != HttpStatus.ok) {
        return Err(Failure(FailureKind.other, 'HTTP ${response.statusCode}'));
      }
      return Ok(parseCompare(jsonDecode(body) as Map<String, Object?>));
    } on IOException catch (e) {
      return Err(Failure(FailureKind.other, e.toString()));
    } on TimeoutException {
      return const Err(Failure(FailureKind.other, 'timed out'));
    } on FormatException catch (e) {
      return Err(Failure(FailureKind.other, e.message));
    } finally {
      client.close(force: true);
    }
  }

  Future<void> _recordCheck() async {
    try {
      await _stamp.parent.create(recursive: true);
      await _stamp.writeAsString(DateTime.now().toIso8601String());
    } on FileSystemException {
      // Only means checking again sooner.
    }
  }

  /// Fetches `main` and runs its install.sh; [onLine] receives the output.
  Future<Result<void>> install({void Function(String line)? onLine}) async {
    final url = 'https://github.com/$updateRepository.git';
    final fetched = await Directory(p.join(sourceDir, '.git')).exists()
        ? await _run('git', [
                '-C',
                sourceDir,
                'fetch',
                '--depth',
                '1',
                'origin',
                'main',
              ], onLine) &&
              await _run('git', [
                '-C',
                sourceDir,
                'reset',
                '--hard',
                'FETCH_HEAD',
              ], onLine)
        : await _run('git', ['clone', '--depth', '1', url, sourceDir], onLine);
    if (!fetched) return const Err(Failure(FailureKind.other, 'git'));
    final built = await _run(
      'bash',
      [p.join(sourceDir, 'install.sh')],
      onLine,
      workingDirectory: sourceDir,
      // The app may have been started from the desktop, whose PATH often
      // lacks Flutter.
      path: '${p.dirname(flutter)}:${_env['PATH'] ?? '/usr/bin:/bin'}',
    );
    return built
        ? const Ok(null)
        : const Err(Failure(FailureKind.other, 'install.sh'));
  }

  Future<bool> _run(
    String exe,
    List<String> args,
    void Function(String line)? onLine, {
    String? workingDirectory,
    String? path,
  }) async {
    try {
      final process = await Process.start(
        exe,
        args,
        workingDirectory: workingDirectory,
        environment: {'PATH': ?path},
      );
      void forward(Stream<List<int>> s) => s
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onLine);
      forward(process.stdout);
      forward(process.stderr);
      return await process.exitCode == 0;
    } on ProcessException catch (e) {
      onLine?.call(e.message);
      return false;
    }
  }

  /// Starts the freshly installed Finder once this process has exited;
  /// the caller exits right after. Started any sooner, the new Finder
  /// would find this one still running and hand its launch back to it.
  Future<void> relaunch() async {
    await Process.start('sh', [
      '-c',
      'while kill -0 "\$1" 2>/dev/null; do sleep 0.2; done; exec "\$0"',
      Platform.resolvedExecutable,
      '$pid',
    ], mode: ProcessStartMode.detached);
  }
}
