import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../models/tag_color.dart';
import 'xattr_tags.dart';

/// Finds files below a folder by name (find) or also by text content
/// (grep), streaming paths as they are found. Cancelling the stream
/// subscription stops the search process.
class SearchService {
  const SearchService();

  /// At most this many results; broad searches in big trees stop here.
  static const limit = 2000;

  Stream<String> search(
    String dir,
    String query, {
    required bool contents,
    required bool includeHidden,
  }) {
    final q = query.trim();
    if (q.isEmpty) return const Stream.empty();
    final controller = StreamController<String>();
    final processes = <Process>[];
    final seen = <String>{};
    var running = 0;

    Future<void> runOne(String exe, List<String> args) async {
      running++;
      try {
        final process = await Process.start(exe, args);
        processes.add(process);
        unawaited(process.stderr.drain<void>());
        await for (final line
            in process.stdout
                .transform(utf8.decoder)
                .transform(const LineSplitter())) {
          if (controller.isClosed) break;
          if (line.isEmpty || !seen.add(line)) continue;
          controller.add(line);
          if (seen.length >= limit) {
            _killAll(processes);
            break;
          }
        }
      } on ProcessException catch (e) {
        if (!controller.isClosed) controller.addError(e);
      } finally {
        if (--running == 0 && !controller.isClosed) await controller.close();
      }
    }

    controller
      ..onListen = () {
        unawaited(runOne('find', nameSearchArgs(dir, q, includeHidden)));
        if (contents) {
          unawaited(runOne('grep', contentSearchArgs(dir, q, includeHidden)));
        }
      }
      ..onCancel = () {
        _killAll(processes);
        return null;
      };
    return controller.stream;
  }

  /// Files below [dir] carrying [tag]. No command-line tool filters by
  /// extended attribute, so a background isolate walks the tree (hidden
  /// folders skipped unless [includeHidden]) and reads each file's tags.
  Stream<String> tagged(String dir, String tag, {required bool includeHidden}) {
    final controller = StreamController<String>();
    final port = ReceivePort();
    Isolate? isolate;
    var count = 0;
    port.listen((message) {
      if (message case final String path) {
        controller.add(path);
        if (++count >= limit) {
          isolate?.kill();
          port.close();
          controller.close();
        }
      } else {
        // null: the walk finished.
        port.close();
        controller.close();
      }
    });
    controller
      ..onListen = () async {
        isolate = await Isolate.spawn(_walkForTag, (
          port: port.sendPort,
          dir: dir,
          tag: tag,
          includeHidden: includeHidden,
        ));
        if (controller.isClosed) isolate?.kill();
      }
      ..onCancel = () {
        isolate?.kill();
        port.close();
        return null;
      };
    return controller.stream;
  }

  static void _killAll(List<Process> processes) {
    for (final p in processes) {
      p.kill();
    }
  }
}

/// `find` arguments: case-insensitive name match below [dir]; hidden
/// files and folders are skipped (pruned) unless [includeHidden].
List<String> nameSearchArgs(String dir, String query, bool includeHidden) => [
  dir,
  '-mindepth',
  '1',
  if (!includeHidden) ...['-name', '.*', '-prune', '-o'],
  '-iname',
  '*${escapeGlob(query)}*',
  '-print',
];

/// `grep` arguments: text files (binary skipped) containing [query],
/// case-insensitive, as a fixed string rather than a pattern.
List<String> contentSearchArgs(String dir, String query, bool includeHidden) =>
    [
      '-rIlF',
      '-i',
      if (!includeHidden) ...['--exclude-dir=.*', '--exclude=.*'],
      '--',
      query,
      dir,
    ];

/// Makes glob characters in a user's query match literally in `-iname`.
String escapeGlob(String text) =>
    text.replaceAllMapped(RegExp(r'[\\*?\[\]]'), (m) => '\\${m[0]}');

void _walkForTag(
  ({SendPort port, String dir, String tag, bool includeHidden}) job,
) {
  final wanted = TagColor.fromTag(job.tag);
  bool matches(String path) {
    final tags = readTags(path);
    return wanted == null
        ? tags.contains(job.tag)
        : tags.any((t) => TagColor.fromTag(t) == wanted);
  }

  void walk(Directory dir) {
    final List<FileSystemEntity> children;
    try {
      children = dir.listSync(followLinks: false);
    } on FileSystemException {
      return; // unreadable folder
    }
    for (final child in children) {
      final name = child.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      if (!job.includeHidden && name.startsWith('.')) continue;
      if (matches(child.path)) job.port.send(child.path);
      if (child is Directory) walk(child);
    }
  }

  walk(Directory(job.dir));
  job.port.send(null);
}
