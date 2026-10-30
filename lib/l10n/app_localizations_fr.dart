// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Finder';

  @override
  String get sectionFavorites => 'Favoris';

  @override
  String get sectionLocations => 'Emplacements';

  @override
  String get placeComputer => 'Ordinateur';

  @override
  String get placeTrash => 'Corbeille';

  @override
  String get tooltipBack => 'Précédent';

  @override
  String get tooltipForward => 'Suivant';

  @override
  String get tooltipViewIcons => 'Afficher en icônes';

  @override
  String get tooltipViewList => 'Afficher en liste';

  @override
  String get tooltipViewColumns => 'Afficher en colonnes';

  @override
  String get tooltipEject => 'Éjecter';

  @override
  String get searchHint => 'Rechercher';

  @override
  String get columnName => 'Nom';

  @override
  String get columnModified => 'Date de modification';

  @override
  String get columnSize => 'Taille';

  @override
  String get columnKind => 'Type';

  @override
  String get kindFolder => 'Dossier';

  @override
  String get kindImage => 'Image';

  @override
  String get kindVideo => 'Film';

  @override
  String get kindAudio => 'Audio';

  @override
  String get kindText => 'Texte brut';

  @override
  String get kindCode => 'Code source';

  @override
  String get kindPdf => 'Document PDF';

  @override
  String get kindArchive => 'Archive';

  @override
  String get kindDocument => 'Document';

  @override
  String get kindSpreadsheet => 'Tableur';

  @override
  String get kindPresentation => 'Présentation';

  @override
  String get kindApplication => 'Application';

  @override
  String get kindOther => 'Document';

  @override
  String kindOtherExt(String ext) {
    return 'Fichier $ext';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '1 élément',
    );
    return '$_temp0';
  }

  @override
  String selectedOfCount(int selected, int count) {
    return '$selected sur $count sélectionné(s)';
  }

  @override
  String spaceAvailable(String size) {
    return '$size disponible(s)';
  }

  @override
  String get emptyFolder => 'Dossier vide';

  @override
  String noResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String todayAt(String time) {
    return 'Aujourd’hui à $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Hier à $time';
  }

  @override
  String get menuOpen => 'Ouvrir';

  @override
  String get menuQuickLook => 'Coup d’œil';

  @override
  String get menuRename => 'Renommer';

  @override
  String get menuDuplicate => 'Dupliquer';

  @override
  String get menuCopy => 'Copier';

  @override
  String get menuCut => 'Couper';

  @override
  String get menuPaste => 'Coller';

  @override
  String get menuMoveToTrash => 'Mettre à la corbeille';

  @override
  String get menuDeleteImmediately => 'Supprimer immédiatement…';

  @override
  String get menuPutBack => 'Remettre';

  @override
  String get menuEmptyTrash => 'Vider la corbeille';

  @override
  String get menuNewFolder => 'Nouveau dossier';

  @override
  String get menuGetInfo => 'Obtenir des informations';

  @override
  String get menuCopyPath => 'Copier le chemin';

  @override
  String get menuOpenInTerminal => 'Ouvrir dans le Terminal';

  @override
  String get menuAddToSidebar => 'Ajouter à la barre latérale';

  @override
  String get menuRemoveFromSidebar => 'Retirer de la barre latérale';

  @override
  String get menuShowHidden => 'Afficher les fichiers cachés';

  @override
  String get menuHideHidden => 'Masquer les fichiers cachés';

  @override
  String get menuNewWindow => 'Nouvelle fenêtre';

  @override
  String get goToFolderTitle => 'Aller au dossier';

  @override
  String get goToFolderHint => 'p. ex. ~/Documents ou /etc';

  @override
  String get buttonGo => 'Aller';

  @override
  String get buttonCancel => 'Annuler';

  @override
  String get buttonDelete => 'Supprimer';

  @override
  String get buttonOk => 'OK';

  @override
  String deleteConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer immédiatement $count éléments ?',
      one: 'Supprimer immédiatement cet élément ?',
    );
    return '$_temp0';
  }

  @override
  String get deleteConfirmBody => 'Vous ne pouvez pas annuler cette action.';

  @override
  String get emptyTrashConfirmTitle =>
      'Effacer définitivement les éléments de la corbeille ?';

  @override
  String get infoKind => 'Type';

  @override
  String get infoSize => 'Taille';

  @override
  String get infoWhere => 'Emplacement';

  @override
  String get infoModified => 'Modifié';

  @override
  String get infoPermissions => 'Permissions';

  @override
  String get infoCalculating => 'Calcul en cours…';

  @override
  String get untitledFolder => 'dossier sans titre';

  @override
  String get copySuffix => 'copie';

  @override
  String get pathCopied => 'Chemin copié';

  @override
  String movedToTrash(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments mis à la corbeille',
      one: '1 élément mis à la corbeille',
    );
    return '$_temp0';
  }

  @override
  String errorFolderNotFound(String path) {
    return 'Le dossier « $path » est introuvable.';
  }

  @override
  String errorOperation(String message) {
    return 'L’opération ne peut pas être effectuée : $message';
  }

  @override
  String errorNameTaken(String name) {
    return 'Le nom « $name » est déjà utilisé.';
  }

  @override
  String get errorInvalidName => 'Ce nom ne peut pas être utilisé.';

  @override
  String get quickLookNoPreview => 'Aucun aperçu disponible';

  @override
  String get tooltipGroupSort => 'Grouper et trier';

  @override
  String get menuGroupBy => 'Grouper par';

  @override
  String get menuSortBy => 'Trier par';

  @override
  String get groupNone => 'Aucun';

  @override
  String get groupToday => 'Aujourd’hui';

  @override
  String get groupYesterday => 'Hier';

  @override
  String get groupPrevious7Days => '7 jours précédents';

  @override
  String get groupPrevious30Days => '30 jours précédents';

  @override
  String get groupFolders => 'Dossiers';

  @override
  String get groupOther => 'Autre';

  @override
  String get sizeZero => 'Zéro octet';

  @override
  String sizeLessThan(String size) {
    return 'Moins de $size';
  }

  @override
  String sizeBetween(String from, String to) {
    return '$from à $to';
  }

  @override
  String sizeAtLeast(String size) {
    return '$size ou plus';
  }

  @override
  String get menuSettings => 'Réglages…';

  @override
  String get settingsTitle => 'Réglages de Finder';

  @override
  String get settingsGeneral => 'Général';

  @override
  String get settingsSidebar => 'Barre latérale';

  @override
  String get settingsAdvanced => 'Avancé';

  @override
  String get settingsNewWindowsShow => 'Les nouvelles fenêtres affichent :';

  @override
  String get settingsDefaultView => 'Présentation par défaut :';

  @override
  String get settingsAppearance => 'Apparence :';

  @override
  String get settingsLanguage => 'Langue :';

  @override
  String get settingsShowInSidebar =>
      'Afficher ces éléments dans la barre latérale :';

  @override
  String get settingsBookmarks => 'Dossiers favoris';

  @override
  String get settingsExternalDrives => 'Disques externes';

  @override
  String get settingsShowHidden => 'Afficher les fichiers cachés';

  @override
  String get settingsFoldersOnTop => 'Garder les dossiers en haut lors du tri';

  @override
  String get settingsThumbnails =>
      'Afficher les aperçus d’images dans les icônes';

  @override
  String get settingsWarnEmptyTrash => 'Avertir avant de vider la corbeille';

  @override
  String get settingsNewWindowsNote =>
      'Les choix de regroupement, de tri et de présentation s’appliquent aux fenêtres ouvertes et aux nouvelles.';

  @override
  String get appearanceSystem => 'Système';

  @override
  String get appearanceLight => 'Clair';

  @override
  String get appearanceDark => 'Sombre';

  @override
  String get languageSystem => 'Système';

  @override
  String get viewIcons => 'Icônes';

  @override
  String get viewList => 'Liste';

  @override
  String get viewColumns => 'Colonnes';

  @override
  String get placeHome => 'Dossier personnel';

  @override
  String get placeDesktop => 'Bureau';

  @override
  String get placeDocuments => 'Documents';

  @override
  String get placeDownloads => 'Téléchargements';

  @override
  String get placePictures => 'Images';

  @override
  String get placeMusic => 'Musique';

  @override
  String get placeVideos => 'Vidéos';

  @override
  String get tooltipNewTab => 'Nouvel onglet';

  @override
  String get tooltipCloseTab => 'Fermer l’onglet';

  @override
  String get menuOpenInNewTab => 'Ouvrir dans un nouvel onglet';

  @override
  String get menuCloseOtherTabs => 'Fermer les autres onglets';

  @override
  String get menuMoveTabToNewWindow =>
      'Déplacer l’onglet vers une nouvelle fenêtre';

  @override
  String get menuMergeAllWindows => 'Fusionner toutes les fenêtres';

  @override
  String mergedWindows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fenêtres fusionnées',
      one: '1 fenêtre fusionnée',
      zero: 'Aucune autre fenêtre Finder à fusionner',
    );
    return '$_temp0';
  }

  @override
  String get settingsDisplay => 'Affichage';

  @override
  String get settingsOpenFoldersInTabs =>
      'Ouvrir les dossiers dans des onglets plutôt que dans de nouvelles fenêtres';

  @override
  String get settingsAccentColor => 'Couleur d’accentuation :';

  @override
  String get settingsTextSize => 'Taille du texte :';

  @override
  String get settingsIconSize => 'Taille des icônes :';

  @override
  String get settingsShowPathBar => 'Afficher la barre de chemin';

  @override
  String get settingsShowStatusBar => 'Afficher la barre d’état';

  @override
  String get settingsShowExtensions =>
      'Afficher toutes les extensions de nom de fichier';

  @override
  String get settingsEnterRenames =>
      'Appuyer sur Entrée pour renommer (style macOS)';

  @override
  String get accentBlue => 'Bleu';

  @override
  String get accentPurple => 'Violet';

  @override
  String get accentPink => 'Rose';

  @override
  String get accentRed => 'Rouge';

  @override
  String get accentOrange => 'Orange';

  @override
  String get accentYellow => 'Jaune';

  @override
  String get accentGreen => 'Vert';

  @override
  String get accentGraphite => 'Graphite';

  @override
  String get splitDropHint => 'Déposer pour afficher côte à côte';

  @override
  String get menuSplitView => 'Afficher côte à côte';

  @override
  String get menuExitSplitView => 'Quitter la vue scindée';

  @override
  String get settingsRestoreTabs =>
      'Rouvrir les onglets de la session précédente';

  @override
  String get menuUndo => 'Annuler';

  @override
  String get menuRedo => 'Rétablir';

  @override
  String conflictTitle(String name, String folder) {
    return '« $name » existe déjà dans « $folder »';
  }

  @override
  String get conflictBody =>
      'Voulez-vous le remplacer ? L’élément remplacé est mis à la corbeille.';

  @override
  String get conflictReplace => 'Remplacer';

  @override
  String get conflictKeepBoth => 'Garder les deux';

  @override
  String get conflictSkip => 'Ignorer';

  @override
  String conflictApplyToAll(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faire de même pour les $count conflits suivants',
      one: 'Faire de même pour le conflit suivant',
    );
    return '$_temp0';
  }

  @override
  String transferCopying(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Copie de $count éléments vers « $dest »',
      one: 'Copie de 1 élément vers « $dest »',
    );
    return '$_temp0';
  }

  @override
  String transferMoving(int count, String dest) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacement de $count éléments vers « $dest »',
      one: 'Déplacement de 1 élément vers « $dest »',
    );
    return '$_temp0';
  }

  @override
  String transferBytes(String done, String total) {
    return '$done sur $total';
  }

  @override
  String transferRemaining(String time) {
    return 'environ $time restantes';
  }

  @override
  String get searchIn => 'Rechercher :';

  @override
  String searchScopeSubfolders(String folder) {
    return '« $folder » et sous-dossiers';
  }

  @override
  String get searchScopeThisFolder => 'Ce dossier uniquement';

  @override
  String get searchByName => 'Nom';

  @override
  String get searchByContents => 'Nom et contenu';

  @override
  String get searching => 'Recherche en cours…';

  @override
  String get columnLocation => 'Emplacement';

  @override
  String get tagRed => 'Rouge';

  @override
  String get tagOrange => 'Orange';

  @override
  String get tagYellow => 'Jaune';

  @override
  String get tagGreen => 'Vert';

  @override
  String get tagBlue => 'Bleu';

  @override
  String get tagPurple => 'Violet';

  @override
  String get tagGray => 'Gris';

  @override
  String get sidebarTags => 'Tags';

  @override
  String taggedIn(String tag, String folder) {
    return 'Tag $tag dans « $folder »';
  }

  @override
  String get tooltipRecentFolders => 'Dossiers récents';

  @override
  String get recentNone => 'Aucun dossier récent';

  @override
  String get menuClearRecents => 'Effacer le menu';

  @override
  String get settingsTheme => 'Thème';

  @override
  String themeEditingFor(String mode) {
    return 'Couleurs de l’apparence $mode. Le clair et le sombre gardent chacun leurs couleurs.';
  }

  @override
  String get themeAccent => 'Couleur d’accentuation';

  @override
  String get themeSelection => 'Sélection';

  @override
  String get themeFolder => 'Dossiers';

  @override
  String get themeWindow => 'Arrière-plan de la fenêtre';

  @override
  String get themeSidebar => 'Barre latérale';

  @override
  String get themeToolbar => 'Barre d’outils';

  @override
  String get themeReset => 'Utiliser la valeur par défaut';

  @override
  String get themeResetAll => 'Réinitialiser toutes les couleurs';

  @override
  String get colorPickerTitle => 'Choisir une couleur';

  @override
  String get colorHue => 'Teinte';

  @override
  String get colorSaturation => 'Saturation';

  @override
  String get colorBrightness => 'Luminosité';

  @override
  String get settingsUpdates => 'Mises à jour';

  @override
  String get updateAutoCheck => 'Rechercher automatiquement les mises à jour';

  @override
  String get updateCheckNow => 'Vérifier maintenant';

  @override
  String get updateChecking => 'Recherche de mises à jour…';

  @override
  String get updateUpToDate => 'Finder est à jour.';

  @override
  String get updateAvailable =>
      'Une nouvelle version de Finder est disponible.';

  @override
  String get updateInstall => 'Mettre à jour';

  @override
  String get updateInstalling =>
      'Téléchargement et compilation de la mise à jour. Cela peut prendre quelques minutes…';

  @override
  String get updateInstalled => 'La mise à jour est installée.';

  @override
  String get updateRestart => 'Redémarrer Finder';

  @override
  String updateFailed(String reason) {
    return 'Mise à jour impossible : $reason';
  }

  @override
  String get updateUnsupported =>
      'Cette version ne peut pas se mettre à jour. Installez-la avec install.sh pour recevoir les mises à jour.';

  @override
  String get themeEffects => 'Effets';

  @override
  String get themeSidebarOpacity => 'Opacité de la barre latérale';

  @override
  String get themeWindowOpacity => 'Opacité de la fenêtre';

  @override
  String get themeGlass => 'Style verre pour les menus, dialogues et panneaux';

  @override
  String themeBlurHint(String appId) {
    return 'Pour flouter le bureau derrière Finder, installez l’extension GNOME « Blur my Shell » et activez-la pour $appId.';
  }
}
