import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../core/result.dart';
import '../models/file_entry.dart';

/// Virtual folder holding the Android devices adb sees (emulators and
/// phones): `/@adb/<serial>/x` is `/sdcard/x` on that device. Keeping devices
/// on ordinary-looking paths lets navigation, history, tabs and the path bar
/// work unchanged; only the file services route these paths to adb.
const adbRoot = '/@adb';
const _storage = '/sdcard';

bool isDevicePath(String path) => p.isWithin(adbRoot, path);

/// A device's shared storage, as shown in the sidebar.
String deviceRootPath(String serial) => p.join(adbRoot, serial);

bool isDeviceRoot(String path) => p.dirname(path) == adbRoot;

/// The device serial and on-device path of a [isDevicePath] path.
({String serial, String remote}) deviceLocation(String path) {
  final parts = p.split(p.relative(path, from: adbRoot));
  return (serial: parts.first, remote: p.joinAll([_storage, ...parts.skip(1)]));
}

typedef AdbDevice = ({String serial, String name});

/// Where "Send to device" puts [entry] on the device at [deviceRoot]: the
/// standard media folders Android's gallery and music apps index, and
/// Download for everything else.
String sendTargetFor(FileEntry entry, String deviceRoot) => p.join(
  deviceRoot,
  entry.isDirectory
      ? 'Download'
      : switch (entry.kind) {
          FileKind.image => 'Pictures',
          FileKind.video => 'Movies',
          FileKind.audio => 'Music',
          _ => 'Download',
        },
);

/// Serials of the online devices in `adb devices` output (skipping ones
/// that are offline or unauthorized).
List<String> parseAdbDevices(String output) => [
  for (final line in output.split('\n').skip(1))
    if (line.trim().split(RegExp(r'\s+')) case [final serial, 'device', ...])
      serial,
];

// stat fields for one item; the name comes last as it may contain "|".
const _statFormat = '%F|%s|%Y|%a';

/// Entries of [dir] from `stat -c "$_statFormat|%n"` lines.
List<FileEntry> parseStatListing(String output, String dir) => [
  for (final line in output.split('\n'))
    if (line.split('|') case [
      _,
      _,
      _,
      _,
      ...final name,
    ] when name.join('|') != '.' && name.join('|') != '..')
      _entryFrom(line, p.join(dir, name.join('|'))),
];

FileEntry _entryFrom(String statLine, String path) {
  final f = statLine.split('|');
  return FileEntry(
    path: path,
    isDirectory: f[0] == 'directory',
    size: int.tryParse(f[1]) ?? 0,
    modified: DateTime.fromMillisecondsSinceEpoch(
      (int.tryParse(f[2]) ?? 0) * 1000,
    ),
    mode: int.tryParse(f[3], radix: 8) ?? 0,
  );
}

String _quote(String s) => "'${s.replaceAll("'", r"'\''")}'";

/// File operations on devices through the `adb` tool. Paths are the
/// virtual [adbRoot] ones, except the local side of [copy] and [move].
class AdbService {
  const AdbService({this.executable = 'adb'});

  final String executable;

  // AVD names don't change while an emulator runs and asking costs a
  // console round trip, so they're remembered per serial.
  static final _names = <String, String>{};

  Future<List<AdbDevice>> devices() async {
    final ProcessResult r;
    try {
      r = await Process.run(executable, ['devices']);
    } on ProcessException {
      return const []; // adb isn't installed.
    }
    return [
      for (final serial in parseAdbDevices(r.stdout as String))
        (serial: serial, name: _names[serial] ??= await _nameOf(serial)),
    ];
  }

  /// "Medium Phone API 37.0" for an emulator, the model for a phone.
  Future<String> _nameOf(String serial) async {
    final args = serial.startsWith('emulator-')
        ? ['-s', serial, 'emu', 'avd', 'name']
        : ['-s', serial, 'shell', 'getprop', 'ro.product.model'];
    try {
      final r = await Process.run(
        executable,
        args,
      ).timeout(const Duration(seconds: 3));
      final name = (r.stdout as String).split('\n').first.trim();
      return name.isEmpty ? serial : name.replaceAll('_', ' ');
    } on Object {
      return serial;
    }
  }

