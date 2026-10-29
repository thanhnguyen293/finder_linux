import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// A tab handed from one window to another.
@immutable
class TabDescriptor {
  const TabDescriptor({required this.path, required this.viewMode});

  final String path;

  /// `ViewMode.name`; kept as text so the wire format stays simple.
  final String viewMode;

  Map<String, Object?> toJson() => {'path': path, 'viewMode': viewMode};

  static TabDescriptor? fromJson(Object? json) => switch (json) {
    {'path': final String path, 'viewMode': final String viewMode} =>
      TabDescriptor(path: path, viewMode: viewMode),
    _ => null,
  };
}

/// Lets the Finder windows of this user find each other. Every window is
/// its own process, so each listens on a Unix socket in
/// `$XDG_RUNTIME_DIR/finder-linux` (private to the user). "Merge All
/// Windows" asks every other window for its tabs; those windows then close.
class WindowRegistry {
  WindowRegistry({
    required String runtimeDir,
    required this.describeTabs,
    required this.surrender,
    this.openInTab,
    String? id,
  }) : _dir = Directory(p.join(runtimeDir, 'finder-linux')),
       _id = id ?? '$pid';

  final Directory _dir;
  final String _id;

  /// This window's tabs, in order.
  final List<TabDescriptor> Function() describeTabs;

  /// Closes this window after its tabs were handed over.
  final VoidCallback surrender;

  /// Opens a folder another Finder launch passed on (see [sendOpen]).
  final void Function(String path, String? select)? openInTab;

  ServerSocket? _server;

  String get _socketPath => p.join(_dir.path, '$_id.sock');

  Future<void> start() async {
    await _dir.create(recursive: true);
    final stale = File(_socketPath);
    if (stale.existsSync()) stale.deleteSync();
    _server = await ServerSocket.bind(_address(_socketPath), 0);
    _server?.listen(_serve);
  }

  Future<void> _serve(Socket client) async {
    try {
      final request = await _readLine(client);
      if (request case {
        'op': 'open',
        'path': final String path,
      } when openInTab != null) {
        final select = request['select'];
        client.write('${jsonEncode({'ok': true})}\n');
        await client.flush();
        await client.close();
        openInTab?.call(path, select is String ? select : null);
        return;
      }
      if (request is Map && request['op'] == 'surrender') {
        client.write(
          '${jsonEncode({
            'tabs': [for (final t in describeTabs()) t.toJson()],
          })}\n',
        );
        await client.flush();
        await client.close();
        surrender();
        return;
      }
    } on Object {
      // Malformed or abandoned request: drop it, keep serving others.
    }
    client.destroy();
  }

  /// Takes the tabs of every other open window, which close themselves.
  /// Returns one tab list per merged window.
  Future<List<List<TabDescriptor>>> collectOtherWindows() async {
    final merged = <List<TabDescriptor>>[];
    if (!_dir.existsSync()) return merged;
    for (final entry in _dir.listSync()) {
      if (entry.path == _socketPath || !entry.path.endsWith('.sock')) continue;
      Socket? socket;
      try {
        socket = await Socket.connect(
          _address(entry.path),
          0,
          timeout: const Duration(seconds: 1),
        );
        socket.write('${jsonEncode({'op': 'surrender'})}\n');
        await socket.flush();
        final reply = await _readLine(socket);
        final tabs = reply is Map ? reply['tabs'] : null;
        merged.add([
          if (tabs is List)
            for (final raw in tabs) ?TabDescriptor.fromJson(raw),
        ]);
      } on SocketException {
        // Nobody listens: a window that crashed left its socket behind.
        _deleteQuietly(entry);
      } on TimeoutException {
        // A hung window keeps its tabs; merging the others still succeeds.
      } finally {
        socket?.destroy();
      }
    }
    return merged;
  }

  /// Asks an open Finder window to show [path] in a new tab. Returns false
  /// when no window answered, so the caller opens its own window.
  static Future<bool> sendOpen({
    required String runtimeDir,
    required String path,
    String? select,
  }) async {
    final dir = Directory(p.join(runtimeDir, 'finder-linux'));
    if (!dir.existsSync()) return false;
    for (final entry in dir.listSync()) {
      if (!entry.path.endsWith('.sock')) continue;
      Socket? socket;
      try {
        socket = await Socket.connect(
          _address(entry.path),
          0,
          timeout: const Duration(milliseconds: 500),
        );
        socket.write(
          '${jsonEncode({'op': 'open', 'path': path, 'select': select})}\n',
        );
        await socket.flush();
        final reply = await utf8.decoder
            .bind(socket)
            .transform(const LineSplitter())
            .first
            .timeout(const Duration(seconds: 1));
        if (jsonDecode(reply) case {'ok': true}) return true;
      } on SocketException {
        _deleteQuietly(entry);
      } on Object {
        // Try the next window.
      } finally {
        socket?.destroy();
      }
    }
    return false;
  }

  Future<void> dispose() async {
    await _server?.close();
    _deleteQuietly(File(_socketPath));
  }

  Future<Object?> _readLine(Socket socket) async {
    final line = await utf8.decoder
        .bind(socket)
        .transform(const LineSplitter())
        .first
        .timeout(const Duration(seconds: 2));
    return jsonDecode(line);
  }

  static InternetAddress _address(String path) =>
      InternetAddress(path, type: InternetAddressType.unix);

  static void _deleteQuietly(FileSystemEntity entity) {
    try {
      entity.deleteSync();
    } on FileSystemException {
      // Already gone.
    }
  }
}
