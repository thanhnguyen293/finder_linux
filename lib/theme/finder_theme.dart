import 'package:flutter/material.dart';

/// Spacing, sizes and radii shared by every Finder surface.
abstract final class FinderMetrics {
  static const toolbarHeight = 52.0;
  static const tabStripHeight = 36.0;
  static const tabMinWidth = 72.0;
  static const tabMaxWidth = 220.0;
  static const sidebarMinWidth = 150.0;
  static const sidebarMaxWidth = 320.0;
  static const sidebarDefaultWidth = 200.0;
  static const sidebarRowHeight = 28.0;
  static const listRowHeight = 24.0;
  static const listHeaderHeight = 26.0;
  static const pathBarHeight = 26.0;
  static const statusBarHeight = 24.0;
  static const columnWidth = 230.0;
  static const iconTileWidth = 104.0;
  static const iconTileHeight = 120.0;
  static const iconSize = 64.0;
  static const radiusSmall = 5.0;
  static const radiusMedium = 8.0;
  static const radiusLarge = 12.0;
  static const windowRadius = 10.0;
  static const gap = 8.0;
  static const fontSize = 13.0;
  static const fontSizeSmall = 11.0;
}

/// macOS-like colours, light and dark.
@immutable
class FinderPalette extends ThemeExtension<FinderPalette> {
  const FinderPalette({
    required this.content,
    required this.sidebar,
    required this.toolbar,
    required this.tabStrip,
    required this.separator,
    required this.accent,
    required this.selection,
    required this.selectionInactive,
    required this.sidebarSelection,
    required this.rowAlternate,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.folder,
    required this.control,
    required this.controlHover,
    required this.trafficClose,
    required this.trafficMinimize,
    required this.trafficZoom,
  });

  final Color content;
  final Color sidebar;
  final Color toolbar;

  /// Background behind inactive tabs; the active tab takes [toolbar].
  final Color tabStrip;
  final Color separator;
  final Color accent;
  final Color selection;
  final Color selectionInactive;
  final Color sidebarSelection;
  final Color rowAlternate;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color folder;
  final Color control;
  final Color controlHover;
  final Color trafficClose;
  final Color trafficMinimize;
  final Color trafficZoom;

  static const light = FinderPalette(
    content: Color(0xFFFFFFFF),
    sidebar: Color(0xFFEDEBEE),
    toolbar: Color(0xFFFAFAFA),
    tabStrip: Color(0xFFE3E1E5),
    separator: Color(0xFFDADADA),
    accent: Color(0xFF007AFF),
    selection: Color(0xFF0064E1),
    selectionInactive: Color(0xFFDCDCDC),
    sidebarSelection: Color(0xFFD8D6DA),
    rowAlternate: Color(0xFFF4F5F5),
    textPrimary: Color(0xFF1D1D1F),
    textSecondary: Color(0xFF86868B),
    textOnAccent: Color(0xFFFFFFFF),
    folder: Color(0xFF3FA9F5),
    control: Color(0x00000000),
    controlHover: Color(0x14000000),
    trafficClose: Color(0xFFFF5F57),
    trafficMinimize: Color(0xFFFEBC2E),
    trafficZoom: Color(0xFF28C840),
  );

  static const dark = FinderPalette(
    content: Color(0xFF1E1E1E),
    sidebar: Color(0xFF29282B),
    toolbar: Color(0xFF2B2B2D),
    tabStrip: Color(0xFF1C1B1E),
    separator: Color(0xFF3A3A3C),
    accent: Color(0xFF0A84FF),
    selection: Color(0xFF0059D1),
    selectionInactive: Color(0xFF464646),
    sidebarSelection: Color(0xFF424145),
    rowAlternate: Color(0xFF252526),
    textPrimary: Color(0xFFE8E8EA),
    textSecondary: Color(0xFF98989D),
    textOnAccent: Color(0xFFFFFFFF),
    folder: Color(0xFF4BA8F0),
    control: Color(0x00FFFFFF),
    controlHover: Color(0x1FFFFFFF),
    trafficClose: Color(0xFFFF5F57),
    trafficMinimize: Color(0xFFFEBC2E),
    trafficZoom: Color(0xFF28C840),
  );

  @override
  FinderPalette copyWith() => this;

  @override
  FinderPalette lerp(FinderPalette? other, double t) =>
      t < 0.5 || other == null ? this : other;
}

extension FinderThemeContext on BuildContext {
  FinderPalette get palette => Theme.of(this).extension<FinderPalette>()!;
}

ThemeData buildFinderTheme(Brightness brightness) {
  final palette = brightness == Brightness.light
      ? FinderPalette.light
      : FinderPalette.dark;
  final base = ThemeData(
    brightness: brightness,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.accent,
      brightness: brightness,
      primary: palette.accent,
      surface: palette.content,
    ),
    scaffoldBackgroundColor: palette.content,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    fontFamily: 'Ubuntu Sans',
    fontFamilyFallback: const ['Inter', 'Ubuntu', 'Cantarell', 'Noto Sans'],
    visualDensity: VisualDensity.compact,
    extensions: [palette],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: palette.textPrimary,
      displayColor: palette.textPrimary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: palette.toolbar,
      elevation: 8,
      menuPadding: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FinderMetrics.radiusMedium),
        side: BorderSide(color: palette.separator, width: 0.5),
      ),
      textStyle: TextStyle(
        fontSize: FinderMetrics.fontSize,
        color: palette.textPrimary,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 600),
      textStyle: TextStyle(
        fontSize: FinderMetrics.fontSizeSmall,
        color: palette.textPrimary,
      ),
      decoration: BoxDecoration(
        color: palette.toolbar,
        borderRadius: BorderRadius.circular(FinderMetrics.radiusSmall),
        border: Border.all(color: palette.separator),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.toolbar,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FinderMetrics.radiusLarge),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      width: 360,
      backgroundColor: palette.textPrimary,
      contentTextStyle: TextStyle(
        color: palette.content,
        fontSize: FinderMetrics.fontSize,
      ),
    ),
  );
}
