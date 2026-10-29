import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../../theme/finder_theme.dart';
import '../finder_scope.dart';

/// Inline name editor. Like Finder it pre-selects the name without its
/// extension; Enter commits, Escape or losing focus cancels/commits.
class RenameField extends StatefulWidget {
  const RenameField({
    super.key,
    required this.name,
    this.textAlign = TextAlign.start,
  });

  final String name;
  final TextAlign textAlign;

  @override
  State<RenameField> createState() => _RenameFieldState();
}

class _RenameFieldState extends State<RenameField> {
  late final _controller = TextEditingController(text: widget.name);
  final _focus = FocusNode();
  bool _done = false;
  // Cached because the focus-loss commit can fire while this element is
  // being torn down, when inherited lookups are no longer allowed.
  late FinderScope _scope;

  @override
  void initState() {
    super.initState();
    final ext = p.extension(widget.name);
    final stemEnd = ext.isEmpty || ext == widget.name
        ? widget.name.length
        : widget.name.length - ext.length;
    _controller.selection = TextSelection(baseOffset: 0, extentOffset: stemEnd);
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit(refocus: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = FinderScope.of(context);
  }

  void _commit({bool refocus = true}) {
    if (_done) return;
    _done = true;
    if (_controller.text.trim() == widget.name) {
      _scope.browser.cancelRename();
    } else {
      _scope.actions.commitRename(_controller.text);
    }
    if (refocus) _scope.contentFocus.requestFocus();
  }

  void _cancel() {
    if (_done) return;
    _done = true;
    _scope.browser.cancelRename();
    _scope.contentFocus.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _cancel},
      child: Container(
        decoration: BoxDecoration(
          color: palette.content,
          border: Border.all(color: palette.accent, width: 2),
          borderRadius: BorderRadius.circular(3),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focus,
          textAlign: widget.textAlign,
          maxLines: 1,
          style: TextStyle(
            fontSize: FinderMetrics.fontSize,
            color: palette.textPrimary,
          ),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          ),
          onSubmitted: (_) => _commit(),
        ),
      ),
    );
  }
}
