import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Finder'**
  String get appTitle;

  /// No description provided for @sectionFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sectionFavorites;

  /// No description provided for @sectionLocations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get sectionLocations;

  /// No description provided for @placeComputer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get placeComputer;

  /// No description provided for @placeTrash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get placeTrash;

  /// No description provided for @tooltipBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get tooltipBack;

  /// No description provided for @tooltipForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get tooltipForward;

  /// No description provided for @tooltipViewIcons.
  ///
  /// In en, this message translates to:
  /// **'View as Icons'**
  String get tooltipViewIcons;

  /// No description provided for @tooltipViewList.
  ///
  /// In en, this message translates to:
  /// **'View as List'**
  String get tooltipViewList;

  /// No description provided for @tooltipViewColumns.
  ///
  /// In en, this message translates to:
  /// **'View as Columns'**
  String get tooltipViewColumns;

  /// No description provided for @tooltipEject.
  ///
  /// In en, this message translates to:
  /// **'Eject'**
  String get tooltipEject;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchHint;

  /// No description provided for @columnName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get columnName;

  /// No description provided for @columnModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get columnModified;

  /// No description provided for @columnSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get columnSize;

  /// No description provided for @columnKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get columnKind;

  /// No description provided for @kindFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get kindFolder;

  /// No description provided for @kindImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get kindImage;

  /// No description provided for @kindVideo.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get kindVideo;

  /// No description provided for @kindAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get kindAudio;

  /// No description provided for @kindText.
  ///
  /// In en, this message translates to:
  /// **'Plain Text'**
  String get kindText;

  /// No description provided for @kindCode.
  ///
  /// In en, this message translates to:
  /// **'Source Code'**
  String get kindCode;

  /// No description provided for @kindPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF Document'**
  String get kindPdf;

  /// No description provided for @kindArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get kindArchive;

  /// No description provided for @kindDocument.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get kindDocument;

  /// No description provided for @kindSpreadsheet.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet'**
  String get kindSpreadsheet;

  /// No description provided for @kindPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get kindPresentation;

  /// No description provided for @kindApplication.
  ///
  /// In en, this message translates to:
  /// **'Application'**
  String get kindApplication;

  /// No description provided for @kindOther.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get kindOther;

  /// No description provided for @kindOtherExt.
  ///
  /// In en, this message translates to:
  /// **'{ext} File'**
  String kindOtherExt(String ext);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @selectedOfCount.
  ///
  /// In en, this message translates to:
  /// **'{selected} of {count} selected'**
  String selectedOfCount(int selected, int count);

  /// No description provided for @spaceAvailable.
  ///
  /// In en, this message translates to:
  /// **'{size} available'**
  String spaceAvailable(String size);

  /// No description provided for @emptyFolder.
  ///
  /// In en, this message translates to:
  /// **'Empty folder'**
  String get emptyFolder;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results for “{query}”'**
  String noResults(String query);

  /// No description provided for @todayAt.
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// No description provided for @yesterdayAt.
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(String time);

  /// No description provided for @menuOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get menuOpen;

  /// No description provided for @menuQuickLook.
  ///
  /// In en, this message translates to:
  /// **'Quick Look'**
  String get menuQuickLook;

  /// No description provided for @menuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get menuRename;

  /// No description provided for @menuDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get menuDuplicate;

  /// No description provided for @menuCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get menuCopy;

  /// No description provided for @menuCut.
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get menuCut;

  /// No description provided for @menuPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get menuPaste;

  /// No description provided for @menuMoveToTrash.
  ///
  /// In en, this message translates to:
  /// **'Move to Trash'**
  String get menuMoveToTrash;

  /// No description provided for @menuDeleteImmediately.
  ///
  /// In en, this message translates to:
  /// **'Delete Immediately…'**
  String get menuDeleteImmediately;

  /// No description provided for @menuPutBack.
  ///
  /// In en, this message translates to:
  /// **'Put Back'**
  String get menuPutBack;

  /// No description provided for @menuEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Empty Trash'**
  String get menuEmptyTrash;

  /// No description provided for @menuNewFolder.
  ///
  /// In en, this message translates to:
  /// **'New Folder'**
  String get menuNewFolder;

  /// No description provided for @menuGetInfo.
  ///
  /// In en, this message translates to:
  /// **'Get Info'**
  String get menuGetInfo;

  /// No description provided for @menuCopyPath.
  ///
  /// In en, this message translates to:
  /// **'Copy Path'**
  String get menuCopyPath;

  /// No description provided for @menuOpenInTerminal.
  ///
  /// In en, this message translates to:
  /// **'Open in Terminal'**
  String get menuOpenInTerminal;

  /// Opens a git folder in a code editor or IDE such as Visual Studio Code
  ///
  /// In en, this message translates to:
  /// **'Open in {app}'**
  String menuOpenInApp(String app);

  /// No description provided for @menuAddToSidebar.
  ///
  /// In en, this message translates to:
  /// **'Add to Sidebar'**
  String get menuAddToSidebar;

  /// No description provided for @menuRemoveFromSidebar.
  ///
  /// In en, this message translates to:
  /// **'Remove from Sidebar'**
  String get menuRemoveFromSidebar;

  /// No description provided for @menuShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show Hidden Files'**
  String get menuShowHidden;

  /// No description provided for @menuHideHidden.
  ///
  /// In en, this message translates to:
  /// **'Hide Hidden Files'**
  String get menuHideHidden;

  /// No description provided for @menuNewWindow.
  ///
  /// In en, this message translates to:
  /// **'New Window'**
  String get menuNewWindow;

  /// No description provided for @goToFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Go to Folder'**
  String get goToFolderTitle;

  /// No description provided for @goToFolderHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ~/Documents or /etc'**
  String get goToFolderHint;

  /// No description provided for @buttonGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get buttonGo;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get buttonOk;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete this item immediately?} other{Delete {count} items immediately?}}'**
  String deleteConfirmTitle(int count);

  /// No description provided for @deleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'You can’t undo this action.'**
  String get deleteConfirmBody;

  /// No description provided for @emptyTrashConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently erase the items in the Trash?'**
  String get emptyTrashConfirmTitle;

  /// No description provided for @infoKind.
  ///
  /// In en, this message translates to:
  /// **'Kind'**
  String get infoKind;

  /// No description provided for @infoSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get infoSize;

  /// No description provided for @infoWhere.
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get infoWhere;

  /// No description provided for @infoModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get infoModified;

  /// No description provided for @infoPermissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get infoPermissions;

  /// No description provided for @infoCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating…'**
  String get infoCalculating;

  /// No description provided for @untitledFolder.
  ///
  /// In en, this message translates to:
  /// **'untitled folder'**
  String get untitledFolder;

  /// No description provided for @copySuffix.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get copySuffix;

  /// No description provided for @pathCopied.
  ///
  /// In en, this message translates to:
  /// **'Path copied'**
  String get pathCopied;

  /// No description provided for @movedToTrash.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moved 1 item to Trash} other{Moved {count} items to Trash}}'**
  String movedToTrash(int count);

  /// No description provided for @errorFolderNotFound.
  ///
  /// In en, this message translates to:
  /// **'The folder “{path}” can’t be found.'**
  String errorFolderNotFound(String path);

  /// No description provided for @errorOperation.
  ///
  /// In en, this message translates to:
  /// **'The operation can’t be completed: {message}'**
  String errorOperation(String message);

  /// No description provided for @errorNameTaken.
  ///
  /// In en, this message translates to:
  /// **'The name “{name}” is already taken.'**
  String errorNameTaken(String name);

  /// No description provided for @errorInvalidName.
  ///
  /// In en, this message translates to:
  /// **'That name can’t be used.'**
  String get errorInvalidName;

  /// No description provided for @quickLookNoPreview.
  ///
  /// In en, this message translates to:
  /// **'No preview available'**
  String get quickLookNoPreview;

  /// No description provided for @tooltipGroupSort.
  ///
  /// In en, this message translates to:
  /// **'Group and Sort'**
  String get tooltipGroupSort;

  /// No description provided for @menuGroupBy.
  ///
  /// In en, this message translates to:
  /// **'Group By'**
  String get menuGroupBy;

  /// No description provided for @menuSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get menuSortBy;

  /// No description provided for @groupNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get groupNone;

  /// No description provided for @groupToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get groupToday;

  /// No description provided for @groupYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get groupYesterday;

  /// No description provided for @groupPrevious7Days.
  ///
  /// In en, this message translates to:
  /// **'Previous 7 Days'**
  String get groupPrevious7Days;

  /// No description provided for @groupPrevious30Days.
  ///
  /// In en, this message translates to:
  /// **'Previous 30 Days'**
  String get groupPrevious30Days;

  /// No description provided for @groupFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get groupFolders;

  /// No description provided for @groupOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get groupOther;

  /// No description provided for @sizeZero.
  ///
  /// In en, this message translates to:
  /// **'Zero bytes'**
  String get sizeZero;

  /// No description provided for @sizeLessThan.
  ///
  /// In en, this message translates to:
  /// **'Less than {size}'**
  String sizeLessThan(String size);

  /// No description provided for @sizeBetween.
  ///
  /// In en, this message translates to:
  /// **'{from} to {to}'**
  String sizeBetween(String from, String to);

  /// No description provided for @sizeAtLeast.
  ///
  /// In en, this message translates to:
  /// **'{size} or more'**
  String sizeAtLeast(String size);

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings…'**
  String get menuSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Finder Settings'**
  String get settingsTitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsSidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get settingsSidebar;

  /// No description provided for @settingsAdvanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get settingsAdvanced;

  /// No description provided for @settingsNewWindowsShow.
  ///
  /// In en, this message translates to:
  /// **'New windows show:'**
  String get settingsNewWindowsShow;

  /// No description provided for @settingsDefaultView.
  ///
  /// In en, this message translates to:
  /// **'Default view:'**
  String get settingsDefaultView;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance:'**
  String get settingsAppearance;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get settingsLanguage;

  /// No description provided for @settingsShowInSidebar.
  ///
  /// In en, this message translates to:
  /// **'Show these items in the sidebar:'**
  String get settingsShowInSidebar;

  /// No description provided for @settingsBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarked folders'**
  String get settingsBookmarks;

  /// No description provided for @settingsExternalDrives.
  ///
  /// In en, this message translates to:
  /// **'External drives'**
  String get settingsExternalDrives;

  /// No description provided for @settingsShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show hidden files'**
  String get settingsShowHidden;

  /// No description provided for @settingsFoldersOnTop.
  ///
  /// In en, this message translates to:
  /// **'Keep folders on top when sorting'**
  String get settingsFoldersOnTop;

  /// No description provided for @settingsThumbnails.
  ///
  /// In en, this message translates to:
  /// **'Show image previews in icons'**
  String get settingsThumbnails;

  /// No description provided for @settingsWarnEmptyTrash.
  ///
  /// In en, this message translates to:
  /// **'Show warning before emptying the Trash'**
  String get settingsWarnEmptyTrash;

  /// No description provided for @settingsNewWindowsNote.
  ///
  /// In en, this message translates to:
  /// **'Group, sort and view choices apply to open windows and new ones.'**
  String get settingsNewWindowsNote;

  /// No description provided for @appearanceSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appearanceSystem;

  /// No description provided for @appearanceLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appearanceLight;

  /// No description provided for @appearanceDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appearanceDark;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @viewIcons.
  ///
  /// In en, this message translates to:
  /// **'Icons'**
  String get viewIcons;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewColumns.
  ///
  /// In en, this message translates to:
  /// **'Columns'**
  String get viewColumns;

  /// No description provided for @placeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get placeHome;

  /// No description provided for @placeDesktop.
  ///
  /// In en, this message translates to:
  /// **'Desktop'**
  String get placeDesktop;

  /// No description provided for @placeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get placeDocuments;

  /// No description provided for @placeDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get placeDownloads;

  /// No description provided for @placePictures.
  ///
  /// In en, this message translates to:
  /// **'Pictures'**
  String get placePictures;

  /// No description provided for @placeMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get placeMusic;

  /// No description provided for @placeVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get placeVideos;

  /// No description provided for @tooltipNewTab.
  ///
  /// In en, this message translates to:
  /// **'New Tab'**
  String get tooltipNewTab;

  /// No description provided for @tooltipCloseTab.
  ///
  /// In en, this message translates to:
  /// **'Close Tab'**
  String get tooltipCloseTab;

  /// No description provided for @menuOpenInNewTab.
  ///
  /// In en, this message translates to:
  /// **'Open in New Tab'**
  String get menuOpenInNewTab;

  /// No description provided for @menuCloseOtherTabs.
  ///
  /// In en, this message translates to:
  /// **'Close Other Tabs'**
  String get menuCloseOtherTabs;

  /// No description provided for @menuMoveTabToNewWindow.
  ///
  /// In en, this message translates to:
  /// **'Move Tab to New Window'**
  String get menuMoveTabToNewWindow;

  /// No description provided for @menuMergeAllWindows.
  ///
  /// In en, this message translates to:
  /// **'Merge All Windows'**
  String get menuMergeAllWindows;

  /// No description provided for @mergedWindows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No other Finder windows to merge} =1{Merged 1 window} other{Merged {count} windows}}'**
  String mergedWindows(int count);

  /// No description provided for @settingsDisplay.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get settingsDisplay;

  /// No description provided for @settingsOpenFoldersInTabs.
  ///
  /// In en, this message translates to:
  /// **'Open folders in tabs instead of new windows'**
  String get settingsOpenFoldersInTabs;

  /// No description provided for @settingsAccentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent color:'**
  String get settingsAccentColor;

  /// No description provided for @settingsTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size:'**
  String get settingsTextSize;

  /// No description provided for @settingsIconSize.
  ///
  /// In en, this message translates to:
  /// **'Icon size:'**
  String get settingsIconSize;

  /// No description provided for @settingsShowPathBar.
  ///
  /// In en, this message translates to:
  /// **'Show path bar'**
  String get settingsShowPathBar;

  /// No description provided for @settingsShowStatusBar.
  ///
  /// In en, this message translates to:
  /// **'Show status bar'**
  String get settingsShowStatusBar;

  /// No description provided for @settingsShowExtensions.
  ///
  /// In en, this message translates to:
  /// **'Show all filename extensions'**
  String get settingsShowExtensions;

  /// No description provided for @settingsEnterRenames.
  ///
  /// In en, this message translates to:
  /// **'Press Enter to rename (macOS style)'**
  String get settingsEnterRenames;

  /// No description provided for @accentBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get accentBlue;

  /// No description provided for @accentPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get accentPurple;

  /// No description provided for @accentPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get accentPink;

  /// No description provided for @accentRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get accentRed;

  /// No description provided for @accentOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get accentOrange;

  /// No description provided for @accentYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get accentYellow;

  /// No description provided for @accentGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get accentGreen;

  /// No description provided for @accentGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get accentGraphite;

  /// No description provided for @splitDropHint.
  ///
  /// In en, this message translates to:
  /// **'Drop to show side by side'**
  String get splitDropHint;

  /// No description provided for @menuSplitView.
  ///
  /// In en, this message translates to:
  /// **'Show Side by Side'**
  String get menuSplitView;

  /// No description provided for @menuExitSplitView.
  ///
  /// In en, this message translates to:
  /// **'Exit Split View'**
  String get menuExitSplitView;

  /// No description provided for @settingsRestoreTabs.
  ///
  /// In en, this message translates to:
  /// **'Reopen tabs from last time'**
  String get settingsRestoreTabs;

  /// No description provided for @menuUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get menuUndo;

  /// No description provided for @menuRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get menuRedo;

  /// No description provided for @conflictTitle.
  ///
  /// In en, this message translates to:
  /// **'“{name}” already exists in “{folder}”'**
  String conflictTitle(String name, String folder);

  /// No description provided for @conflictBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to replace it? The item you replace goes to the Trash.'**
  String get conflictBody;

  /// No description provided for @conflictReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get conflictReplace;

  /// No description provided for @conflictKeepBoth.
  ///
  /// In en, this message translates to:
  /// **'Keep Both'**
  String get conflictKeepBoth;

  /// No description provided for @conflictSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get conflictSkip;

  /// No description provided for @conflictApplyToAll.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Do the same for the next conflict} other{Do the same for the next {count} conflicts}}'**
  String conflictApplyToAll(int count);

  /// No description provided for @transferCopying.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copying 1 item to “{dest}”} other{Copying {count} items to “{dest}”}}'**
  String transferCopying(int count, String dest);

  /// No description provided for @transferMoving.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Moving 1 item to “{dest}”} other{Moving {count} items to “{dest}”}}'**
  String transferMoving(int count, String dest);

  /// No description provided for @transferBytes.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String transferBytes(String done, String total);

  /// No description provided for @transferRemaining.
  ///
  /// In en, this message translates to:
  /// **'about {time} left'**
  String transferRemaining(String time);

  /// No description provided for @searchIn.
  ///
  /// In en, this message translates to:
  /// **'Search:'**
  String get searchIn;

  /// No description provided for @searchScopeSubfolders.
  ///
  /// In en, this message translates to:
  /// **'“{folder}” and subfolders'**
  String searchScopeSubfolders(String folder);

  /// No description provided for @searchScopeThisFolder.
  ///
  /// In en, this message translates to:
  /// **'This folder only'**
  String get searchScopeThisFolder;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get searchByName;

  /// No description provided for @searchByContents.
  ///
  /// In en, this message translates to:
  /// **'Name & Contents'**
  String get searchByContents;

  /// No description provided for @searching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searching;

  /// No description provided for @columnLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get columnLocation;

  /// No description provided for @tagRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get tagRed;

  /// No description provided for @tagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get tagOrange;

  /// No description provided for @tagYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get tagYellow;

  /// No description provided for @tagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get tagGreen;

  /// No description provided for @tagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get tagBlue;

  /// No description provided for @tagPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get tagPurple;

  /// No description provided for @tagGray.
  ///
  /// In en, this message translates to:
  /// **'Gray'**
  String get tagGray;

  /// No description provided for @sidebarTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get sidebarTags;

  /// Sidebar section listing Android emulators and phones reached through adb
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get sidebarDevices;

  /// Context menu item copying the selection to an Android emulator or phone
  ///
  /// In en, this message translates to:
  /// **'Send to {device}'**
  String menuSendTo(String device);

  /// No description provided for @sentToDevice.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Sent 1 item to {device}} other{Sent {count} items to {device}}}'**
  String sentToDevice(int count, String device);

  /// No description provided for @taggedIn.
  ///
  /// In en, this message translates to:
  /// **'Tagged {tag} in “{folder}”'**
  String taggedIn(String tag, String folder);

  /// No description provided for @tooltipRecentFolders.
  ///
  /// In en, this message translates to:
  /// **'Recent Folders'**
  String get tooltipRecentFolders;

  /// No description provided for @recentNone.
  ///
  /// In en, this message translates to:
  /// **'No recent folders'**
  String get recentNone;

  /// No description provided for @menuClearRecents.
  ///
  /// In en, this message translates to:
  /// **'Clear Menu'**
  String get menuClearRecents;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @themeEditingFor.
  ///
  /// In en, this message translates to:
  /// **'Colors for the {mode} appearance. Light and dark keep their own colors.'**
  String themeEditingFor(String mode);

  /// No description provided for @themeAccent.
  ///
  /// In en, this message translates to:
  /// **'Accent'**
  String get themeAccent;

  /// No description provided for @themeSelection.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get themeSelection;

  /// No description provided for @themeFolder.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get themeFolder;

  /// No description provided for @themeWindow.
  ///
  /// In en, this message translates to:
  /// **'Window background'**
  String get themeWindow;

  /// No description provided for @themeSidebar.
  ///
  /// In en, this message translates to:
  /// **'Sidebar'**
  String get themeSidebar;

  /// No description provided for @themeToolbar.
  ///
  /// In en, this message translates to:
  /// **'Toolbar'**
  String get themeToolbar;

  /// No description provided for @themeReset.
  ///
  /// In en, this message translates to:
  /// **'Use default'**
  String get themeReset;

  /// No description provided for @themeResetAll.
  ///
  /// In en, this message translates to:
  /// **'Reset All Colors'**
  String get themeResetAll;

  /// No description provided for @colorPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a Color'**
  String get colorPickerTitle;

  /// No description provided for @colorHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get colorHue;

  /// No description provided for @colorSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get colorSaturation;

  /// No description provided for @colorBrightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get colorBrightness;

  /// No description provided for @settingsUpdates.
  ///
  /// In en, this message translates to:
  /// **'Updates'**
  String get settingsUpdates;

  /// No description provided for @updateAutoCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for updates automatically'**
  String get updateAutoCheck;

  /// No description provided for @updateCheckNow.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get updateCheckNow;

  /// No description provided for @updateChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get updateChecking;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Finder is up to date.'**
  String get updateUpToDate;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'A new version of Finder is available.'**
  String get updateAvailable;

  /// No description provided for @updateInstall.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateInstall;

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Downloading and building the update. This can take a few minutes…'**
  String get updateInstalling;

  /// No description provided for @updateInstalled.
  ///
  /// In en, this message translates to:
  /// **'The update is installed.'**
  String get updateInstalled;

  /// No description provided for @updateRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart Finder'**
  String get updateRestart;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update: {reason}'**
  String updateFailed(String reason);

  /// No description provided for @updateUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This build can\'t update itself. Install it with install.sh to get updates.'**
  String get updateUnsupported;

  /// No description provided for @themeEffects.
  ///
  /// In en, this message translates to:
  /// **'Effects'**
  String get themeEffects;

  /// No description provided for @themeSidebarOpacity.
  ///
  /// In en, this message translates to:
  /// **'Sidebar opacity'**
  String get themeSidebarOpacity;

  /// No description provided for @themeWindowOpacity.
  ///
  /// In en, this message translates to:
  /// **'Window opacity'**
  String get themeWindowOpacity;

  /// No description provided for @themeGlass.
  ///
  /// In en, this message translates to:
  /// **'Glass style for menus, dialogs and panels'**
  String get themeGlass;

  /// No description provided for @themeBlurHint.
  ///
  /// In en, this message translates to:
  /// **'To blur the desktop behind Finder, install the GNOME extension “Blur my Shell” and turn it on for {appId}.'**
  String themeBlurHint(String appId);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'nl',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
