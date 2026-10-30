// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favoriten';

  @override
  String get sectionLocations => 'Orte';

  @override
  String get placeComputer => 'Computer';

  @override
  String get placeTrash => 'Papierkorb';

  @override
  String get tooltipBack => 'Zurück';

  @override
  String get tooltipForward => 'Vorwärts';

  @override
  String get tooltipViewIcons => 'Als Symbole';

  @override
  String get tooltipViewList => 'Als Liste';

  @override
  String get tooltipViewColumns => 'Als Spalten';

  @override
  String get tooltipEject => 'Auswerfen';

  @override
  String get searchHint => 'Suchen';

  @override
  String get columnName => 'Name';

  @override
  String get columnModified => 'Änderungsdatum';

  @override
  String get columnSize => 'Größe';

  @override
  String get columnKind => 'Art';

  @override
  String get kindFolder => 'Ordner';

  @override
  String get kindImage => 'Bild';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Nur-Text';

  @override
  String get kindCode => 'Quellcode';

  @override
  String get kindPdf => 'PDF-Dokument';

  @override
  String get kindArchive => 'Archiv';

  @override
  String get kindDocument => 'Dokument';

  @override
  String get kindSpreadsheet => 'Tabelle';

  @override
  String get kindPresentation => 'Präsentation';

  @override
  String get kindApplication => 'Programm';

  @override
  String get kindOther => 'Dokument';

  @override
  String kindOtherExt(String ext) {
    return '$ext-Datei';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Objekte',
      one: '1 Objekt',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected von $count ausgewählt';
  }

  @override
  String spaceAvailable(String size) {
    return '$size verfügbar';
  }

  @override
  String get emptyFolder => 'Leerer Ordner';

  @override
  String noResults(String query) {
    return 'Keine Ergebnisse für „$query“';
  }

  @override
  String todayAt(String time) {
    return 'Heute um $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Gestern um $time';
  }

  @override
  String get menuOpen => 'Öffnen';

  @override
  String get menuQuickLook => 'Übersicht';

  @override
  String get menuRename => 'Umbenennen';

  @override
  String get menuDuplicate => 'Duplizieren';

  @override
  String get menuCopy => 'Kopieren';

  @override
  String get menuCut => 'Ausschneiden';

  @override
  String get menuPaste => 'Einsetzen';

  @override
  String get menuMoveToTrash => 'In den Papierkorb legen';

  @override
  String get menuDeleteImmediately => 'Sofort löschen …';

  @override
  String get menuPutBack => 'Zurücklegen';

  @override
  String get menuEmptyTrash => 'Papierkorb entleeren';

  @override
  String get menuNewFolder => 'Neuer Ordner';

  @override
  String get menuGetInfo => 'Informationen';

  @override
  String get menuCopyPath => 'Pfad kopieren';

  @override
  String get menuOpenInTerminal => 'Im Terminal öffnen';

  @override
  String get menuAddToSidebar => 'Zur Seitenleiste hinzufügen';

  @override
  String get menuRemoveFromSidebar => 'Aus der Seitenleiste entfernen';

  @override
  String get menuShowHidden => 'Unsichtbare Dateien einblenden';

  @override
  String get menuHideHidden => 'Unsichtbare Dateien ausblenden';

  @override
  String get menuNewWindow => 'Neues Fenster';

  @override
  String get goToFolderTitle => 'Gehe zum Ordner';

  @override
  String get goToFolderHint => 'z. B. ~/Documents oder /etc';

  @override
  String get buttonGo => 'Los';

  @override
  String get buttonCancel => 'Abbrechen';

  @override
  String get buttonDelete => 'Löschen';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Objekte sofort löschen?',
      one: 'Dieses Objekt sofort löschen?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Diese Aktion kann nicht widerrufen werden.';

  @override
  String get emptyTrashConfirmTitle =>
      'Objekte im Papierkorb endgültig löschen?';

  @override
  String get infoKind => 'Art';

  @override
  String get infoSize => 'Größe';

  @override
  String get infoWhere => 'Ort';

  @override
  String get infoModified => 'Geändert';

  @override
  String get infoPermissions => 'Zugriffsrechte';

  @override
  String get infoCalculating => 'Berechnung läuft …';

  @override
  String get untitledFolder => 'unbenannter Ordner';

  @override
  String get copySuffix => 'Kopie';

  @override
  String get pathCopied => 'Pfad kopiert';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Objekte in den Papierkorb gelegt',
      one: '1 Objekt in den Papierkorb gelegt',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Der Ordner „$path“ wurde nicht gefunden.';
  }

  @override
  String errorOperation(String message) {
    return 'Der Vorgang kann nicht abgeschlossen werden: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Der Name „$name“ ist bereits vergeben.';
  }

  @override
  String get errorInvalidName => 'Dieser Name kann nicht verwendet werden.';

  @override
  String get quickLookNoPreview => 'Keine Vorschau verfügbar';

  @override
  String get tooltipGroupSort => 'Gruppieren und sortieren';

  @override
  String get menuGroupBy => 'Gruppieren nach';

  @override
  String get menuSortBy => 'Sortieren nach';

  @override
  String get groupNone => 'Keine';

  @override
  String get groupToday => 'Heute';

  @override
  String get groupYesterday => 'Gestern';

  @override
  String get groupPrevious7Days => 'Letzte 7 Tage';

  @override
  String get groupPrevious30Days => 'Letzte 30 Tage';

  @override
  String get groupFolders => 'Ordner';

  @override
  String get groupOther => 'Andere';

  @override
  String get sizeZero => 'Null Byte';

  @override
  String sizeLessThan(String size) {
    return 'Weniger als $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from bis $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size oder mehr';
  }

  @override
  String get menuSettings => 'Einstellungen …';

  @override
  String get settingsTitle => 'Finder-Einstellungen';

  @override
  String get settingsGeneral => 'Allgemein';

  @override
  String get settingsSidebar => 'Seitenleiste';

  @override
  String get settingsAdvanced => 'Erweitert';

  @override
  String get settingsNewWindowsShow => 'Neue Fenster zeigen:';

  @override
  String get settingsDefaultView => 'Standardansicht:';

  @override
  String get settingsAppearance => 'Erscheinungsbild:';

  @override
  String get settingsLanguage => 'Sprache:';

  @override
  String get settingsShowInSidebar =>
      'Diese Objekte in der Seitenleiste zeigen:';

  @override
  String get settingsBookmarks => 'Ordner mit Lesezeichen';

  @override
  String get settingsExternalDrives => 'Externe Laufwerke';

  @override
  String get settingsShowHidden => 'Unsichtbare Dateien einblenden';

  @override
  String get settingsFoldersOnTop => 'Beim Sortieren Ordner oben behalten';

  @override
  String get settingsThumbnails => 'Bildvorschauen in Symbolen zeigen';

  @override
  String get settingsWarnEmptyTrash =>
      'Warnung vor dem Entleeren des Papierkorbs zeigen';

  @override
  String get settingsNewWindowsNote =>
      'Gruppierungs-, Sortier- und Ansichtsauswahl gilt für geöffnete und neue Fenster.';

  @override
  String get appearanceSystem => 'System';

  @override
  String get appearanceLight => 'Hell';

  @override
  String get appearanceDark => 'Dunkel';

  @override
  String get languageSystem => 'System';

  @override
  String get viewIcons => 'Symbole';

  @override
  String get viewList => 'Liste';

  @override
  String get viewColumns => 'Spalten';

  @override
  String get placeHome => 'Benutzerordner';

  @override
  String get placeDesktop => 'Schreibtisch';

  @override
  String get placeDocuments => 'Dokumente';

  @override
  String get placeDownloads => 'Downloads';

  @override
  String get placePictures => 'Bilder';

  @override
  String get placeMusic => 'Musik';

  @override
  String get placeVideos => 'Videos';

  @override
  String get tooltipNewTab => 'Neuer Tab';

  @override
  String get tooltipCloseTab => 'Tab schließen';

  @override
  String get menuOpenInNewTab => 'In neuem Tab öffnen';

  @override
  String get menuCloseOtherTabs => 'Andere Tabs schließen';

  @override
  String get menuMoveTabToNewWindow => 'Tab in neues Fenster bewegen';

  @override
  String get menuMergeAllWindows => 'Alle Fenster zusammenführen';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fenster zusammengeführt',
      one: '1 Fenster zusammengeführt',
      zero: 'Keine weiteren Finder-Fenster zum Zusammenführen',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Anzeige';

  @override
  String get settingsOpenFoldersInTabs =>
      'Ordner in Tabs statt in neuen Fenstern öffnen';

  @override
  String get settingsAccentColor => 'Akzentfarbe:';

  @override
  String get settingsTextSize => 'Textgröße:';

  @override
  String get settingsIconSize => 'Symbolgröße:';

  @override
  String get settingsShowPathBar => 'Pfadleiste einblenden';

  @override
  String get settingsShowStatusBar => 'Statusleiste einblenden';

  @override
  String get settingsShowExtensions =>
      'Alle Dateinamenerweiterungen einblenden';

  @override
  String get settingsEnterRenames =>
      'Zum Umbenennen Eingabetaste drücken (macOS-Stil)';

  @override
  String get accentBlue => 'Blau';

  @override
  String get accentPurple => 'Violett';

  @override
  String get accentPink => 'Rosa';

  @override
  String get accentRed => 'Rot';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentYellow => 'Gelb';

  @override
  String get accentGreen => 'Grün';

  @override
  String get accentGraphite => 'Graphit';

  @override
  String get splitDropHint => 'Hier ablegen, um nebeneinander anzuzeigen';

  @override
  String get menuSplitView => 'Nebeneinander anzeigen';

  @override
  String get menuExitSplitView => 'Geteilte Ansicht beenden';

  @override
  String get settingsRestoreTabs => 'Tabs der letzten Sitzung wieder öffnen';

  @override
  String get menuUndo => 'Widerrufen';

  @override
  String get menuRedo => 'Wiederholen';

  @override
  String conflictTitle(String name, String folder) {
    return '„$name“ ist in „$folder“ bereits vorhanden';
  }

  @override
  String get conflictBody =>
      'Möchten Sie das Objekt ersetzen? Das ersetzte Objekt wird in den Papierkorb gelegt.';

  @override
  String get conflictReplace => 'Ersetzen';

  @override
  String get conflictKeepBoth => 'Beide behalten';

  @override
  String get conflictSkip => 'Überspringen';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Für die nächsten $count Konflikte dasselbe tun',
      one: 'Für den nächsten Konflikt dasselbe tun',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Objekte werden in „$dest“ kopiert',
      one: '1 Objekt wird in „$dest“ kopiert',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Objekte werden in „$dest“ bewegt',
      one: '1 Objekt wird in „$dest“ bewegt',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done von $total';
  }

  @override
  String transferRemaining(String time) {
    return 'noch ca. $time';
  }

  @override
  String get searchIn => 'Suchen:';

  @override
  String searchScopeSubfolders(String folder) {
    return '„$folder“ und Unterordner';
  }

  @override
  String get searchScopeThisFolder => 'Nur dieser Ordner';

  @override
  String get searchByName => 'Name';

  @override
  String get searchByContents => 'Name und Inhalt';

  @override
  String get searching => 'Suche läuft …';

  @override
  String get columnLocation => 'Ort';

  @override
  String get tagRed => 'Rot';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagYellow => 'Gelb';

  @override
  String get tagGreen => 'Grün';

  @override
  String get tagBlue => 'Blau';

  @override
  String get tagPurple => 'Violett';

  @override
  String get tagGray => 'Grau';

  @override
  String get sidebarTags => 'Tags';

  @override
  String taggedIn(String tag, String folder) {
    return 'Mit Tag $tag in „$folder“';
  }

  @override
  String get tooltipRecentFolders => 'Benutzte Ordner';

  @override
  String get recentNone => 'Keine benutzten Ordner';

  @override
  String get menuClearRecents => 'Menü löschen';

  @override
  String get settingsTheme => 'Design';

  @override
  String themeEditingFor(String mode) {
    return 'Farben für das Erscheinungsbild „$mode“. Hell und Dunkel behalten eigene Farben.';
  }

  @override
  String get themeAccent => 'Akzentfarbe';

  @override
  String get themeSelection => 'Auswahl';

  @override
  String get themeFolder => 'Ordner';

  @override
  String get themeWindow => 'Fensterhintergrund';

  @override
  String get themeSidebar => 'Seitenleiste';

  @override
  String get themeToolbar => 'Symbolleiste';

  @override
  String get themeReset => 'Standard verwenden';

  @override
  String get themeResetAll => 'Alle Farben zurücksetzen';

  @override
  String get colorPickerTitle => 'Farbe auswählen';

  @override
  String get colorHue => 'Farbton';

  @override
  String get colorSaturation => 'Sättigung';

  @override
  String get colorBrightness => 'Helligkeit';

  @override
  String get settingsUpdates => 'Updates';

  @override
  String get updateAutoCheck => 'Automatisch nach Updates suchen';

  @override
  String get updateCheckNow => 'Jetzt prüfen';

  @override
  String get updateChecking => 'Nach Updates suchen …';

  @override
  String get updateUpToDate => 'Finder ist auf dem neuesten Stand.';

  @override
  String get updateAvailable => 'Eine neue Version von Finder ist verfügbar.';

  @override
  String get updateInstall => 'Jetzt aktualisieren';

  @override
  String get updateInstalling =>
      'Update wird geladen und gebaut. Das kann einige Minuten dauern …';

  @override
  String get updateInstalled => 'Das Update ist installiert.';

  @override
  String get updateRestart => 'Finder neu starten';

  @override
  String updateFailed(String reason) {
    return 'Aktualisierung fehlgeschlagen: $reason';
  }

  @override
  String get updateUnsupported =>
      'Diese Version kann sich nicht selbst aktualisieren. Installiere sie mit install.sh, um Updates zu erhalten.';

  @override
  String get themeEffects => 'Effekte';

  @override
  String get themeSidebarOpacity => 'Deckkraft der Seitenleiste';

  @override
  String get themeWindowOpacity => 'Deckkraft des Fensters';

  @override
  String get themeGlass => 'Glasstil für Menüs, Dialoge und Fenster';

  @override
  String themeBlurHint(String appId) {
    return 'Um den Schreibtisch hinter Finder weichzuzeichnen, installiere die GNOME-Erweiterung „Blur my Shell“ und aktiviere sie für $appId.';
  }
}
