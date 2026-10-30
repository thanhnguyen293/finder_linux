import 'package:flutter/foundation.dart';

enum PlaceKind {
  home,
  desktop,
  documents,
  downloads,
  pictures,
  music,
  videos,
  bookmark,
  computer,
  volume,
  trash,

  /// An Android emulator or phone reached through adb.
  device,
}

/// A sidebar destination.
@immutable
class Place {
  const Place({required this.kind, required this.path, required this.label});

  final PlaceKind kind;
  final String path;

  /// Display name; empty for places the UI localizes itself
  /// (computer, trash).
  final String label;

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.kind == kind &&
      other.path == path &&
      other.label == label;

  @override
  int get hashCode => Object.hash(kind, path, label);
}
