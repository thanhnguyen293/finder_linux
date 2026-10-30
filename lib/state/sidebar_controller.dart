import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../services/adb_service.dart';
import '../services/places_service.dart';

/// Sidebar places. Volumes and adb devices are polled: `/proc/mounts`
/// can't be watched with inotify, and adb has no change events.
class SidebarController extends ChangeNotifier {
  SidebarController(this._places, {this._adb});

  final PlacesService _places;
  final AdbService? _adb;
  List<Place> _favorites = const [];
  List<Place> _locations = const [];
  List<Place> _devices = const [];
  Timer? _poll;

  List<Place> get favorites => _favorites;
  List<Place> get locations => _locations;

  /// Running emulators and connected phones.
  List<Place> get devices => _devices;
  String get trashDir => _places.trashFilesDir;
  String get home => _places.home;

  bool isBookmarked(String path) =>
      _favorites.any((p) => p.kind == PlaceKind.bookmark && p.path == path);

  bool isFavorite(String path) => _favorites.any((p) => p.path == path);

  Future<void> start() async {
    // Started before the first await so dispose() always finds it.
    _poll = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _reloadLocations(),
    );
    await reload();
  }

  Future<void> reload() async {
    _favorites = await _places.favorites();
    _locations = await _places.locations();
    _devices = await _listDevices();
    if (!_disposed) notifyListeners();
  }

  Future<void> addBookmark(String path) async {
    await _places.addBookmark(path);
    await reload();
  }

  Future<void> removeBookmark(String path) async {
    await _places.removeBookmark(path);
    await reload();
  }

  Future<void> _reloadLocations() async {
    final next = await _places.locations();
    final devices = await _listDevices();
    if (_disposed ||
        (listEquals(next, _locations) && listEquals(devices, _devices))) {
      return;
    }
    _locations = next;
    _devices = devices;
    notifyListeners();
  }

  Future<List<Place>> _listDevices() async => [
    for (final d in await _adb?.devices() ?? const <AdbDevice>[])
      Place(
        kind: PlaceKind.device,
        path: deviceRootPath(d.serial),
        label: d.name,
      ),
  ];

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    super.dispose();
  }
}
