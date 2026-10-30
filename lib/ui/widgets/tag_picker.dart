import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/tag_color.dart';
import '../../theme/finder_theme.dart';
import 'context_menus.dart';

/// Finder's row of color circles in a file's context menu: clicking one
/// adds that tag to the selection, or removes it when all items have it
/// (marked with a check).
class TagPickerEntry extends PopupMenuEntry<VoidCallback> {
  const TagPickerEntry({
    super.key,
    required this.tagged,
    required this.onToggle,
  });

  /// Tags every selected item already has.
  final Set<TagColor> tagged;
  final ValueChanged<TagColor> onToggle;

  @override
  double get height => 30;

  @override
  bool represents(VoidCallback? value) => false;

  @override
  State<TagPickerEntry> createState() => _TagPickerEntryState();
}

class _TagPickerEntryState extends State<TagPickerEntry> {
  @override
  Widget build(BuildContext context) {
    // The circles spread over the items' label width, the first and last
    // dots lining up with the labels' and shortcuts' edges.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14 - _dotInset),
      child: SizedBox(
        width: contextMenuContentWidth + 2 * _dotInset,
        height: widget.height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 2,
          children: [
            for (final tag in TagColor.values)
              _TagCircle(
                tag: tag,
                checked: widget.tagged.contains(tag),
                onTap: () => Navigator.pop<VoidCallback>(
                  context,
                  () => widget.onToggle(tag),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

const _ringSize = 22.0;
const _dotSize = 15.0;

/// Space between a circle's hover ring and its colored dot.
const _dotInset = (_ringSize - _dotSize) / 2;

class _TagCircle extends StatefulWidget {
  const _TagCircle({
    required this.tag,
    required this.checked,
    required this.onTap,
  });

  final TagColor tag;
  final bool checked;
  final VoidCallback onTap;

  @override
  State<_TagCircle> createState() => _TagCircleState();
}

class _TagCircleState extends State<_TagCircle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = tagSwatch(widget.tag);
    return Tooltip(
      message: tagLabel(AppLocalizations.of(context), widget.tag),
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: _ringSize,
            height: _ringSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Hover ring, like Finder's.
              border: Border.all(
                color: _hover
                    ? context.palette.textSecondary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Container(
              width: _dotSize,
              height: _dotSize,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: widget.checked
                  ? const Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 11,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

String tagLabel(AppLocalizations l10n, TagColor tag) => switch (tag) {
  TagColor.red => l10n.tagRed,
  TagColor.orange => l10n.tagOrange,
  TagColor.yellow => l10n.tagYellow,
  TagColor.green => l10n.tagGreen,
  TagColor.blue => l10n.tagBlue,
  TagColor.purple => l10n.tagPurple,
  TagColor.gray => l10n.tagGray,
};
