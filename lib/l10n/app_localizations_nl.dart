// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favorieten';

  @override
  String get sectionLocations => 'Locaties';

  @override
  String get placeComputer => 'Computer';

  @override
  String get placeTrash => 'Prullenmand';

  @override
  String get tooltipBack => 'Terug';

  @override
  String get tooltipForward => 'Vooruit';

  @override
  String get tooltipViewIcons => 'Als symbolen';

  @override
  String get tooltipViewList => 'Als lijst';

  @override
  String get tooltipViewColumns => 'Als kolommen';

  @override
  String get tooltipEject => 'Verwijder';

  @override
  String get searchHint => 'Zoek';

  @override
  String get columnName => 'Naam';

  @override
  String get columnModified => 'Wijzigingsdatum';

  @override
  String get columnSize => 'Grootte';

  @override
  String get columnKind => 'Soort';

  @override
  String get kindFolder => 'Map';

  @override
  String get kindImage => 'Afbeelding';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Platte tekst';

  @override
  String get kindCode => 'Broncode';

  @override
  String get kindPdf => 'PDF-document';

  @override
  String get kindArchive => 'Archief';

  @override
  String get kindDocument => 'Document';

  @override
  String get kindSpreadsheet => 'Spreadsheet';

  @override
  String get kindPresentation => 'Presentatie';

  @override
  String get kindApplication => 'Programma';

  @override
  String get kindOther => 'Document';

  @override
  String kindOtherExt(String ext) {
    return '$ext-bestand';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen',
      one: '1 onderdeel',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected van $count geselecteerd';
  }

  @override
  String spaceAvailable(String size) {
    return '$size beschikbaar';
  }

  @override
  String get emptyFolder => 'Lege map';

  @override
  String noResults(String query) {
    return 'Geen resultaten voor ‘$query’';
  }

  @override
  String todayAt(String time) {
    return 'Vandaag om $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Gisteren om $time';
  }

  @override
  String get menuOpen => 'Open';

  @override
  String get menuQuickLook => 'Quick Look';

  @override
  String get menuRename => 'Wijzig naam';

  @override
  String get menuDuplicate => 'Dupliceer';

  @override
  String get menuCopy => 'Kopieer';

  @override
  String get menuCut => 'Knip';

  @override
  String get menuPaste => 'Plak';

  @override
  String get menuMoveToTrash => 'Verplaats naar prullenmand';

  @override
  String get menuDeleteImmediately => 'Verwijder direct…';

  @override
  String get menuPutBack => 'Zet terug';

  @override
  String get menuEmptyTrash => 'Leeg prullenmand';

  @override
  String get menuNewFolder => 'Nieuwe map';

  @override
  String get menuGetInfo => 'Toon info';

  @override
  String get menuCopyPath => 'Kopieer pad';

  @override
  String get menuOpenInTerminal => 'Open in Terminal';

  @override
  String get menuAddToSidebar => 'Voeg toe aan navigatiekolom';

  @override
  String get menuRemoveFromSidebar => 'Verwijder uit navigatiekolom';

  @override
  String get menuShowHidden => 'Toon verborgen bestanden';

  @override
  String get menuHideHidden => 'Verberg verborgen bestanden';

  @override
  String get menuNewWindow => 'Nieuw venster';

  @override
  String get goToFolderTitle => 'Ga naar map';

  @override
  String get goToFolderHint => 'bijv. ~/Documents of /etc';

  @override
  String get buttonGo => 'Ga';

  @override
  String get buttonCancel => 'Annuleer';

  @override
  String get buttonDelete => 'Verwijder';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen direct verwijderen?',
      one: 'Dit onderdeel direct verwijderen?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody =>
      'Deze actie kan niet ongedaan worden gemaakt.';

  @override
  String get emptyTrashConfirmTitle =>
      'Onderdelen in de prullenmand definitief wissen?';

  @override
  String get infoKind => 'Soort';

  @override
  String get infoSize => 'Grootte';

  @override
  String get infoWhere => 'Locatie';

  @override
  String get infoModified => 'Gewijzigd';

  @override
  String get infoPermissions => 'Toegangsrechten';

  @override
  String get infoCalculating => 'Bezig met berekenen…';

  @override
  String get untitledFolder => 'naamloze map';

  @override
  String get copySuffix => 'kopie';

  @override
  String get pathCopied => 'Pad gekopieerd';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen naar de prullenmand verplaatst',
      one: '1 onderdeel naar de prullenmand verplaatst',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'De map ‘$path’ kan niet worden gevonden.';
  }

  @override
  String errorOperation(String message) {
    return 'De bewerking kan niet worden voltooid: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'De naam ‘$name’ is al in gebruik.';
  }

  @override
  String get errorInvalidName => 'Die naam kan niet worden gebruikt.';

  @override
  String get quickLookNoPreview => 'Geen voorvertoning beschikbaar';

  @override
  String get tooltipGroupSort => 'Groepeer en sorteer';

  @override
  String get menuGroupBy => 'Groepeer op';

  @override
  String get menuSortBy => 'Sorteer op';

  @override
  String get groupNone => 'Geen';

  @override
  String get groupToday => 'Vandaag';

  @override
  String get groupYesterday => 'Gisteren';

  @override
  String get groupPrevious7Days => 'Afgelopen 7 dagen';

  @override
  String get groupPrevious30Days => 'Afgelopen 30 dagen';

  @override
  String get groupFolders => 'Mappen';

  @override
  String get groupOther => 'Overig';

  @override
  String get sizeZero => 'Nul bytes';

  @override
  String sizeLessThan(String size) {
    return 'Minder dan $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from tot $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size of meer';
  }

  @override
  String get menuSettings => 'Instellingen…';

  @override
  String get settingsTitle => 'Finder-instellingen';

  @override
  String get settingsGeneral => 'Algemeen';

  @override
  String get settingsSidebar => 'Navigatiekolom';

  @override
  String get settingsAdvanced => 'Geavanceerd';

  @override
  String get settingsNewWindowsShow => 'Nieuwe vensters tonen:';

  @override
  String get settingsDefaultView => 'Standaardweergave:';

  @override
  String get settingsAppearance => 'Weergave:';

  @override
  String get settingsLanguage => 'Taal:';

  @override
  String get settingsShowInSidebar =>
      'Toon deze onderdelen in de navigatiekolom:';

  @override
  String get settingsBookmarks => 'Mappen met bladwijzer';

  @override
  String get settingsExternalDrives => 'Externe schijven';

  @override
  String get settingsShowHidden => 'Toon verborgen bestanden';

  @override
  String get settingsFoldersOnTop => 'Houd mappen bovenaan bij het sorteren';

  @override
  String get settingsThumbnails =>
      'Toon voorvertoningen van afbeeldingen in symbolen';

  @override
  String get settingsWarnEmptyTrash =>
      'Toon een waarschuwing voordat de prullenmand wordt geleegd';

  @override
  String get settingsNewWindowsNote =>
      'Keuzes voor groeperen, sorteren en weergave gelden voor geopende en nieuwe vensters.';

  @override
  String get appearanceSystem => 'Systeem';

  @override
  String get appearanceLight => 'Licht';

  @override
  String get appearanceDark => 'Donker';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get viewIcons => 'Symbolen';

  @override
  String get viewList => 'Lijst';

  @override
  String get viewColumns => 'Kolommen';

  @override
  String get placeHome => 'Thuis';

  @override
  String get placeDesktop => 'Bureaublad';

  @override
  String get placeDocuments => 'Documenten';

  @override
  String get placeDownloads => 'Downloads';

  @override
  String get placePictures => 'Afbeeldingen';

  @override
  String get placeMusic => 'Muziek';

  @override
  String get placeVideos => 'Video’s';

  @override
  String get tooltipNewTab => 'Nieuw tabblad';

  @override
  String get tooltipCloseTab => 'Sluit tabblad';

  @override
  String get menuOpenInNewTab => 'Open in nieuw tabblad';

  @override
  String get menuCloseOtherTabs => 'Sluit andere tabbladen';

  @override
  String get menuMoveTabToNewWindow => 'Verplaats tabblad naar nieuw venster';

  @override
  String get menuMergeAllWindows => 'Voeg alle vensters samen';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vensters samengevoegd',
      one: '1 venster samengevoegd',
      zero: 'Geen andere Finder-vensters om samen te voegen',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Weergave';

  @override
  String get settingsOpenFoldersInTabs =>
      'Open mappen in tabbladen in plaats van nieuwe vensters';

  @override
  String get settingsAccentColor => 'Accentkleur:';

  @override
  String get settingsTextSize => 'Tekstgrootte:';

  @override
  String get settingsIconSize => 'Symboolgrootte:';

  @override
  String get settingsShowPathBar => 'Toon padbalk';

  @override
  String get settingsShowStatusBar => 'Toon statusbalk';

  @override
  String get settingsShowExtensions => 'Toon alle bestandsnaamextensies';

  @override
  String get settingsEnterRenames =>
      'Druk op Enter om de naam te wijzigen (macOS-stijl)';

  @override
  String get accentBlue => 'Blauw';

  @override
  String get accentPurple => 'Paars';

  @override
  String get accentPink => 'Roze';

  @override
  String get accentRed => 'Rood';

  @override
  String get accentOrange => 'Oranje';

  @override
  String get accentYellow => 'Geel';

  @override
  String get accentGreen => 'Groen';

  @override
  String get accentGraphite => 'Grafiet';

  @override
  String get splitDropHint => 'Laat los om naast elkaar te tonen';

  @override
  String get menuSplitView => 'Toon naast elkaar';

  @override
  String get menuExitSplitView => 'Verlaat gesplitste weergave';

  @override
  String get settingsRestoreTabs => 'Open tabbladen van vorige keer opnieuw';

  @override
  String get menuUndo => 'Wijzig terug';

  @override
  String get menuRedo => 'Herstel';

  @override
  String conflictTitle(String name, String folder) {
    return '‘$name’ bestaat al in ‘$folder’';
  }

  @override
  String get conflictBody =>
      'Wil je het vervangen? Het vervangen onderdeel gaat naar de prullenmand.';

  @override
  String get conflictReplace => 'Vervang';

  @override
  String get conflictKeepBoth => 'Bewaar beide';

  @override
  String get conflictSkip => 'Sla over';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Doe hetzelfde voor de volgende $count conflicten',
      one: 'Doe hetzelfde voor het volgende conflict',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen kopiëren naar ‘$dest’',
      one: '1 onderdeel kopiëren naar ‘$dest’',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen verplaatsen naar ‘$dest’',
      one: '1 onderdeel verplaatsen naar ‘$dest’',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done van $total';
  }

  @override
  String transferRemaining(String time) {
    return 'nog ongeveer $time';
  }

  @override
  String get searchIn => 'Zoek:';

  @override
  String searchScopeSubfolders(String folder) {
    return '‘$folder’ en submappen';
  }

  @override
  String get searchScopeThisFolder => 'Alleen deze map';

  @override
  String get searchByName => 'Naam';

  @override
  String get searchByContents => 'Naam en inhoud';

  @override
  String get searching => 'Bezig met zoeken…';

  @override
  String get columnLocation => 'Locatie';

  @override
  String get tagRed => 'Rood';

  @override
  String get tagOrange => 'Oranje';

  @override
  String get tagYellow => 'Geel';

  @override
  String get tagGreen => 'Groen';

  @override
  String get tagBlue => 'Blauw';

  @override
  String get tagPurple => 'Paars';

  @override
  String get tagGray => 'Grijs';

  @override
  String get sidebarTags => 'Labels';

  @override
  String taggedIn(String tag, String folder) {
    return 'Label $tag in ‘$folder’';
  }

  @override
  String get tooltipRecentFolders => 'Recente mappen';

  @override
  String get recentNone => 'Geen recente mappen';

  @override
  String get menuClearRecents => 'Wis menu';

  @override
  String get settingsTheme => 'Thema';

  @override
  String themeEditingFor(String mode) {
    return 'Kleuren voor de weergave ‘$mode’. Licht en donker hebben elk hun eigen kleuren.';
  }

  @override
  String get themeAccent => 'Accentkleur';

  @override
  String get themeSelection => 'Selectie';

  @override
  String get themeFolder => 'Mappen';

  @override
  String get themeWindow => 'Vensterachtergrond';

  @override
  String get themeSidebar => 'Navigatiekolom';

  @override
  String get themeToolbar => 'Knoppenbalk';

  @override
  String get themeReset => 'Gebruik standaard';

  @override
  String get themeResetAll => 'Herstel alle kleuren';

  @override
  String get colorPickerTitle => 'Kies een kleur';

  @override
  String get colorHue => 'Tint';

  @override
  String get colorSaturation => 'Verzadiging';

  @override
  String get colorBrightness => 'Helderheid';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get updateAutoCheck => 'Automatisch zoeken naar updates';

  @override
  String get updateCheckNow => 'Controleer nu';

  @override
  String get updateChecking => 'Zoeken naar updates…';

  @override
  String get updateUpToDate => 'Finder is bijgewerkt.';

  @override
  String get updateAvailable =>
      'Er is een nieuwe versie van Finder beschikbaar.';

  @override
  String get updateInstall => 'Werk nu bij';

  @override
  String get updateInstalling =>
      'Update wordt gedownload en gebouwd. Dit kan enkele minuten duren…';

  @override
  String get updateInstalled => 'De update is geïnstalleerd.';

  @override
  String get updateRestart => 'Start Finder opnieuw';

  @override
  String updateFailed(String reason) {
    return 'Bijwerken mislukt: $reason';
  }

  @override
  String get updateUnsupported =>
      'Deze build kan zichzelf niet bijwerken. Installeer met install.sh om updates te krijgen.';

  @override
  String get themeEffects => 'Effecten';

  @override
  String get themeSidebarOpacity => 'Dekking navigatiekolom';

  @override
  String get themeWindowOpacity => 'Dekking venster';

  @override
  String get themeGlass => 'Glasstijl voor menu’s, dialoogvensters en panelen';

  @override
  String themeBlurHint(String appId) {
    return 'Installeer de GNOME-extensie ‘Blur my Shell’ en zet die aan voor $appId om het bureaublad achter Finder te vervagen.';
  }
}
