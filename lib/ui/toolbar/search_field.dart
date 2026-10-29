import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/finder_theme.dart';
import '../finder_scope.dart';

/// Filters the current folder by name. The query itself lives in
/// BrowserController; this only mirrors it into a text field.
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.focusNode});

  final FocusNode focusNode;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final _text = TextEditingController();
  late FinderScope _scope;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scope = FinderScope.of(context);
    _scope.browser.removeListener(_syncQuery);
    _scope.browser.addListener(_syncQuery);
  }

  /// Navigation clears the query; keep the field in step.
  void _syncQuery() {
    final query = _scope.browser.query;
    if (_text.text != query) _text.text = query;
  }

  @override
  void dispose() {
    _scope.browser.removeListener(_syncQuery);
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scope = FinderScope.of(context);
    final query = scope.browser.query;
    return SizedBox(
      width: 200,
      height: 28,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            scope.browser.setQuery('');
            scope.contentFocus.requestFocus();
          },
          const SingleActivator(LogicalKeyboardKey.arrowDown):
              scope.contentFocus.requestFocus,
        },
        child: TextField(
          controller: _text,
          focusNode: widget.focusNode,
          onChanged: scope.browser.setQuery,
          onSubmitted: (_) => scope.contentFocus.requestFocus(),
          style: TextStyle(
            fontSize: FinderMetrics.fontSize,
            color: palette.textPrimary,
          ),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: palette.controlHover,
            hintText: AppLocalizations.of(context).searchHint,
            hintStyle: TextStyle(color: palette.textSecondary),
            prefixIcon: Icon(
              CupertinoIcons.search,
              size: 15,
              color: palette.textSecondary,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 30),
            suffixIcon: query.isEmpty
                ? null
                : GestureDetector(
                    onTap: () => scope.browser.setQuery(''),
                    child: Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 15,
                      color: palette.textSecondary,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FinderMetrics.radiusMedium),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(FinderMetrics.radiusMedium),
              borderSide: BorderSide(
                color: palette.accent.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
