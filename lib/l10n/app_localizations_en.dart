// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favorites';

  @override
  String get sectionLocations => 'Locations';

  @override
  String get placeComputer => 'Computer';

  @override
  String get placeTrash => 'Trash';

  @override
  String get tooltipBack => 'Back';

  @override
  String get tooltipForward => 'Forward';

  @override
  String get tooltipViewIcons => 'View as Icons';

  @override
  String get tooltipViewList => 'View as List';

  @override
  String get tooltipViewColumns => 'View as Columns';

  @override
  String get tooltipEject => 'Eject';

  @override
  String get searchHint => 'Search';

  @override
  String get columnName => 'Name';

  @override
  String get columnModified => 'Date Modified';

  @override
  String get columnSize => 'Size';

  @override
  String get columnKind => 'Kind';

  @override
  String get kindFolder => 'Folder';

  @override
  String get kindImage => 'Image';

  @override
  String get kindVideo => 'Movie';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Plain Text';

  @override
  String get kindCode => 'Source Code';

  @override
  String get kindPdf => 'PDF Document';

  @override
  String get kindArchive => 'Archive';

  @override
  String get kindDocument => 'Document';

  @override
  String get kindSpreadsheet => 'Spreadsheet';

  @override
  String get kindPresentation => 'Presentation';

  @override
  String get kindApplication => 'Application';

  @override
  String get kindOther => 'Document';

  @override
  String kindOtherExt(String ext) {
    return '$ext File';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected of $count selected';
  }

  @override
  String spaceAvailable(String size) {
    return '$size available';
  }

  @override
  String get emptyFolder => 'Empty folder';

  @override
  String noResults(String query) {
    return 'No results for “$query”';
  }

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String get menuOpen => 'Open';

  @override
  String get menuQuickLook => 'Quick Look';

  @override
  String get menuRename => 'Rename';

  @override
  String get menuDuplicate => 'Duplicate';

  @override
  String get menuCopy => 'Copy';

  @override
  String get menuCut => 'Cut';

  @override
  String get menuPaste => 'Paste';

  @override
  String get menuMoveToTrash => 'Move to Trash';

  @override
  String get menuDeleteImmediately => 'Delete Immediately…';

  @override
  String get menuPutBack => 'Put Back';

  @override
  String get menuEmptyTrash => 'Empty Trash';

  @override
  String get menuNewFolder => 'New Folder';

  @override
  String get menuGetInfo => 'Get Info';

  @override
  String get menuCopyPath => 'Copy Path';

  @override
  String get menuOpenInTerminal => 'Open in Terminal';

  @override
  String get menuAddToSidebar => 'Add to Sidebar';

  @override
  String get menuRemoveFromSidebar => 'Remove from Sidebar';

  @override
  String get menuShowHidden => 'Show Hidden Files';

  @override
  String get menuHideHidden => 'Hide Hidden Files';

  @override
  String get menuNewWindow => 'New Window';

  @override
  String get goToFolderTitle => 'Go to Folder';

  @override
  String get goToFolderHint => 'e.g. ~/Documents or /etc';

  @override
  String get buttonGo => 'Go';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count items immediately?',
      one: 'Delete this item immediately?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'You can’t undo this action.';

  @override
  String get emptyTrashConfirmTitle =>
      'Permanently erase the items in the Trash?';

  @override
  String get infoKind => 'Kind';

  @override
  String get infoSize => 'Size';

  @override
  String get infoWhere => 'Where';

  @override
  String get infoModified => 'Modified';

  @override
  String get infoPermissions => 'Permissions';

  @override
  String get infoCalculating => 'Calculating…';

  @override
  String get untitledFolder => 'untitled folder';

  @override
  String get copySuffix => 'copy';

  @override
  String get pathCopied => 'Path copied';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moved $count items to Trash',
      one: 'Moved 1 item to Trash',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'The folder “$path” can’t be found.';
  }

  @override
  String errorOperation(String message) {
    return 'The operation can’t be completed: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'The name “$name” is already taken.';
  }

  @override
  String get errorInvalidName => 'That name can’t be used.';

  @override
  String get quickLookNoPreview => 'No preview available';

  @override
  String get tooltipGroupSort => 'Group and Sort';

  @override
  String get menuGroupBy => 'Group By';

  @override
  String get menuSortBy => 'Sort By';

  @override
  String get groupNone => 'None';

  @override
  String get groupToday => 'Today';

  @override
  String get groupYesterday => 'Yesterday';

  @override
  String get groupPrevious7Days => 'Previous 7 Days';

  @override
  String get groupPrevious30Days => 'Previous 30 Days';

  @override
  String get groupFolders => 'Folders';

  @override
  String get groupOther => 'Other';

  @override
  String get sizeZero => 'Zero bytes';

  @override
  String sizeLessThan(String size) {
    return 'Less than $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from to $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size or more';
  }

  @override
  String get menuSettings => 'Settings…';

  @override
  String get settingsTitle => 'Finder Settings';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsSidebar => 'Sidebar';

  @override
  String get settingsAdvanced => 'Advanced';

  @override
  String get settingsNewWindowsShow => 'New windows show:';

  @override
  String get settingsDefaultView => 'Default view:';

  @override
  String get settingsAppearance => 'Appearance:';

  @override
  String get settingsLanguage => 'Language:';

  @override
  String get settingsShowInSidebar => 'Show these items in the sidebar:';

  @override
  String get settingsBookmarks => 'Bookmarked folders';

  @override
  String get settingsExternalDrives => 'External drives';

  @override
  String get settingsShowHidden => 'Show hidden files';

  @override
  String get settingsFoldersOnTop => 'Keep folders on top when sorting';

  @override
  String get settingsThumbnails => 'Show image previews in icons';

  @override
  String get settingsWarnEmptyTrash => 'Show warning before emptying the Trash';

  @override
  String get settingsNewWindowsNote =>
      'Group, sort and view choices apply to open windows and new ones.';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Light';

  @override
  String get appearanceDark => 'Dark';

  @override
  String get languageSystem => 'System';

  @override
  String get viewIcons => 'Icons';

  @override
  String get viewList => 'List';

  @override
  String get viewColumns => 'Columns';

  @override
  String get placeHome => 'Home';

  @override
  String get placeDesktop => 'Desktop';

  @override
  String get placeDocuments => 'Documents';

  @override
  String get placeDownloads => 'Downloads';

  @override
  String get placePictures => 'Pictures';

  @override
  String get placeMusic => 'Music';

  @override
  String get placeVideos => 'Videos';

  @override
  String get tooltipNewTab => 'New Tab';

  @override
  String get tooltipCloseTab => 'Close Tab';

  @override
  String get menuOpenInNewTab => 'Open in New Tab';

  @override
  String get menuCloseOtherTabs => 'Close Other Tabs';

  @override
  String get menuMoveTabToNewWindow => 'Move Tab to New Window';

  @override
  String get menuMergeAllWindows => 'Merge All Windows';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Merged $count windows',
      one: 'Merged 1 window',
      zero: 'No other Finder windows to merge',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Display';

  @override
  String get settingsOpenFoldersInTabs =>
      'Open folders in tabs instead of new windows';

  @override
  String get settingsAccentColor => 'Accent color:';

  @override
  String get settingsTextSize => 'Text size:';

  @override
  String get settingsIconSize => 'Icon size:';

  @override
  String get settingsShowPathBar => 'Show path bar';

  @override
  String get settingsShowStatusBar => 'Show status bar';

  @override
  String get settingsShowExtensions => 'Show all filename extensions';

  @override
  String get settingsEnterRenames => 'Press Enter to rename (macOS style)';

  @override
  String get accentBlue => 'Blue';

  @override
  String get accentPurple => 'Purple';

  @override
  String get accentPink => 'Pink';

  @override
  String get accentRed => 'Red';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentYellow => 'Yellow';

  @override
  String get accentGreen => 'Green';

  @override
  String get accentGraphite => 'Graphite';

  @override
  String get splitDropHint => 'Drop to show side by side';

  @override
  String get menuSplitView => 'Show Side by Side';

  @override
  String get menuExitSplitView => 'Exit Split View';

  @override
  String get settingsRestoreTabs => 'Reopen tabs from last time';

  @override
  String get menuUndo => 'Undo';

  @override
  String get menuRedo => 'Redo';

  @override
  String conflictTitle(String name, String folder) {
    return '“$name” already exists in “$folder”';
  }

  @override
  String get conflictBody =>
      'Do you want to replace it? The item you replace goes to the Trash.';

  @override
  String get conflictReplace => 'Replace';

  @override
  String get conflictKeepBoth => 'Keep Both';

  @override
  String get conflictSkip => 'Skip';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Do the same for the next $count conflicts',
      one: 'Do the same for the next conflict',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copying $count items to “$dest”',
      one: 'Copying 1 item to “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Moving $count items to “$dest”',
      one: 'Moving 1 item to “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done of $total';
  }

  @override
  String transferRemaining(String time) {
    return 'about $time left';
  }

  @override
  String get searchIn => 'Search:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” and subfolders';
  }

  @override
  String get searchScopeThisFolder => 'This folder only';

  @override
  String get searchByName => 'Name';

  @override
  String get searchByContents => 'Name & Contents';

  @override
  String get searching => 'Searching…';

  @override
  String get columnLocation => 'Location';

  @override
  String get tagRed => 'Red';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagYellow => 'Yellow';

  @override
  String get tagGreen => 'Green';

  @override
  String get tagBlue => 'Blue';

  @override
  String get tagPurple => 'Purple';

  @override
  String get tagGray => 'Gray';

  @override
  String get sidebarTags => 'Tags';

  @override
  String get sidebarDevices => 'Devices';

  @override
  String taggedIn(String tag, String folder) {
    return 'Tagged $tag in “$folder”';
  }

  @override
  String get tooltipRecentFolders => 'Recent Folders';

  @override
  String get recentNone => 'No recent folders';

  @override
  String get menuClearRecents => 'Clear Menu';

  @override
  String get settingsTheme => 'Theme';

  @override
  String themeEditingFor(String mode) {
    return 'Colors for the $mode appearance. Light and dark keep their own colors.';
  }

  @override
  String get themeAccent => 'Accent';

  @override
  String get themeSelection => 'Selection';

  @override
  String get themeFolder => 'Folders';

  @override
  String get themeWindow => 'Window background';

  @override
  String get themeSidebar => 'Sidebar';

  @override
  String get themeToolbar => 'Toolbar';

  @override
  String get themeReset => 'Use default';

  @override
  String get themeResetAll => 'Reset All Colors';

  @override
  String get colorPickerTitle => 'Choose a Color';

  @override
  String get colorHue => 'Hue';

  @override
  String get colorSaturation => 'Saturation';

  @override
  String get colorBrightness => 'Brightness';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get updateAutoCheck => 'Check for updates automatically';

  @override
  String get updateCheckNow => 'Check Now';

  @override
  String get updateChecking => 'Checking for updates…';

  @override
  String get updateUpToDate => 'Finder is up to date.';

  @override
  String get updateAvailable => 'A new version of Finder is available.';

  @override
  String get updateInstall => 'Update Now';

  @override
  String get updateInstalling =>
      'Downloading and building the update. This can take a few minutes…';

  @override
  String get updateInstalled => 'The update is installed.';

  @override
  String get updateRestart => 'Restart Finder';

  @override
  String updateFailed(String reason) {
    return 'Couldn\'t update: $reason';
  }

  @override
  String get updateUnsupported =>
      'This build can\'t update itself. Install it with install.sh to get updates.';

  @override
  String get themeEffects => 'Effects';

  @override
  String get themeSidebarOpacity => 'Sidebar opacity';

  @override
  String get themeWindowOpacity => 'Window opacity';

  @override
  String get themeGlass => 'Glass style for menus, dialogs and panels';

  @override
  String themeBlurHint(String appId) {
    return 'To blur the desktop behind Finder, install the GNOME extension “Blur my Shell” and turn it on for $appId.';
  }
}
