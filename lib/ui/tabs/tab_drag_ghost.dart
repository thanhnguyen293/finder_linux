import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

import '../../theme/finder_theme.dart';
import '../toolbar/finder_toolbar.dart';
import 'chrome_tab.dart';
import 'tab_drag.dart';

const _previewWidth = 360.0;

/// A tab pulled out of the strip, drawn as Chrome does: a small window -
/// the tab on top of a snapshot of its contents - following the pointer,
/// held at the spot where the tab was picked up.
class TabDragGhost extends StatelessWidget {
  const TabDragGhost({super.key, required this.tracker});

  final TabDragTracker tracker;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ListenableBuilder(
        listenable: tracker,
        builder: (context, _) {
          final tab = tracker.tab;
          final pointer = tracker.pointer;
          final box = context.findRenderObject();
          if (tab == null ||
              pointer == null ||
              tracker.nearStrip ||
              box is! RenderBox) {
            return const SizedBox.shrink();
          }
          final at = box.globalToLocal(pointer) - tracker.grab;
          return Stack(
            children: [
              Positioned(
                left: at.dx,
                top: at.dy,
                // Pops out slightly as it leaves the strip.
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.9, end: 1),
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(
                    scale: scale,
                    alignment: Alignment.topLeft,
                    child: child,
                  ),
                  child: Opacity(
                    opacity: 0.94,
                    child: _MiniWindow(
                      title: folderTitle(context, tab.browser.path),
                      preview: tracker.preview,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MiniWindow extends StatelessWidget {
  const _MiniWindow({required this.title, required this.preview});

  final String title;
  final ui.Image? preview;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final image = preview;
    final aspect = image == null ? 0.6 : image.height / image.width;
    final bodyHeight = (_previewWidth * aspect).clamp(120.0, 260.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: FinderMetrics.tabMaxWidth * 0.85,
          height: FinderMetrics.tabStripHeight - tabTopGap,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: palette.toolbar,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Row(
            spacing: 6,
            children: [
              Icon(CupertinoIcons.folder_fill, size: 14, color: palette.folder),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FinderMetrics.fontSizeSmall + 1,
                    color: palette.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: _previewWidth,
          height: bodyHeight,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: palette.content,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(FinderMetrics.radiusMedium),
              bottomLeft: Radius.circular(FinderMetrics.radiusMedium),
              bottomRight: Radius.circular(FinderMetrics.radiusMedium),
            ),
            border: Border.all(color: palette.separator),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: image == null
              ? Center(
                  child: Icon(
                    CupertinoIcons.folder_fill,
                    size: 48,
                    color: palette.folder,
                  ),
                )
              : RawImage(image: image, fit: BoxFit.cover),
        ),
      ],
    );
  }
}
