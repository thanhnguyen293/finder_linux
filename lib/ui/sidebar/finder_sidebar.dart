import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

import '../../l10n/app_localizations.dart';
import '../../models/place.dart';
import '../../models/tag_color.dart';
import '../../theme/finder_theme.dart';
import '../commands.dart';
import '../dnd/file_drag.dart';
import '../finder_scope.dart';
import '../settings/settings_dialog.dart';
import '../settings_scope.dart';
import '../widgets/context_menus.dart';
import '../widgets/hover_button.dart';
import '../widgets/tag_dots.dart';
import '../widgets/tag_picker.dart';

/// Sidebar glyph for each kind of place (also used in Settings).
/// Sidebar glyph for each kind of place (also used in Settings).
const placeIcons = <PlaceKind, IconData>{
  PlaceKind.home: CupertinoIcons.house,
  PlaceKind.desktop: CupertinoIcons.macwindow,
  PlaceKind.documents: CupertinoIcons.doc,
  PlaceKind.downloads: CupertinoIcons.arrow_down_circle,
  PlaceKind.pictures: CupertinoIcons.photo,
  PlaceKind.music: CupertinoIcons.music_note,
  PlaceKind.videos: CupertinoIcons.film,
  PlaceKind.bookmark: CupertinoIcons.folder,
  PlaceKind.computer: CupertinoIcons.desktopcomputer,
  PlaceKind.volume: CupertinoIcons.device_laptop,
  PlaceKind.trash: CupertinoIcons.trash,
};

class FinderSidebar extends StatelessWidget {
  const FinderSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scope = FinderScope.of(context);
    final hidden = SettingsScope.of(context).hiddenPlaces;
    return ColoredBox(
      color: context.palette.sidebar,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: ListenableBuilder(
              listenable: Listenable.merge([scope.sidebar, scope.browser]),
              builder: (context, _) {
                bool shown(Place p) => !hidden.contains(p.kind);
                final favorites = scope.sidebar.favorites.where(shown);
                final locations = scope.sidebar.locations.where(shown);
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  children: [
                    if (favorites.isNotEmpty) ...[
                      _SectionHeader(l10n.sectionFavorites),
                      for (final place in favorites) _PlaceRow(place: place),
                      const SizedBox(height: 14),
                    ],
                    if (locations.isNotEmpty) ...[
                      _SectionHeader(l10n.sectionLocations),
                      for (final place in locations) _PlaceRow(place: place),
                      const SizedBox(height: 14),
                    ],
                    _SectionHeader(l10n.sidebarTags),
                    for (final tag in TagColor.values) _TagRow(tag: tag),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: HoverButton(
                tooltip: l10n.menuSettings,
                onPressed: () => showFinderSettings(context),
                child: const Icon(CupertinoIcons.gear_alt, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
    child: Text(
      label,
      style: TextStyle(
        fontSize: FinderMetrics.fontSizeSmall,
        fontWeight: FontWeight.w700,
        color: context.palette.textSecondary,
      ),
    ),
  );
}

class _PlaceRow extends StatefulWidget {
  const _PlaceRow({required this.place});

  final Place place;

  @override
  State<_PlaceRow> createState() => _PlaceRowState();
}

class _PlaceRowState extends State<_PlaceRow> {
  bool _hover = false;

  String _label(AppLocalizations l10n) => switch (widget.place.kind) {
    PlaceKind.computer => l10n.placeComputer,
    PlaceKind.trash => l10n.placeTrash,
    _ => widget.place.label,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final scope = FinderScope.of(context);
    final place = widget.place;
    final selected = scope.browser.path == place.path;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Listener(
        onPointerDown: (e) {
          if (e.buttons & kSecondaryMouseButton != 0) {
            showPlaceMenu(context, e.position, place);
          } else if (e.buttons & kMiddleMouseButton != 0) {
            FinderCommands(context).newTab(place.path, false);
          }
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FinderCommands(context).goTo(place.path),
          child: FolderDropTarget(
            dir: place.path,
            toTrash: place.kind == PlaceKind.trash,
            builder: (context, hovering) => Container(
              height: context.scaled(FinderMetrics.sidebarRowHeight),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: hovering
                  ? dropHighlight(context)
                  : BoxDecoration(
                      color: selected
                          ? palette.sidebarSelection
                          : (_hover ? palette.controlHover : null),
                      borderRadius: BorderRadius.circular(
                        FinderMetrics.radiusSmall,
                      ),
                    ),
              child: Row(
                spacing: 8,
                children: [
                  Icon(placeIcons[place.kind], size: 16, color: palette.accent),
                  Expanded(
                    child: Text(
                      _label(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: FinderMetrics.fontSize,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                  if (place.kind == PlaceKind.volume)
                    HoverButton(
                      tooltip: l10n.tooltipEject,
                      padding: const EdgeInsets.all(2),
                      onPressed: () => scope.actions.eject(place.path),
                      child: const Icon(CupertinoIcons.eject, size: 13),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A color in the sidebar's Tags section; lists the files carrying it.
class _TagRow extends StatefulWidget {
  const _TagRow({required this.tag});

  final TagColor tag;

  @override
  State<_TagRow> createState() => _TagRowState();
}

class _TagRowState extends State<_TagRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = FinderScope.of(context).browser.tag == widget.tag;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FinderCommands(context).showTagged(widget.tag),
        child: Container(
          height: context.scaled(FinderMetrics.sidebarRowHeight),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? palette.sidebarSelection
                : (_hover ? palette.controlHover : null),
            borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
          ),
          child: Row(
            spacing: 8,
            children: [
              SizedBox(
                width: 16,
                child: Center(
                  child: TagDots(
                    tags: [widget.tag],
                    size: 11,
                    ring: tagSwatch(widget.tag),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  tagLabel(AppLocalizations.of(context), widget.tag),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FinderMetrics.fontSize,
                    color: palette.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
