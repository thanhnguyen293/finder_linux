import 'package:flutter/widgets.dart';

import '../../models/tag_color.dart';
import '../../theme/finder_theme.dart';

/// A file's color tags as small overlapping dots, as Finder draws them
/// after the name.
class TagDots extends StatelessWidget {
  const TagDots({super.key, required this.tags, this.size = 9, this.ring});

  final List<TagColor> tags;
  final double size;

  /// Outline separating overlapping dots; the row's background color.
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final ring = this.ring ?? context.palette.content;
    final step = size * 0.6;
    return SizedBox(
      width: size + step * (tags.length - 1),
      height: size,
      child: Stack(
        children: [
          for (final (i, tag) in tags.indexed)
            Positioned(
              left: step * i,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: tagSwatch(tag),
                  shape: BoxShape.circle,
                  border: Border.all(color: ring, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
