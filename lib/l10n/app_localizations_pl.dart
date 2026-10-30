// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Ulubione';

  @override
  String get sectionLocations => 'Lokalizacje';

  @override
  String get placeComputer => 'Komputer';

  @override
  String get placeTrash => 'Kosz';

  @override
  String get tooltipBack => 'Wstecz';

  @override
  String get tooltipForward => 'Dalej';

  @override
  String get tooltipViewIcons => 'Wyświetl jako ikony';

  @override
  String get tooltipViewList => 'Wyświetl jako listę';

  @override
  String get tooltipViewColumns => 'Wyświetl jako kolumny';

  @override
  String get tooltipEject => 'Wysuń';

  @override
  String get searchHint => 'Szukaj';

  @override
  String get columnName => 'Nazwa';

  @override
  String get columnModified => 'Data modyfikacji';

  @override
  String get columnSize => 'Rozmiar';

  @override
  String get columnKind => 'Rodzaj';

  @override
  String get kindFolder => 'Folder';

  @override
  String get kindImage => 'Obraz';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Zwykły tekst';

  @override
  String get kindCode => 'Kod źródłowy';

  @override
  String get kindPdf => 'Dokument PDF';

  @override
  String get kindArchive => 'Archiwum';

  @override
  String get kindDocument => 'Dokument';

  @override
  String get kindSpreadsheet => 'Arkusz kalkulacyjny';

  @override
  String get kindPresentation => 'Prezentacja';

  @override
  String get kindApplication => 'Aplikacja';

  @override
  String get kindOther => 'Dokument';

  @override
  String kindOtherExt(String ext) {
    return 'Plik $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu',
      many: '$count elementów',
      few: '$count elementy',
      one: '1 element',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return 'Zaznaczono $selected z $count';
  }

  @override
  String spaceAvailable(String size) {
    return 'Dostępne: $size';
  }

  @override
  String get emptyFolder => 'Pusty folder';

  @override
  String noResults(String query) {
    return 'Brak wyników dla „$query”';
  }

  @override
  String todayAt(String time) {
    return 'Dzisiaj o $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Wczoraj o $time';
  }

  @override
  String get menuOpen => 'Otwórz';

  @override
  String get menuQuickLook => 'Szybki podgląd';

  @override
  String get menuRename => 'Zmień nazwę';

  @override
  String get menuDuplicate => 'Powiel';

  @override
  String get menuCopy => 'Kopiuj';

  @override
  String get menuCut => 'Wytnij';

  @override
  String get menuPaste => 'Wklej';

  @override
  String get menuMoveToTrash => 'Przenieś do kosza';

  @override
  String get menuDeleteImmediately => 'Usuń natychmiast…';

  @override
  String get menuPutBack => 'Odłóż';

  @override
  String get menuEmptyTrash => 'Opróżnij kosz';

  @override
  String get menuNewFolder => 'Nowy folder';

  @override
  String get menuGetInfo => 'Pokaż informacje';

  @override
  String get menuCopyPath => 'Kopiuj ścieżkę';

  @override
  String get menuOpenInTerminal => 'Otwórz w Terminalu';

  @override
  String get menuAddToSidebar => 'Dodaj do paska bocznego';

  @override
  String get menuRemoveFromSidebar => 'Usuń z paska bocznego';

  @override
  String get menuShowHidden => 'Pokaż ukryte pliki';

  @override
  String get menuHideHidden => 'Ukryj ukryte pliki';

  @override
  String get menuNewWindow => 'Nowe okno';

  @override
  String get goToFolderTitle => 'Idź do folderu';

  @override
  String get goToFolderHint => 'np. ~/Documents lub /etc';

  @override
  String get buttonGo => 'Idź';

  @override
  String get buttonCancel => 'Anuluj';

  @override
  String get buttonDelete => 'Usuń';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunąć $count elementu natychmiast?',
      many: 'Usunąć $count elementów natychmiast?',
      few: 'Usunąć $count elementy natychmiast?',
      one: 'Usunąć ten element natychmiast?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Tej operacji nie można cofnąć.';

  @override
  String get emptyTrashConfirmTitle => 'Czy trwale usunąć elementy z kosza?';

  @override
  String get infoKind => 'Rodzaj';

  @override
  String get infoSize => 'Rozmiar';

  @override
  String get infoWhere => 'Lokalizacja';

  @override
  String get infoModified => 'Zmodyfikowano';

  @override
  String get infoPermissions => 'Uprawnienia';

  @override
  String get infoCalculating => 'Obliczanie…';

  @override
  String get untitledFolder => 'folder bez nazwy';

  @override
  String get copySuffix => 'kopia';

  @override
  String get pathCopied => 'Skopiowano ścieżkę';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przeniesiono $count elementu do kosza',
      many: 'Przeniesiono $count elementów do kosza',
      few: 'Przeniesiono $count elementy do kosza',
      one: 'Przeniesiono 1 element do kosza',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Nie można znaleźć folderu „$path”.';
  }

  @override
  String errorOperation(String message) {
    return 'Nie można ukończyć operacji: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Nazwa „$name” jest już zajęta.';
  }

  @override
  String get errorInvalidName => 'Tej nazwy nie można użyć.';

  @override
  String get quickLookNoPreview => 'Podgląd niedostępny';

  @override
  String get tooltipGroupSort => 'Grupuj i sortuj';

  @override
  String get menuGroupBy => 'Grupuj według';

  @override
  String get menuSortBy => 'Sortuj według';

  @override
  String get groupNone => 'Brak';

  @override
  String get groupToday => 'Dzisiaj';

  @override
  String get groupYesterday => 'Wczoraj';

  @override
  String get groupPrevious7Days => 'Poprzednie 7 dni';

  @override
  String get groupPrevious30Days => 'Poprzednie 30 dni';

  @override
  String get groupFolders => 'Foldery';

  @override
  String get groupOther => 'Inne';

  @override
  String get sizeZero => 'Zero bajtów';

  @override
  String sizeLessThan(String size) {
    return 'Mniej niż $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from do $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size lub więcej';
  }

  @override
  String get menuSettings => 'Ustawienia…';

  @override
  String get settingsTitle => 'Ustawienia Findera';

  @override
  String get settingsGeneral => 'Ogólne';

  @override
  String get settingsSidebar => 'Pasek boczny';

  @override
  String get settingsAdvanced => 'Zaawansowane';

  @override
  String get settingsNewWindowsShow => 'Nowe okna pokazują:';

  @override
  String get settingsDefaultView => 'Domyślny widok:';

  @override
  String get settingsAppearance => 'Wygląd:';

  @override
  String get settingsLanguage => 'Język:';

  @override
  String get settingsShowInSidebar => 'Pokaż te elementy na pasku bocznym:';

  @override
  String get settingsBookmarks => 'Foldery z zakładek';

  @override
  String get settingsExternalDrives => 'Dyski zewnętrzne';

  @override
  String get settingsShowHidden => 'Pokaż ukryte pliki';

  @override
  String get settingsFoldersOnTop => 'Foldery zawsze na górze przy sortowaniu';

  @override
  String get settingsThumbnails => 'Pokaż podglądy obrazów w ikonach';

  @override
  String get settingsWarnEmptyTrash => 'Ostrzegaj przed opróżnieniem kosza';

  @override
  String get settingsNewWindowsNote =>
      'Wybór grupowania, sortowania i widoku dotyczy otwartych i nowych okien.';

  @override
  String get appearanceSystem => 'Systemowy';

  @override
  String get appearanceLight => 'Jasny';

  @override
  String get appearanceDark => 'Ciemny';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get viewIcons => 'Ikony';

  @override
  String get viewList => 'Lista';

  @override
  String get viewColumns => 'Kolumny';

  @override
  String get placeHome => 'Dom';

  @override
  String get placeDesktop => 'Biurko';

  @override
  String get placeDocuments => 'Dokumenty';

  @override
  String get placeDownloads => 'Pobrane';

  @override
  String get placePictures => 'Obrazy';

  @override
  String get placeMusic => 'Muzyka';

  @override
  String get placeVideos => 'Filmy';

  @override
  String get tooltipNewTab => 'Nowa karta';

  @override
  String get tooltipCloseTab => 'Zamknij kartę';

  @override
  String get menuOpenInNewTab => 'Otwórz w nowej karcie';

  @override
  String get menuCloseOtherTabs => 'Zamknij pozostałe karty';

  @override
  String get menuMoveTabToNewWindow => 'Przenieś kartę do nowego okna';

  @override
  String get menuMergeAllWindows => 'Scal wszystkie okna';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Scalono $count okna',
      many: 'Scalono $count okien',
      few: 'Scalono $count okna',
      one: 'Scalono 1 okno',
      zero: 'Brak innych okien Findera do scalenia',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Wyświetlanie';

  @override
  String get settingsOpenFoldersInTabs =>
      'Otwieraj foldery w kartach zamiast w nowych oknach';

  @override
  String get settingsAccentColor => 'Kolor akcentu:';

  @override
  String get settingsTextSize => 'Rozmiar tekstu:';

  @override
  String get settingsIconSize => 'Rozmiar ikon:';

  @override
  String get settingsShowPathBar => 'Pokaż pasek ścieżki';

  @override
  String get settingsShowStatusBar => 'Pokaż pasek stanu';

  @override
  String get settingsShowExtensions =>
      'Pokaż wszystkie rozszerzenia nazw plików';

  @override
  String get settingsEnterRenames => 'Enter zmienia nazwę (jak w macOS)';

  @override
  String get accentBlue => 'Niebieski';

  @override
  String get accentPurple => 'Fioletowy';

  @override
  String get accentPink => 'Różowy';

  @override
  String get accentRed => 'Czerwony';

  @override
  String get accentOrange => 'Pomarańczowy';

  @override
  String get accentYellow => 'Żółty';

  @override
  String get accentGreen => 'Zielony';

  @override
  String get accentGraphite => 'Grafitowy';

  @override
  String get splitDropHint => 'Upuść, aby wyświetlić obok siebie';

  @override
  String get menuSplitView => 'Pokaż obok siebie';

  @override
  String get menuExitSplitView => 'Zakończ widok podzielony';

  @override
  String get settingsRestoreTabs => 'Otwórz ponownie karty z ostatniej sesji';

  @override
  String get menuUndo => 'Cofnij';

  @override
  String get menuRedo => 'Ponów';

  @override
  String conflictTitle(String name, String folder) {
    return '„$name” już istnieje w „$folder”';
  }

  @override
  String get conflictBody =>
      'Czy chcesz go zastąpić? Zastąpiony element trafi do kosza.';

  @override
  String get conflictReplace => 'Zastąp';

  @override
  String get conflictKeepBoth => 'Zachowaj oba';

  @override
  String get conflictSkip => 'Pomiń';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zrób to samo przy następnych konfliktach: $count',
      one: 'Zrób to samo przy następnym konflikcie',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kopiowanie elementów ($count) do „$dest”',
      one: 'Kopiowanie 1 elementu do „$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przenoszenie elementów ($count) do „$dest”',
      one: 'Przenoszenie 1 elementu do „$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done z $total';
  }

  @override
  String transferRemaining(String time) {
    return 'pozostało ok. $time';
  }

  @override
  String get searchIn => 'Szukaj:';

  @override
  String searchScopeSubfolders(String folder) {
    return '„$folder” i podfoldery';
  }

  @override
  String get searchScopeThisFolder => 'Tylko ten folder';

  @override
  String get searchByName => 'Nazwa';

  @override
  String get searchByContents => 'Nazwa i zawartość';

  @override
  String get searching => 'Szukanie…';

  @override
  String get columnLocation => 'Lokalizacja';

  @override
  String get tagRed => 'Czerwony';

  @override
  String get tagOrange => 'Pomarańczowy';

  @override
  String get tagYellow => 'Żółty';

  @override
  String get tagGreen => 'Zielony';

  @override
  String get tagBlue => 'Niebieski';

  @override
  String get tagPurple => 'Fioletowy';

  @override
  String get tagGray => 'Szary';

  @override
  String get sidebarTags => 'Tagi';

  @override
  String taggedIn(String tag, String folder) {
    return 'Oznaczone tagiem $tag w „$folder”';
  }

  @override
  String get tooltipRecentFolders => 'Ostatnie foldery';

  @override
  String get recentNone => 'Brak ostatnich folderów';

  @override
  String get menuClearRecents => 'Wyczyść menu';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String themeEditingFor(String mode) {
    return 'Kolory wyglądu „$mode”. Jasny i ciemny mają własne kolory.';
  }

  @override
  String get themeAccent => 'Kolor akcentu';

  @override
  String get themeSelection => 'Zaznaczenie';

  @override
  String get themeFolder => 'Foldery';

  @override
  String get themeWindow => 'Tło okna';

  @override
  String get themeSidebar => 'Pasek boczny';

  @override
  String get themeToolbar => 'Pasek narzędzi';

  @override
  String get themeReset => 'Użyj domyślnego';

  @override
  String get themeResetAll => 'Przywróć wszystkie kolory';

  @override
  String get colorPickerTitle => 'Wybierz kolor';

  @override
  String get colorHue => 'Odcień';

  @override
  String get colorSaturation => 'Nasycenie';

  @override
  String get colorBrightness => 'Jasność';

  @override
  String get settingsUpdates => 'Uaktualnienia';

  @override
  String get updateAutoCheck => 'Automatycznie sprawdzaj uaktualnienia';

  @override
  String get updateCheckNow => 'Sprawdź teraz';

  @override
  String get updateChecking => 'Sprawdzanie uaktualnień…';

  @override
  String get updateUpToDate => 'Finder jest aktualny.';

  @override
  String get updateAvailable => 'Dostępna jest nowa wersja Findera.';

  @override
  String get updateInstall => 'Uaktualnij teraz';

  @override
  String get updateInstalling =>
      'Pobieranie i budowanie uaktualnienia. Może to potrwać kilka minut…';

  @override
  String get updateInstalled => 'Uaktualnienie zostało zainstalowane.';

  @override
  String get updateRestart => 'Uruchom ponownie Findera';

  @override
  String updateFailed(String reason) {
    return 'Nie można uaktualnić: $reason';
  }

  @override
  String get updateUnsupported =>
      'Ta wersja nie może się sama uaktualniać. Zainstaluj ją za pomocą install.sh, aby otrzymywać uaktualnienia.';

  @override
  String get themeEffects => 'Efekty';

  @override
  String get themeSidebarOpacity => 'Krycie paska bocznego';

  @override
  String get themeWindowOpacity => 'Krycie okna';

  @override
  String get themeGlass => 'Styl szkła dla menu, okien dialogowych i paneli';

  @override
  String themeBlurHint(String appId) {
    return 'Aby rozmyć biurko za Finderem, zainstaluj rozszerzenie GNOME „Blur my Shell” i włącz je dla $appId.';
  }
}