  Future<Result<List<FileEntry>>> list(String dir) async {
    final (:serial, :remote) = deviceLocation(dir);
    final q = _quote(remote);
    // -L follows links so linked folders act as folders; ".*" also matches
    // "." and "..", which the parser drops.
    final r = await _shell(
      serial,
      '[ -d $q ] || exit 2; cd $q 2>/dev/null || exit 13; '
      'stat -L -c "$_statFormat|%n" -- * .* 2>/dev/null; exit 0',
      path: dir,
    );
    return switch (r) {
      Ok(:final value) => Ok(parseStatListing(value, dir)),
      Err(:final failure) => Err(failure),
    };
  }

  Future<FileEntry?> entry(String path) async {
    final (:serial, :remote) = deviceLocation(path);
    final r = await _shell(
      serial,
      'stat -L -c "$_statFormat" -- ${_quote(remote)}',
    );
    return switch (r) {
      Ok(:final value) when value.trim().isNotEmpty => _entryFrom(
        value.trim(),
        path,
      ),
      _ => null,
    };
  }

  bool exists(String path) => _test('-e', path);
  bool isDirectory(String path) => _test('-d', path);

  // Synchronous because name picking (uniqueChildPath) is.
  bool _test(String flag, String path) {
    final (:serial, :remote) = deviceLocation(path);
    try {
      return Process.runSync(executable, [
            '-s',
            serial,
            'shell',
            '[ $flag ${_quote(remote)} ]',
          ]).exitCode ==
          0;
    } on ProcessException {
      return false;
    }
  }

  Future<Result<String>> mkdir(String path) async {
    final (:serial, :remote) = deviceLocation(path);
    final r = await _shell(serial, 'mkdir -- ${_quote(remote)}', path: path);
    return r is Err<String> ? Err(r.failure) : Ok(path);
  }

  /// Renames within one device, refusing to overwrite.
  Future<Result<String>> rename(String from, String to) async {
    final src = deviceLocation(from);
    final dest = deviceLocation(to);
    final r = await _shell(
      src.serial,
      '[ -e ${_quote(dest.remote)} ] && exit 17; '
      'mv -- ${_quote(src.remote)} ${_quote(dest.remote)}',
      path: to,
    );
    return r is Err<String> ? Err(r.failure) : Ok(to);
  }

  Future<Result<void>> delete(List<String> paths) async {
    for (final path in paths) {
      final (:serial, :remote) = deviceLocation(path);
      final r = await _shell(serial, 'rm -rf -- ${_quote(remote)}');
      if (r case Err(:final failure)) return Err(failure);
    }
    return const Ok(null);
  }

  /// Copies [source] to exactly [dest]; either side may be local.
  Future<Result<void>> copy(String source, String dest) async {
    final from = isDevicePath(source) ? deviceLocation(source) : null;
    final to = isDevicePath(dest) ? deviceLocation(dest) : null;
    switch ((from, to)) {
      case (final f?, final t?) when f.serial == t.serial:
        return _shell(
          f.serial,
          'cp -r -- ${_quote(f.remote)} ${_quote(t.remote)}',
        );
      case (final f?, final t?):
        // Between two devices: through a local temporary copy.
        final temp = await Directory.systemTemp.createTemp('finder-adb');
        try {
          final local = p.join(temp.path, p.basename(f.remote));
          final pulled = await _adb(['-s', f.serial, 'pull', f.remote, local]);
          if (pulled is Err) return pulled;
          return await _adb(['-s', t.serial, 'push', local, t.remote]);
        } finally {
          await temp.delete(recursive: true);
        }
      case (final f?, null):
        return _adb(['-s', f.serial, 'pull', '-a', f.remote, dest]);
      case (null, final t?):
        return _adb(['-s', t.serial, 'push', source, t.remote]);
      case _:
        return Err(Failure(FailureKind.other, source));
    }
  }

