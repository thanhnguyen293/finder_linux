import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../services/places_service.dart';

/// Sidebar places. Volumes are polled because `/proc/mounts` can't be
/// watched with inotify.
class SidebarController extends ChangeNotifier {
  SidebarController(this._places);

  final PlacesService _places;
  List<Place> _favorites = const [];
  List<Place> _locations = const [];
  Timer? _poll;

  List<Place> get favorites => _favorites;
  List<Place> get locations => _locations;
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
    if (_disposed || listEquals(next, _locations)) return;
    _locations = next;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _poll?.cancel();
    super.dispose();
  }
}
