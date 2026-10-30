// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Preferiti';

  @override
  String get sectionLocations => 'Posizioni';

  @override
  String get placeComputer => 'Computer';

  @override
  String get placeTrash => 'Cestino';

  @override
  String get tooltipBack => 'Indietro';

  @override
  String get tooltipForward => 'Avanti';

  @override
  String get tooltipViewIcons => 'Come icone';

  @override
  String get tooltipViewList => 'Come elenco';

  @override
  String get tooltipViewColumns => 'Come colonne';

  @override
  String get tooltipEject => 'Espelli';

  @override
  String get searchHint => 'Cerca';

  @override
  String get columnName => 'Nome';

  @override
  String get columnModified => 'Data modifica';

  @override
  String get columnSize => 'Dimensione';

  @override
  String get columnKind => 'Tipo';

  @override
  String get kindFolder => 'Cartella';

  @override
  String get kindImage => 'Immagine';

  @override
  String get kindVideo => 'Filmato';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Testo semplice';

  @override
  String get kindCode => 'Codice sorgente';

  @override
  String get kindPdf => 'Documento PDF';

  @override
  String get kindArchive => 'Archivio';

  @override
  String get kindDocument => 'Documento';

  @override
  String get kindSpreadsheet => 'Foglio di calcolo';

  @override
  String get kindPresentation => 'Presentazione';

  @override
  String get kindApplication => 'Applicazione';

  @override
  String get kindOther => 'Documento';

  @override
  String kindOtherExt(String ext) {
    return 'File $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected di $count selezionati';
  }

  @override
  String spaceAvailable(String size) {
    return '$size disponibili';
  }

  @override
  String get emptyFolder => 'Cartella vuota';

  @override
  String noResults(String query) {
    return 'Nessun risultato per “$query”';
  }

  @override
  String todayAt(String time) {
    return 'Oggi alle $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ieri alle $time';
  }

  @override
  String get menuOpen => 'Apri';

  @override
  String get menuQuickLook => 'Anteprima rapida';

  @override
  String get menuRename => 'Rinomina';

  @override
  String get menuDuplicate => 'Duplica';

  @override
  String get menuCopy => 'Copia';

  @override
  String get menuCut => 'Taglia';

  @override
  String get menuPaste => 'Incolla';

  @override
  String get menuMoveToTrash => 'Sposta nel Cestino';

  @override
  String get menuDeleteImmediately => 'Elimina immediatamente…';

  @override
  String get menuPutBack => 'Rimetti a posto';

  @override
  String get menuEmptyTrash => 'Svuota il Cestino';

  @override
  String get menuNewFolder => 'Nuova cartella';

  @override
  String get menuGetInfo => 'Ottieni informazioni';

  @override
  String get menuCopyPath => 'Copia percorso';

  @override
  String get menuOpenInTerminal => 'Apri nel Terminale';

  @override
  String get menuAddToSidebar => 'Aggiungi alla barra laterale';

  @override
  String get menuRemoveFromSidebar => 'Rimuovi dalla barra laterale';

  @override
  String get menuShowHidden => 'Mostra file nascosti';

  @override
  String get menuHideHidden => 'Nascondi file nascosti';

  @override
  String get menuNewWindow => 'Nuova finestra';

  @override
  String get goToFolderTitle => 'Vai alla cartella';

  @override
  String get goToFolderHint => 'ad es. ~/Documents o /etc';

  @override
  String get buttonGo => 'Vai';

  @override
  String get buttonCancel => 'Annulla';

  @override
  String get buttonDelete => 'Elimina';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminare subito $count elementi?',
      one: 'Eliminare subito questo elemento?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Questa azione non può essere annullata.';

  @override
  String get emptyTrashConfirmTitle =>
      'Eliminare definitivamente gli elementi nel Cestino?';

  @override
  String get infoKind => 'Tipo';

  @override
  String get infoSize => 'Dimensione';

  @override
  String get infoWhere => 'Dove';

  @override
  String get infoModified => 'Modificato';

  @override
  String get infoPermissions => 'Permessi';

  @override
  String get infoCalculating => 'Calcolo in corso…';

  @override
  String get untitledFolder => 'cartella senza nome';

  @override
  String get copySuffix => 'copia';

  @override
  String get pathCopied => 'Percorso copiato';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi spostati nel Cestino',
      one: '1 elemento spostato nel Cestino',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Impossibile trovare la cartella “$path”.';
  }

  @override
  String errorOperation(String message) {
    return 'Impossibile completare l’operazione: $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Il nome “$name” è già in uso.';
  }

  @override
  String get errorInvalidName => 'Impossibile usare questo nome.';

  @override
  String get quickLookNoPreview => 'Anteprima non disponibile';

  @override
  String get tooltipGroupSort => 'Raggruppa e ordina';

  @override
  String get menuGroupBy => 'Raggruppa per';

  @override
  String get menuSortBy => 'Ordina per';

  @override
  String get groupNone => 'Nessuno';

  @override
  String get groupToday => 'Oggi';

  @override
  String get groupYesterday => 'Ieri';

  @override
  String get groupPrevious7Days => 'Ultimi 7 giorni';

  @override
  String get groupPrevious30Days => 'Ultimi 30 giorni';

  @override
  String get groupFolders => 'Cartelle';

  @override
  String get groupOther => 'Altro';

  @override
  String get sizeZero => 'Zero byte';

  @override
  String sizeLessThan(String size) {
    return 'Meno di $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return 'Da $from a $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size o più';
  }

  @override
  String get menuSettings => 'Impostazioni…';

  @override
  String get settingsTitle => 'Impostazioni del Finder';

  @override
  String get settingsGeneral => 'Generali';

  @override
  String get settingsSidebar => 'Barra laterale';

  @override
  String get settingsAdvanced => 'Avanzate';

  @override
  String get settingsNewWindowsShow => 'Le nuove finestre mostrano:';

  @override
  String get settingsDefaultView => 'Vista predefinita:';

  @override
  String get settingsAppearance => 'Aspetto:';

  @override
  String get settingsLanguage => 'Lingua:';

  @override
  String get settingsShowInSidebar =>
      'Mostra questi elementi nella barra laterale:';

  @override
  String get settingsBookmarks => 'Cartelle nei segnalibri';

  @override
  String get settingsExternalDrives => 'Dischi esterni';

  @override
  String get settingsShowHidden => 'Mostra file nascosti';

  @override
  String get settingsFoldersOnTop =>
      'Mantieni le cartelle in alto durante l’ordinamento';

  @override
  String get settingsThumbnails =>
      'Mostra anteprime delle immagini nelle icone';

  @override
  String get settingsWarnEmptyTrash =>
      'Mostra un avviso prima di svuotare il Cestino';

  @override
  String get settingsNewWindowsNote =>
      'Le scelte di raggruppamento, ordinamento e vista valgono per le finestre aperte e per quelle nuove.';

  @override
  String get appearanceSystem => 'Sistema';

  @override
  String get appearanceLight => 'Chiaro';

  @override
  String get appearanceDark => 'Scuro';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get viewIcons => 'Icone';

  @override
  String get viewList => 'Elenco';

  @override
  String get viewColumns => 'Colonne';

  @override
  String get placeHome => 'Home';

  @override
  String get placeDesktop => 'Scrivania';

  @override
  String get placeDocuments => 'Documenti';

  @override
  String get placeDownloads => 'Download';

  @override
  String get placePictures => 'Immagini';

  @override
  String get placeMusic => 'Musica';

  @override
  String get placeVideos => 'Video';

  @override
  String get tooltipNewTab => 'Nuova scheda';

  @override
  String get tooltipCloseTab => 'Chiudi scheda';

  @override
  String get menuOpenInNewTab => 'Apri in una nuova scheda';

  @override
  String get menuCloseOtherTabs => 'Chiudi le altre schede';

  @override
  String get menuMoveTabToNewWindow => 'Sposta la scheda in una nuova finestra';

  @override
  String get menuMergeAllWindows => 'Unisci tutte le finestre';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count finestre unite',
      one: '1 finestra unita',
      zero: 'Nessun’altra finestra del Finder da unire',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Visualizzazione';

  @override
  String get settingsOpenFoldersInTabs =>
      'Apri le cartelle in schede anziché in nuove finestre';

  @override
  String get settingsAccentColor => 'Colore principale:';

  @override
  String get settingsTextSize => 'Dimensione del testo:';

  @override
  String get settingsIconSize => 'Dimensione delle icone:';

  @override
  String get settingsShowPathBar => 'Mostra barra del percorso';

  @override
  String get settingsShowStatusBar => 'Mostra barra di stato';

  @override
  String get settingsShowExtensions =>
      'Mostra tutte le estensioni dei nomi file';

  @override
  String get settingsEnterRenames => 'Premi Invio per rinominare (stile macOS)';

  @override
  String get accentBlue => 'Blu';

  @override
  String get accentPurple => 'Viola';

  @override
  String get accentPink => 'Rosa';

  @override
  String get accentRed => 'Rosso';

  @override
  String get accentOrange => 'Arancione';

  @override
  String get accentYellow => 'Giallo';

  @override
  String get accentGreen => 'Verde';

  @override
  String get accentGraphite => 'Grafite';

  @override
  String get splitDropHint => 'Rilascia per mostrare affiancati';

  @override
  String get menuSplitView => 'Mostra affiancati';

  @override
  String get menuExitSplitView => 'Esci da Split View';

  @override
  String get settingsRestoreTabs => 'Riapri le schede dell’ultima volta';

  @override
  String get menuUndo => 'Annulla';

  @override
  String get menuRedo => 'Ripeti';

  @override
  String conflictTitle(String name, String folder) {
    return '“$name” esiste già in “$folder”';
  }

  @override
  String get conflictBody =>
      'Vuoi sostituirlo? L’elemento sostituito verrà spostato nel Cestino.';

  @override
  String get conflictReplace => 'Sostituisci';

  @override
  String get conflictKeepBoth => 'Mantieni entrambi';

  @override
  String get conflictSkip => 'Salta';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Fai lo stesso per i prossimi $count conflitti',
      one: 'Fai lo stesso per il prossimo conflitto',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copia di $count elementi in “$dest”',
      one: 'Copia di 1 elemento in “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Spostamento di $count elementi in “$dest”',
      one: 'Spostamento di 1 elemento in “$dest”',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done di $total';
  }

  @override
  String transferRemaining(String time) {
    return 'mancano circa $time';
  }

  @override
  String get searchIn => 'Cerca:';

  @override
  String searchScopeSubfolders(String folder) {
    return '“$folder” e sottocartelle';
  }

  @override
  String get searchScopeThisFolder => 'Solo questa cartella';

  @override
  String get searchByName => 'Nome';

  @override
  String get searchByContents => 'Nome e contenuto';

  @override
  String get searching => 'Ricerca in corso…';

  @override
  String get columnLocation => 'Posizione';

  @override
  String get tagRed => 'Rosso';

  @override
  String get tagOrange => 'Arancione';

  @override
  String get tagYellow => 'Giallo';

  @override
  String get tagGreen => 'Verde';

  @override
  String get tagBlue => 'Blu';

  @override
  String get tagPurple => 'Viola';

  @override
  String get tagGray => 'Grigio';

  @override
  String get sidebarTags => 'Tag';

  @override
  String get sidebarDevices => 'Dispositivi';

  @override
  String taggedIn(String tag, String folder) {
    return 'Con tag $tag in “$folder”';
  }

  @override
  String get tooltipRecentFolders => 'Cartelle recenti';

  @override
  String get recentNone => 'Nessuna cartella recente';

  @override
  String get menuClearRecents => 'Cancella menu';

  @override
  String get settingsTheme => 'Tema';

  @override
  String themeEditingFor(String mode) {
    return 'Colori per l’aspetto $mode. Chiaro e scuro mantengono i propri colori.';
  }

  @override
  String get themeAccent => 'Colore di evidenziazione';

  @override
  String get themeSelection => 'Selezione';

  @override
  String get themeFolder => 'Cartelle';

  @override
  String get themeWindow => 'Sfondo della finestra';

  @override
  String get themeSidebar => 'Barra laterale';

  @override
  String get themeToolbar => 'Barra strumenti';

  @override
  String get themeReset => 'Usa predefinito';

  @override
  String get themeResetAll => 'Ripristina tutti i colori';

  @override
  String get colorPickerTitle => 'Scegli un colore';

  @override
  String get colorHue => 'Tonalità';

  @override
  String get colorSaturation => 'Saturazione';

  @override
  String get colorBrightness => 'Luminosità';

  @override
  String get settingsUpdates => 'Aggiornamenti';

  @override
  String get updateAutoCheck => 'Cerca aggiornamenti automaticamente';

  @override
  String get updateCheckNow => 'Controlla ora';

  @override
  String get updateChecking => 'Ricerca aggiornamenti…';

  @override
  String get updateUpToDate => 'Finder è aggiornato.';

  @override
  String get updateAvailable => 'È disponibile una nuova versione di Finder.';

  @override
  String get updateInstall => 'Aggiorna ora';

  @override
  String get updateInstalling =>
      'Download e compilazione dell’aggiornamento. Potrebbe richiedere alcuni minuti…';

  @override
  String get updateInstalled => 'L’aggiornamento è installato.';

  @override
  String get updateRestart => 'Riavvia Finder';

  @override
  String updateFailed(String reason) {
    return 'Impossibile aggiornare: $reason';
  }

  @override
  String get updateUnsupported =>
      'Questa build non può aggiornarsi da sola. Installala con install.sh per ricevere gli aggiornamenti.';

  @override
  String get themeEffects => 'Effetti';

  @override
  String get themeSidebarOpacity => 'Opacità barra laterale';

  @override
  String get themeWindowOpacity => 'Opacità finestra';

  @override
  String get themeGlass =>
      'Stile vetro per menu, finestre di dialogo e pannelli';

  @override
  String themeBlurHint(String appId) {
    return 'Per sfocare la scrivania dietro Finder, installa l’estensione GNOME “Blur my Shell” e attivala per $appId.';
  }
}