  /// Moves [source] to exactly [dest]: a rename on one device, otherwise
  /// a copy and then removing the source.
  Future<Result<void>> move(String source, String dest) async {
    if (isDevicePath(source) &&
        isDevicePath(dest) &&
        deviceLocation(source).serial == deviceLocation(dest).serial) {
      return rename(source, dest);
    }
    final copied = await copy(source, dest);
    if (copied is Err) return copied;
    if (isDevicePath(source)) return delete([source]);
    try {
      final local = FileSystemEntity.isDirectorySync(source)
          ? Directory(source)
          : File(source);
      await local.delete(recursive: true);
      return const Ok(null);
    } on FileSystemException catch (e) {
      return Err(Failure(FailureKind.other, e.message));
    }
  }

  /// Opens a device file with its default app, from a local copy.
  Future<Result<void>> open(String path) async {
    final local = await pullToTemp(path);
    if (local is! Ok<String>) return local;
    final r = await Process.run('gio', ['open', local.value]);
    return r.exitCode == 0
        ? const Ok(null)
        : Err(Failure(FailureKind.other, (r.stderr as String).trim()));
  }

  /// A fresh local copy of a device file (for opening or Quick Look), in
  /// a temporary folder per device.
  Future<Result<String>> pullToTemp(String path) async {
    final (:serial, :remote) = deviceLocation(path);
    final dir = Directory(
      p.join(Directory.systemTemp.path, 'finder-adb', serial),
    );
    await dir.create(recursive: true);
    final local = p.join(dir.path, p.basename(remote));
    if (FileSystemEntity.typeSync(local) != FileSystemEntityType.notFound) {
      await Process.run('rm', ['-rf', '--', local]);
    }
    final pulled = await _adb(['-s', serial, 'pull', '-a', remote, local]);
    return pulled is Err<String> ? Err(pulled.failure) : Ok(local);
  }

  /// Asks the devices holding [paths] to index new media, so copied photos
  /// and videos show up in their Gallery right away. Best effort.
  Future<void> scanMedia(Iterable<String> paths) async {
    for (final serial in {for (final x in paths) deviceLocation(x).serial}) {
      await _shell(
        serial,
        'content call --uri content://media --method scan_volume '
        '--arg external_primary',
      );
    }
  }

  Future<int?> freeSpace(String path) async {
    final r = await _shell(deviceLocation(path).serial, 'df -k $_storage/');
    if (r is! Ok<String>) return null;
    final fields = r.value.trim().split('\n').last.split(RegExp(r'\s+'));
    final kb = fields.length > 3 ? int.tryParse(fields[3]) : null;
    return kb == null ? null : kb * 1024;
  }

  Future<int?> directorySize(String path) async {
    final (:serial, :remote) = deviceLocation(path);
    final r = await _shell(serial, 'du -sk -- ${_quote(remote)}');
    if (r is! Ok<String>) return null;
    final kb = int.tryParse(r.value.split(RegExp(r'\s')).first);
    return kb == null ? null : kb * 1024;
  }

  /// Runs [script] in the device's shell. Exit codes 2, 13 and 17 stand
  /// for missing, permission denied and name taken (about [path]).
  Future<Result<String>> _shell(
    String serial,
    String script, {
    String path = '',
  }) => _adb(['-s', serial, 'shell', script], path: path);

  Future<Result<String>> _adb(List<String> args, {String path = ''}) async {
    try {
      final r = await Process.run(executable, args);
      if (r.exitCode == 0) return Ok(r.stdout as String);
      final message = '${r.stderr}'.trim();
      return Err(switch (r.exitCode) {
        2 => Failure(FailureKind.notFound, path),
        13 => Failure(FailureKind.permissionDenied, path),
        17 => Failure(FailureKind.nameTaken, p.basename(path)),
        _ when message.contains('Permission denied') => Failure(
          FailureKind.permissionDenied,
          message,
        ),
        _ => Failure(FailureKind.other, message),
      });
    } on ProcessException catch (e) {
      return Err(Failure(FailureKind.other, e.message));
    }
  }
}
